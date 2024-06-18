defmodule PigeonWeb.Live.Monitors.Show do
  alias Pigeon.Monitoring
  alias Pigeon.Monitoring.Monitor
  alias PigeonWeb.Live.Monitors.Utils, as: MonitorUtils
  use PigeonWeb, :live_view
  use PigeonWeb.Components

  def mount(%{"id" => id}, _, socket) do
    # TODO: Check if the monitor exists

    monitor = Monitoring.get_monitor(id)
    if connected?(socket), do: Pigeon.Monitoring.subscribe(:monitor, id)

    {:ok, assign(socket, monitor: monitor)}
  end

  def handle_event("start_monitoring", _, socket) do
    Monitoring.start_monitoring(socket.assigns.monitor.id)
    {:noreply, socket}
  end

  def handle_event("pause_monitoring", _, socket) do
    Monitoring.pause_monitoring(socket.assigns.monitor)
    {:noreply, socket}
  end

  def handle_info({Pigeon.Monitoring, [:monitor, _], monitor}, socket) do
    socket = assign(socket, :monitor, Monitoring.get_monitor(monitor.id))
    {:noreply, socket}
  end

  def handle_info(_, socket), do: {:noreply, socket}

  def render(assigns) do
    ~H"""
    <div class="mx-auto">
      <.header separator={true}>
        <div class="flex items-center gap-3">
          <%= @monitor.name %>
          <.status status={@monitor.status} class="size-3" />
        </div>
        <:subtitle>
          <.link href={@monitor.url} class="flex items-center gap-2 hover:underline" target="_blank">
            <%= @monitor.url %> <.icon name="hero-arrow-top-right-on-square" class="size-4" />
          </.link>
        </:subtitle>
        <:actions>
          <%= if @monitor.status == :paused do %>
            <.button phx-click="start_monitoring">Start monitoring</.button>
          <% else %>
            <.button phx-click="pause_monitoring">Pause monitoring</.button>
          <% end %>
        </:actions>
        <:actions>
          <.link navigate={~p"/monitors/#{@monitor.id}/edit"} class={button_class()}>
            Edit Monitor
          </.link>
        </:actions>
      </.header>
      <div>
        <dl class="mt-5 grid grid-cols-1 gap-5 sm:grid-cols-3">
          <div class="overflow-hidden rounded-lg bg-white px-4 py-5 sm:p-6 border border-gray-200">
            <dt class="truncate text-sm font-medium text-gray-500">Status</dt>
            <dd class="mt-1">
              <span class="text-3xl font-semibold tracking-tight text-gray-900">
                <%= @monitor.status |> to_string() |> String.capitalize() %>
              </span>
              <span class="text-sm text-gray-600">
                for <%= MonitorUtils.status_changed_at(@monitor) %>
              </span>
            </dd>
          </div>
          <div class="overflow-hidden rounded-lg bg-white px-4 py-5 sm:p-6 border border-gray-200">
            <dt class="truncate text-sm font-medium text-gray-500">Check interval</dt>
            <dd class="mt-1 text-3xl font-semibold tracking-tight text-gray-900">
              <%= MonitorUtils.interval(@monitor) %>
            </dd>
          </div>
          <div class="overflow-hidden rounded-lg bg-white px-4 py-5 sm:p-6 border border-gray-200">
            <dt class="truncate text-sm font-medium text-gray-500">Avg. Uptime</dt>
            <dd class="mt-1 text-3xl font-semibold tracking-tight text-gray-900">98.57%</dd>
          </div>
        </dl>
      </div>
    </div>
    """
  end
end
