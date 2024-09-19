defmodule PigeonWeb.Components.Button do
  use Phoenix.Component

  attr :type, :string, default: nil
  attr :class, :string, default: nil
  attr :rest, :global, include: ~w(disabled form name value)
  attr :variant, :string, default: "primary"

  slot :inner_block, required: true

  def button(assigns) do
    ~H"""
    <button type={@type} class={button_class(@class, @variant)} {@rest}>
      <%= render_slot(@inner_block) %>
    </button>
    """
  end

  def button_class(class \\ "", variant \\ "primary") do
    [
      "rounded-md bg-white px-3 py-2 text-sm font-semibold  shadow-sm ring-1 ring-inset ring-gray-300 hover:bg-gray-50 appearance-auto",
      case variant do
        "primary" -> "text-gray-900"
        "danger" -> "text-red-400"
      end,
      class
    ]
  end
end
