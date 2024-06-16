defmodule PigeonWeb.Components.Button do
  use Phoenix.Component

  attr :type, :string, default: nil
  attr :class, :string, default: nil
  attr :rest, :global, include: ~w(disabled form name value)

  slot :inner_block, required: true

  def button(assigns) do
    ~H"""
    <button type={@type} class={button_class(@class)} {@rest}>
      <%= render_slot(@inner_block) %>
    </button>
    """
  end

  def button_class(class \\ "") do
    [
      "rounded-md bg-white px-3 py-2 text-sm font-semibold text-gray-900 shadow-sm ring-1 ring-inset ring-gray-300 hover:bg-gray-50",
      class
    ]
  end
end
