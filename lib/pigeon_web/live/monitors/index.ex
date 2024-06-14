defmodule PigeonWeb.Live.Monitors.Index do
  use PigeonWeb, :live_view

  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign_async(:monitors, &fetch_monitors/0)

    {:ok, socket}
  end

  defp fetch_monitors do
    {:ok, %{monitors: Pigeon.Monitoring.list_monitors()}}
  end

  def render(assigns) do
    ~H"""
    <h1 class="text-2xl font-bold mb-4">Monitoring</h1>
    <div class="px-3 py-4 border border-zinc-100 rounded-md">
      <.async_result :let={monitors} assign={@monitors}>
        <:loading>
          <p>Loading...</p>
        </:loading>

        <div class="flex flex-col gap-4">
          <%= if length(monitors) > 0 do %>
            <%= for monitor <- monitors do %>
              <div class="flex items-center px-2 py-4 gap-4">
                <%= if monitor.status == :up do %>
                  <div class="size-4 bg-green-400 rounded-full"></div>
                <% end %>
                <%= if monitor.status == :paused do %>
                  <div class="size-4 bg-yellow-400 rounded-full"></div>
                <% end %>
                <%= if monitor.status == :down do %>
                  <div class="size-4 bg-red-400 rounded-full"></div>
                <% end %>

                <.link navigate={~p"/monitors/#{monitor.id}"} class="font-medium">
                  <%= monitor.name %>
                </.link>
              </div>
            <% end %>
          <% end %>
        </div>
      </.async_result>
    </div>
    """
  end
end
