defmodule Pigeon.Monitoring do
  alias Pigeon.Repo
  alias Pigeon.Monitoring.Monitor
  import Ecto.Query

  def list_monitors do
    Repo.all(Monitor)
  end

  def get_monitor(id) do
    Repo.get(Monitor, id)
  end

  def create_monitor(attrs) do
    %Monitor{}
    |> Monitor.changeset(attrs)
    |> Repo.insert()
  end

  def update_monitor(monitor, attrs) do
    monitor
    |> Monitor.changeset(attrs)
    |> Repo.update()
  end

  def update_monitor_status(monitor, attrs) do
    monitor
    |> Monitor.status_changeset(attrs)
    |> Repo.update()
  end

  def start_monitoring(monitor_id) do
    Pigeon.Monitoring.MonitorWorker.insert(monitor_id)
  end

  def stop_monitoring(monitor_id) do
    monitor_id = to_string(monitor_id)

    Oban.Job
    |> where(worker: "Pigeon.Monitoring.MonitorWorker")
    |> where([j], fragment("?->>'monitor_id' = ?", j.args, ^monitor_id))
    |> Oban.cancel_all_jobs()
  end

  def poke(%Monitor{id: id, url: url}) do
    Finch.build(:get, url)
    |> Finch.Request.put_private(:monitor_id, id)
    |> Finch.request(Pigeon.Finch)
  end
end
