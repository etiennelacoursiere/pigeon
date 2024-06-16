defmodule PigeonWeb.Live.UserSettings.Form do
  alias Pigeon.Accounts.User
  alias Pigeon.Monitoring
  use PigeonWeb, :live_view
  use PigeonWeb.Components

  def mount(_, _, socket) do
    socket =
      socket
      |> assign(:form, to_form(User.changeset(%User{})))

    {:ok, socket}
  end

  def handle_event("submit", %{"user" => params}, socket) do
    {:noreply, socket}
  end

  def render(assigns) do
    ~H"""
    <div class="max-w-3xl mx-auto">
      <div class="pt-1">
        <h1 class="text-2xl font-bold">User settings</h1>
      </div>
      <hr class="my-5" />
      <.form for={@form} class="flex flex-col gap-4" phx-submit="submit">
        <.input field={@form[:name]} label="Name" />
        <.input field={@form[:email]} label="email" />
        <.input field={@form[:tz]} label="Timezone" type="select" options={[]} />
        <hr class="my-5" />
        <div class="flex gap-4 justify-end">
          <.button type="submit">Update profile</.button>
        </div>
      </.form>
    </div>
    """
  end
end
