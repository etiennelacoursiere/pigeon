defmodule Pigeon.Monitoring.MonitorWorker do
  use Oban.Worker,
    queue: :monitors,
    priority: 1,
    max_attempts: 1

  alias Pigeon.Monitoring

  def insert(monitor_id, opts \\ []) do
    schedule_in = Keyword.get(opts, :schedule_in, nil)
    args = %{"monitor_id" => monitor_id}

    job =
      case schedule_in do
        nil -> new(args)
        schedule_in -> new(args, schedule_in: schedule_in)
      end

    Oban.insert(job)
  end

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"monitor_id" => monitor_id}} = job) do
    monitor = Monitoring.get_monitor(monitor_id) |> Pigeon.Repo.preload(:settings)

    case monitor do
      nil ->
        Oban.cancel_job(job)
        {:error, "Monitor with id #{monitor_id} not found"}

      _ ->
        poke_monitor(monitor)
        insert(monitor.id, schedule_in: monitor.settings.interval)

        {:ok, monitor}
    end
  end

  defp poke_monitor(monitor) do
    case Monitoring.poke(monitor) do
      {:ok, %{status: status}} ->
        new_status = get_status(status)

        if get_status(status) != monitor.status do
          # TODO: insert a incident if status is down
          Monitoring.update_monitor_status(monitor, %{status: new_status})
        end

      {:error, reason} ->
        Monitoring.update_monitor_status(monitor, %{status: :down})
        IO.inspect("Got an error: #{inspect(reason)} when poking monitor #{monitor.id}")
    end
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
