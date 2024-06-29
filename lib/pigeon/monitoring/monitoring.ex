defmodule Pigeon.Monitoring do
  alias Pigeon.Repo
  alias Pigeon.Monitoring.Monitor
  alias Pigeon.Monitoring.Incident
  import Ecto.Query

  def list_monitors do
    Monitor
    |> order_by(:name)
    |> Repo.all()
    |> Repo.preload(:settings)
  end

  def get_monitor(id) do
    Repo.get(Monitor, id) |> Repo.preload(:settings)
  end

  def create_monitor(attrs) do
    %Monitor{}
    |> Monitor.changeset(attrs)
    |> Repo.insert()
    |> broadcast([:monitor, :created])
  end

  def update_monitor(monitor, attrs) do
    monitor
    |> Monitor.changeset(attrs)
    |> tap(&reschedule_monitor(monitor, &1))
    |> Repo.update()
    |> broadcast([:monitor, :updated])
  end

  defp reschedule_monitor(monitor, %Ecto.Changeset{changes: changes}) do
    settings = changes |> Map.get(:settings, %{}) |> Map.get(:changes, %{})
    url_changed = Map.has_key?(changes, :url)
    interval_changed = Map.has_key?(settings, :interval)

    if url_changed or interval_changed do
      cancel_worker_jobs(monitor.id)
      start_monitoring(monitor.id)
    end
  end

  def update_monitor_status(monitor, attrs) do
    monitor
    |> Monitor.status_changeset(attrs)
    |> Repo.update()
    |> broadcast([:monitor, :status_updated])
  end

  def start_monitoring(monitor_id) do
    Pigeon.Monitoring.MonitorWorker.insert(monitor_id)
  end

  def pause_monitoring(%Monitor{id: monitor_id} = monitor) do
    cancel_worker_jobs(monitor_id)
    update_monitor_status(monitor, %{status: :paused})
  end

  defp cancel_worker_jobs(monitor_id) do
    monitor_id = to_string(monitor_id)

    Oban.Job
    |> where(worker: "Pigeon.Monitoring.MonitorWorker")
    |> where([j], fragment("?->>'monitor_id' = ?", j.args, ^monitor_id))
    |> Oban.cancel_all_jobs()
  end

  def uptime_percentage(monitor) do
    incidents =
      Incident
      |> where(monitor_id: ^monitor.id)
      |> select([i], %{inserted_at: i.inserted_at, resolved_on: i.resolved_on})
      |> Repo.all()

    downtime =
      Enum.reduce(incidents, 0, fn incident, acc ->
        resolved_on =
          case incident.resolved_on do
            nil -> NaiveDateTime.utc_now()
            t -> t
          end

        acc + Timex.diff(resolved_on, incident.inserted_at, :seconds)
      end)

    total_time = Timex.diff(NaiveDateTime.utc_now(), monitor.inserted_at, :seconds)

    percentage = (total_time - downtime) / total_time * 100
    Float.round(percentage, 2)
  end

  def list_incidents do
    Incident
    |> order_by([i], desc: i.inserted_at)
    |> Repo.all()
    |> Repo.preload([:monitor])
  end

  def get_incident(id) do
    Repo.get(Incident, id) |> Repo.preload([:monitor])
  end

  def create_incident(monitor, attrs \\ %{}) do
    attrs = Map.put(attrs, :monitor_id, monitor.id)

    %Incident{}
    |> Incident.new_incident_changeset(attrs)
    |> Repo.insert()
    |> broadcast([:incident, :created])
  end

  def resolve_incident(incident) do
    incident
    |> Incident.resolve_incident_changeset()
    |> Repo.update()
    |> broadcast([:incident, :resolved])
  end

  def resolve_latest_incident(monitor) do
    Incident
    |> where(monitor_id: ^monitor.id)
    |> last(:inserted_at)
    |> Repo.one()
    |> case do
      nil -> nil
      incident -> resolve_incident(incident)
    end
  end

  @topic inspect(__MODULE__)
  @schemas [:monitor, :incident]

  def subscribe(schema) when schema in @schemas do
    Phoenix.PubSub.subscribe(Pigeon.PubSub, "#{@topic}:#{to_string(schema)}")
  end

  def subscribe(schema, id) when schema in @schemas do
    Phoenix.PubSub.subscribe(Pigeon.PubSub, "#{@topic}:#{to_string(schema)}:#{id}")
  end

  def broadcast({:ok, result}, [schema, _] = event) do
    topic = "#{@topic}:#{to_string(schema)}"
    Phoenix.PubSub.broadcast(Pigeon.PubSub, topic, {__MODULE__, event, result})
    Phoenix.PubSub.broadcast(Pigeon.PubSub, "#{topic}:#{result.id}", {__MODULE__, event, result})
    {:ok, result}
  end

  def broadcast({:error, reason}, _), do: {:error, reason}
end
