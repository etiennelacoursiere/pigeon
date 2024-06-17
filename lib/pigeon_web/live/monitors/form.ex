defmodule PigeonWeb.Live.Monitors.Form do
  alias Pigeon.Monitoring.Monitor
  alias Pigeon.Monitoring
  use PigeonWeb, :live_view
  use PigeonWeb.Components

  def handle_params(params, _uri, socket) do
    socket = apply_action(socket.assigns.live_action, params, socket)
    {:noreply, socket}
  end

  def apply_action(:new, _, socket) do
    socket
    |> assign(:title, "New monitor")
    |> assign(:form, to_form(Monitor.changeset(%Monitor{})))
  end

  def apply_action(:edit, %{"id" => id}, socket) do
    case Monitoring.get_monitor(id) |> Pigeon.Repo.preload(:settings) do
      nil ->
        {:noreply, redirect(socket, to: ~p"/monitors")}

      monitor ->
        socket
        |> assign(:title, "Edit monitor")
        |> assign(:form, to_form(Monitor.changeset(monitor)))
    end
  end

  def handle_event("submit", %{"monitor" => params}, socket) do
    case socket.assigns.live_action do
      :new -> create_monitor(params, socket)
      :edit -> update_monitor(params, socket)
    end
  end

  def create_monitor(params, socket) do
    case Monitoring.create_monitor(params) do
      {:ok, monitor} ->
        Monitoring.start_monitoring(monitor.id)
        {:noreply, redirect(socket, to: ~p"/monitors")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :form, to_form(changeset))}
    end
  end

  def update_monitor(params, socket) do
    case Monitoring.update_monitor(socket.assigns.form.data, params) do
      {:ok, monitor} ->
        {:noreply, redirect(socket, to: ~p"/monitors")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :form, to_form(changeset))}
    end
  end

  def options_for_interval() do
    Enum.map(
      Monitoring.MonitorSettings.intervals(),
      fn
        60 -> {"1m", 60}
        300 -> {"5m", 300}
        1800 -> {"30m", 1800}
        3600 -> {"1h", 3600}
        43200 -> {"12h", 43200}
        86400 -> {"24h", 86400}
      end
    )
  end

  def render(assigns) do
    ~H"""
    <div class="max-w-3xl mx-auto">
      <div class="pt-1">
        <h1 class="text-2xl font-bold">Create a new monitor</h1>
        <p class="text-sm text-gray-600">
          Deploy your own personal pigeonbot to monitor any url you want.
        </p>
      </div>
      <hr class="my-5" />
      <.form for={@form} class="flex flex-col gap-4" phx-submit="submit">
        <.input field={@form[:url]} label="Url to monitor" placeholder="https://" />
        <.input field={@form[:name]} label="Monitor name" />
        <hr class="my-5" />
        <.inputs_for :let={settings_form} field={@form[:settings]}>
          <.input
            field={settings_form[:interval]}
            label="Monitoring interval"
            type="select"
            options={options_for_interval()}
          />
        </.inputs_for>
        <hr class="my-5" />
        <div class="flex gap-4 justify-end">
          <.link navigate={~p"/monitors"} class={button_class()}>Cancel</.link>
          <%= if @live_action == :new do %>
            <.button type="submit">Create Monitor</.button>
          <% else %>
            <.button type="submit">Update Monitor</.button>
          <% end %>
        </div>
      </.form>
    </div>
    """
  end
end
