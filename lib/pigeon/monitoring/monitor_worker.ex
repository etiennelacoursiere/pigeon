defmodule Pigeon.Monitoring.MonitorWorker do
  use Oban.Worker,
    queue: :monitors,
    priority: 1,
    max_attempts: 1

  alias Pigeon.Monitoring

  def insert(monitor_id) do
    new(%{"monitor_id" => monitor_id}) |> Oban.insert()
  end

  defp schedule(monitor) do
    new(%{"monitor_id" => monitor.id}, schedule_in: monitor.settings.interval) |> Oban.insert()
  end

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"monitor_id" => monitor_id}} = job) do
    monitor_id
    |> Monitoring.get_monitor()
    |> process_monitor(job)
  end

  defp process_monitor(nil, job) do
    Oban.cancel_job(job)
    {:error, "Monitor not found"}
  end

  defp process_monitor(monitor, _job) do
    case Monitoring.poke_monitor(monitor) do
      {:ok, %{status: response_status}} ->
        new_monitor_status = get_status(response_status)

        if new_monitor_status != monitor.status do
          Monitoring.update_monitor_status(monitor, %{status: new_monitor_status})

          case new_monitor_status do
            :down -> Monitoring.create_incident(monitor, %{root_cause: inspect(response_status)})
            :up -> Monitoring.resolve_latest_incident(monitor)
          end
        end

      {:error, reason} ->
        if monitor.status != :down do
          Monitoring.update_monitor_status(monitor, %{status: :down})
          Monitoring.create_incident(monitor, %{root_cause: inspect(reason)})
        end
    end

    schedule(monitor)

    {:ok, monitor}
  end

  # TODO: Refactor to take preferences into account.
  # Like what which status code to consider as error
  defp get_status(status) do
    cond do
      status >= 200 and status < 300 -> :up
      status >= 300 and status < 400 -> :up
      true -> :down
    end
  end
end
