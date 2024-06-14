defmodule PigeonWeb.Live.Monitors.Index do
  alias Pigeon.Monitoring.Monitor
  use PigeonWeb, :live_view
  use PigeonWeb.Components

  def mount(_params, _session, socket) do
    if connected?(socket), do: Pigeon.Monitoring.subscribe()

    socket = assign(socket, :monitors, fetch_monitors())

    {:ok, socket}
  end

  def fetch_monitors() do
    Pigeon.Monitoring.list_monitors() |> Pigeon.Repo.preload(:settings)
  end

  def handle_info({Pigeon.Monitoring, [:monitor, _], _}, socket) do
    socket = assign(socket, :monitors, fetch_monitors())
    {:noreply, socket}
  end

  def handle_info(_, socket), do: {:noreply, socket}

  def render(assigns) do
    ~H"""
    <div class="flex items-center justify-between mb-6">
      <h1 class="text-2xl font-bold">Monitoring</h1>
      <button
        type="button"
        class="rounded-md bg-white px-3 py-2 text-sm font-semibold text-gray-900 shadow-sm ring-1 ring-inset ring-gray-300 hover:bg-gray-50"
      >
        <.link navigate={~p"/monitors/new"} class="btn btn-primary">New Monitor</.link>
      </button>
    </div>
    <.link_list :let={monitor} rows={@monitors}>
      <div class="flex items-center gap-x-4">
        <.status status={monitor.status} />
        <div>
          <.link navigate={~p"/monitors/#{monitor.id}"} class="font-medium hover:underline">
            <%= monitor.name %>
          </.link>
          <p class="text-xs">
            <%= monitor.status %> for <%= time_since_last_status_change(monitor) %>
          </p>
        </div>
      </div>
      <div class="flex items-center">
        <p>every <%= interval_in_min(monitor.settings.interval) %> min</p>
      </div>
    </.link_list>
    """
  end

  defp interval_in_min(interval) do
    (interval / 60) |> round()
  end

  defp time_since_last_status_change(monitor) do
    {h, m, _s, _ms} =
      monitor
      |> Monitor.time_since_last_status_change()
      |> Timex.Duration.from_seconds()
      |> Timex.Duration.to_clock()

    "#{h}h #{m}m "
  end
end
