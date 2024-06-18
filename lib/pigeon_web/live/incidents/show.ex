defmodule PigeonWeb.Live.Incidents.Show do
  alias Pigeon.Monitoring
  use PigeonWeb, :live_view
  use PigeonWeb.Components

  def mount(%{"id" => id}, _, socket) do
    # TODO: Check if the incident exists

    incident = Monitoring.get_incident(id)
    if connected?(socket), do: Pigeon.Monitoring.subscribe(:incident, id)

    {:ok, assign(socket, incident: incident)}
  end

  def handle_info({Pigeon.Monitoring, [:incident, _], incident}, socket) do
    socket = assign(socket, :incident, Monitoring.get_incident(incident.id))
    {:noreply, socket}
  end

  def handle_info(_, socket), do: {:noreply, socket}

  def title(incident) do
    status = incident.status |> to_string() |> String.capitalize()
    "#{status} incident on #{incident.monitor.name}"
  end

  def render(assigns) do
    ~H"""
    <div class="mx-auto">
      <.header separator={true}>
        <div class="flex items-center gap-3">
          <%= title(@incident) %>
          <.status status={@incident.status} class="size-3" />
        </div>
        <:actions>
          <.link navigate={~p"/monitors/#{@incident.monitor.id}"} class={button_class()}>
            View Monitor
          </.link>
        </:actions>
      </.header>
    </div>
    """
  end
end
