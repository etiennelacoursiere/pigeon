defmodule PigeonWeb.Components.LinkList do
  use Phoenix.Component

  slot :inner_block, required: true
  attr :rows, :list, default: []

  def link_list(assigns) do
    ~H"""
    <ul
      role="list"
      class="divide-y divide-gray-100 overflow-hidden bg-white shadow-sm ring-1 ring-gray-900/5 sm:rounded-xl"
    >
      <%= for row <- @rows do %>
        <li class="relative flex justify-between gap-x-6 px-4 py-4 hover:bg-gray-50 sm:px-6">
          <%= render_slot(@inner_block, row) %>
        </li>
      <% end %>
    </ul>
    """
  end
end
