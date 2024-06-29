defmodule PigeonWeb.Live.Monitors.Show do
  alias Pigeon.Monitoring
  alias PigeonWeb.Live.Monitors.Utils, as: MonitorUtils
  alias PigeonWeb.Live.Incidents.Utils, as: IncidentUtils
  use PigeonWeb, :live_view
  use PigeonWeb.Components

  def mount(%{"id" => id}, _, socket) do
    case Monitoring.get_monitor(id) do
      nil ->
        socket =
          socket
          |> put_flash(:error, "Monitor not found")
          |> redirect(to: "/monitors")

        {:ok, socket}

      monitor ->
        if connected?(socket), do: Pigeon.Monitoring.subscribe(:monitor, id)

        socket =
          socket
          |> assign(:monitor, monitor)
          |> assign(:incidents, Monitoring.list_incidents_for_monitor(monitor))

        {:ok, socket}
    end
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
      <div class="mb-10">
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
            <dd class="mt-1 text-3xl font-semibold tracking-tight text-gray-900">
              <%= Monitoring.uptime_percentage(@monitor) %>%
            </dd>
          </div>
        </dl>
      </div>

      <h2 class="text-2xl font-bold mb-5">Incidents</h2>
      <%= if length(@incidents) == 0 do %>
        <p class="text-gray-500">Your biotech pigeon spies haven't reported an incident yet.</p>
      <% else %>
        <.basic_table rows={@incidents}>
          <:column :let={incident} label="Status">
            <div class="flex gap-2 items-center">
              <.status status={incident.status} />
              <span><%= incident.status %></span>
            </div>
          </:column>
          <:column :let={incident} label="Monitor">
            <%= incident.monitor.name %>
          </:column>
          <:column :let={incident} label="Root cause">
            <%= incident.root_cause %>
          </:column>
          <:column :let={incident} label="Started">
            <%= IncidentUtils.started_at(@current_user, incident.inserted_at) %>
          </:column>
          <:column :let={incident} label="Duration">
            <%= IncidentUtils.duration(incident) %>
          </:column>
          <:column :let={incident} label="">
            <.link navigate={~p"/incidents/#{incident.id}"} class="font-bold underline">
              View
            </.link>
          </:column>
        </.basic_table>
      <% end %>
    </div>
    """
  end
end
