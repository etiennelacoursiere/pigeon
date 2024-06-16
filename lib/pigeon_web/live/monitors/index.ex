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
      <h1 class="text-2xl font-bold">Monitors</h1>
      <.link navigate={~p"/monitors/new"} class={button_class()}>New Monitor</.link>
    </div>
    <%= if length(@monitors) == 0 do %>
      <p class="text-gray-500">No monitors found</p>
    <% else %>
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
        <div class="flex items-center gap-2">
          <.icon name="hero-arrow-path" class="w-4 h-4" />
          <p>
            <%= interval(monitor.settings.interval) %>
          </p>
        </div>
      </.link_list>
    <% end %>
    """
  end

  defp interval(interval) do
    case Timex.Duration.from_seconds(interval) |> Timex.Duration.to_clock() do
      {0, 0, s, _ms} -> "#{s}s"
      {0, m, 0, _ms} -> "#{m}m"
      {h, 0, 0, _ms} -> "#{h}h"
    end
  end

  defp time_since_last_status_change(monitor) do
    {h, m, _s, _ms} =
      monitor
      |> Monitor.time_since_last_status_change()
      |> Timex.Duration.from_seconds()
      |> Timex.Duration.to_clock()

    "#{h}h #{m}m"
  end
end
