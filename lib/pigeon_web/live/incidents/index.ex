defmodule PigeonWeb.Live.Incidents.Index do
  alias Pigeon.Monitoring.Incident
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
    <%= if length(@incidents) == 0 do %>
      <p class="text-gray-500">Your biotech pigeon spies haven't reported an incident yet.</p>
    <% else %>
      <.basic_table rows={@incidents}>
        <:column :let={incident} label="Status">
          <div class="flex gap-2">
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
          <%!-- TODO: Format based on user timezone --%>
          <%= incident.inserted_at %>
        </:column>
        <:column :let={incident} label="Duration">
          <%= duration(incident) %>
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

  defp duration(incident) do
    {h, m, s, _} =
      incident
      |> Incident.duration()
      |> Timex.Duration.from_seconds()
      |> Timex.Duration.to_clock()

    "#{h}h #{m}m #{s}s"
  end
end
