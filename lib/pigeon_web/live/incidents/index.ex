defmodule PigeonWeb.Live.Incidents.Index do
  use PigeonWeb, :live_view
  use PigeonWeb.Components

  def mount(_params, _session, socket) do
    if connected?(socket), do: Pigeon.Monitoring.subscribe()

    socket = assign(socket, :incidents, fetch_incidents())

    {:ok, socket}
  end

  def fetch_incidents() do
    Pigeon.Monitoring.list_incidents()
  end

  def handle_info({Pigeon.Monitoring, [:incident, _], _}, socket) do
    {:noreply, assign(socket, :incidents, fetch_incidents())}
  end

  def handle_info(_, socket), do: {:noreply, socket}

  def render(assigns) do
    ~H"""
    <div class="flex items-center justify-between mb-6">
      <h1 class="text-2xl font-bold">Incidents</h1>
    </div>
    <.link_list :let={incident} rows={@incidents}>
      <div class="flex items-center gap-x-4">
        <.status status={incident.status} />
        <p>
          <%= incident.status %>
        </p>
      </div>
      <p><%= incident.monitor.name %></p>
      <.link navigate={~p"/incidents/#{incident.id}"} class="font-medium hover:underline">
        <%= incident.root_cause %>
      </.link>
    </.link_list>
    """
  end
end
