defmodule PigeonWeb.Live.Monitors.Index do
  alias Pigeon.Monitoring.Monitor
  alias PigeonWeb.Live.Monitors.Utils, as: MonitorUtils
  use PigeonWeb, :live_view
  use PigeonWeb.Components

  def mount(_params, _session, socket) do
    if connected?(socket), do: Pigeon.Monitoring.subscribe(:monitor)

    socket = assign(socket, :monitors, fetch_monitors())

    {:ok, socket}
  end

  def fetch_monitors() do
    Pigeon.Monitoring.list_monitors()
  end

  def handle_info({Pigeon.Monitoring, [:monitor, _], _}, socket) do
    socket = assign(socket, :monitors, fetch_monitors())
    {:noreply, socket}
  end

  def handle_info(_, socket), do: {:noreply, socket}

  def render(assigns) do
    ~H"""
    <.header>
      Monitors
      <:actions>
        <.link navigate={~p"/monitors/new"} class={button_class()}>New Monitor</.link>
      </:actions>
    </.header>
    <%= if length(@monitors) == 0 do %>
      <p class="text-gray-500">No monitors found</p>
    <% else %>
      <.data_list :let={monitor} rows={@monitors}>
        <div class="flex items-center gap-x-4">
          <.status status={monitor.status} />
          <div>
            <.link navigate={~p"/monitors/#{monitor.id}"} class="font-medium hover:underline">
              <%= monitor.name %>
            </.link>
            <p class="text-xs">
              <%= monitor.status %> for <%= MonitorUtils.status_changed_at(monitor) %>
            </p>
          </div>
        </div>
        <div class="flex items-center gap-2">
          <.icon name="hero-arrow-path" class="w-4 h-4" />
          <p>
            <%= MonitorUtils.interval(monitor) %>
          </p>
        </div>
      </.data_list>
    <% end %>
    """
  end
end
