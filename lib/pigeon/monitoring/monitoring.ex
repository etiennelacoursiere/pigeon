defmodule Pigeon.Monitoring do
  alias Pigeon.Repo
  alias Pigeon.Monitoring.Monitor
  alias Pigeon.Monitoring.Incident
  import Ecto.Query

  def list_monitors do
    Monitor
    |> order_by(:name)
    |> Repo.all()
  end

  def get_monitor(id) do
    Repo.get(Monitor, id)
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
    |> Repo.update()
    |> broadcast([:monitor, :updated])
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

  def pause_monitoring(monitor_id) do
    monitor_id = to_string(monitor_id)

    Oban.Job
    |> where(worker: "Pigeon.Monitoring.MonitorWorker")
    |> where([j], fragment("?->>'monitor_id' = ?", j.args, ^monitor_id))
    |> Oban.cancel_all_jobs()

    monitor_id
    |> get_monitor()
    |> update_monitor_status(%{status: :paused})
  end

  def poke_monitor(%Monitor{id: id, url: url}) do
    Finch.build(:get, url)
    |> Finch.Request.put_private(:monitor_id, id)
    |> Finch.request(Pigeon.Finch)
  end

  def list_incidents do
    Incident
    |> order_by([i], desc: i.inserted_at)
    |> Repo.all()
    |> Repo.preload([:monitor])
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

  def get_incident(id) do
    Repo.get(Incident, id)
  end

  @topic inspect(__MODULE__)
  def subscribe() do
    Phoenix.PubSub.subscribe(Pigeon.PubSub, @topic)
  end

  def broadcast({:ok, result}, event) do
    Phoenix.PubSub.broadcast(Pigeon.PubSub, @topic, {__MODULE__, event, result})
    {:ok, result}
  end

  def broadcast({:error, reason}, _), do: {:error, reason}
end
