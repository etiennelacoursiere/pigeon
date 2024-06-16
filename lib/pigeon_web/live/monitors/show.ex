defmodule PigeonWeb.Live.Monitors.Show do
  alias Pigeon.Monitoring.Monitor
  alias Pigeon.Monitoring
  use PigeonWeb, :live_view
  use PigeonWeb.Components

  def mount(%{"id" => id}, _, socket) do
    monitor = Monitoring.get_monitor(id) |> Pigeon.Repo.preload(:settings)
    {:ok, assign(socket, monitor: monitor)}
  end

  defp time_since_last_status_change(monitor) do
    {h, m, _s, _ms} =
      monitor
      |> Monitor.time_since_last_status_change()
      |> Timex.Duration.from_seconds()
      |> Timex.Duration.to_clock()

    "#{h}h #{m}m"
  end

  defp interval(interval) do
    case Timex.Duration.from_seconds(interval) |> Timex.Duration.to_clock() do
      {0, 0, s, _ms} -> "#{s}s"
      {0, m, 0, _ms} -> "#{m}m"
      {h, 0, 0, _ms} -> "#{h}h"
    end
  end

  def render(assigns) do
    ~H"""
    <div class="mx-auto">
      <div class="flex items-center justify-between">
        <div>
          <h1 class="text-2xl font-bold mb-2"><%= @monitor.name %></h1>
          <.link href={@monitor.url} class=" flex items-center gap-2 hover:underline" target="_blank">
            <%= @monitor.url %> <.icon name="hero-arrow-top-right-on-square" class="size-4" />
          </.link>
        </div>
        <.link navigate={~p"/monitors/#{@monitor.id}/edit"} class={button_class()}>
          Edit Monitor
        </.link>
      </div>
    </div>
    """
  end
end
