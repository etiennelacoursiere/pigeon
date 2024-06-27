defmodule PigeonWeb.Live.Incidents.Show do
  alias Pigeon.Monitoring
  use PigeonWeb, :live_view
  use PigeonWeb.Components
  alias PigeonWeb.Live.Incidents.Utils, as: IncidentUtils

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
      <dl class="mt-5 grid grid-cols-1 gap-5 sm:grid-cols-3">
        <div class="overflow-hidden rounded-lg bg-white px-4 py-5 sm:p-6 border border-gray-200">
          <dt class="truncate text-sm font-medium text-gray-500">Status</dt>
          <dd class="mt-1">
            <span class="text-3xl font-semibold tracking-tight text-gray-900">
              <%= @incident.status |> to_string() |> String.capitalize() %>
            </span>
          </dd>
        </div>
        <div class="overflow-hidden rounded-lg bg-white px-4 py-5 sm:p-6 border border-gray-200">
          <dt class="truncate text-sm font-medium text-gray-500">Duration</dt>
          <dd class="mt-1 text-3xl font-semibold tracking-tight text-gray-900">
            <%= IncidentUtils.duration(@incident) %>
          </dd>
          <dd class="mt-1 text-sm text-gray-600">
            Started at <%= IncidentUtils.started_at(@current_user, @incident.inserted_at) %>
          </dd>
        </div>
        <div class="overflow-hidden rounded-lg bg-white px-4 py-5 sm:p-6 border border-gray-200">
          <dt class="truncate text-sm font-medium text-gray-500">Root cause</dt>
          <dd class="mt-1 text-3xl font-semibold tracking-tight text-gray-900">
            <%= @incident.root_cause %>
          </dd>
        </div>
      </dl>
      <dl class="mt-5 grid grid-cols-1 gap-5 sm:grid-cols-2">
        <div class="overflow-hidden rounded-lg bg-white px-4 py-5 sm:p-6 border border-gray-200">
          <dt class="truncate text-sm font-medium text-gray-500">Request</dt>
          <dd class="mt-1">
            <pre class="bg-slate-100 p-4 rounded-md text-sm language-json">
              <code lang="json">
                <%= Jason.encode!(@incident.request, escape: :javascript_safe, pretty: true) %>
              </code>
             </pre>
          </dd>
        </div>
        <div class="overflow-hidden rounded-lg bg-white px-4 py-5 sm:p-6 border border-gray-200">
          <dt class="truncate text-sm font-medium text-gray-500">Request</dt>
          <dd class="mt-1">
            <pre class="bg-slate-100 p-4 rounded-md text-sm">
              <code lang="json">
                <%= Jason.encode!(@incident.response, escape: :javascript_safe, pretty: true) %>
              </code>
             </pre>
          </dd>
        </div>
      </dl>
    </div>
    """
  end
end
