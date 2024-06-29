defmodule PigeonWeb.Live.Incidents.Index do
  alias PigeonWeb.Live.Incidents.Utils, as: IncidentUtils
  use PigeonWeb, :live_view
  use PigeonWeb.Components

  def mount(_params, _session, socket) do
    if connected?(socket), do: Pigeon.Monitoring.subscribe(:incident)

    socket = assign(socket, :incidents, Pigeon.Monitoring.list_incidents())

    {:ok, socket}
  end

  def handle_info({Pigeon.Monitoring, [:incident, _], _}, socket) do
    {:noreply, assign(socket, :incidents, Pigeon.Monitoring.list_incidents())}
  end

  def handle_info(_, socket), do: {:noreply, socket}

  def render(assigns) do
    ~H"""
    <.header>
      Incidents
    </.header>
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
    """
  end
end
