defmodule Pigeon.Monitoring.MonitorWorker do
  use Oban.Worker,
    queue: :monitors,
    priority: 1,
    max_attempts: 1

  alias Pigeon.Monitoring
  alias Pigeon.Monitoring.Monitor

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
    {request, response} = poke_monitor(monitor)

    case response do
      {:ok, %{status: response_status} = response} ->
        new_monitor_status = get_status(response_status)

        if new_monitor_status != monitor.status do
          Monitoring.update_monitor_status(monitor, %{status: new_monitor_status})

          case new_monitor_status do
            :down ->
              Monitoring.create_incident(monitor, %{
                root_cause: inspect(response_status),
                request: request,
                response: response
              })

            :up ->
              Monitoring.resolve_latest_incident(monitor)
          end
        end

      {:error, reason} ->
        if monitor.status != :down do
          Monitoring.update_monitor_status(monitor, %{status: :down})

          Monitoring.create_incident(monitor, %{
            root_cause: reason,
            request: request,
            response: %{}
          })
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

  def poke_monitor(%Monitor{id: _id, url: url}) do
    {request, response} = Req.new(method: :head, url: url) |> Req.run()

    response =
      case response do
        %Req.Response{} = response -> {:ok, strip(response)}
        %Req.TransportError{reason: reason} -> {:error, error_reason(reason)}
      end

    {strip(request), response}
  end

  defp strip(%Req.Request{} = request) do
    %{
      headers: request.headers,
      url: URI.to_string(request.url),
      method: request.method
    }
  end

  defp strip(%Req.Response{} = response) do
    %{
      status: response.status,
      headers: response.headers,
      body: response.body
    }
  end

  defp error_reason(:nxdomain), do: "DNS resolution failed"
  defp error_reason(:econnrefused), do: "Connection refused"
  defp error_reason(:timeout), do: "Connection timeout"
  defp error_reason(:closed), do: "Connection closed"
end
