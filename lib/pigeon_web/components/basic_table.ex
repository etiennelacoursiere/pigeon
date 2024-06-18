defmodule PigeonWeb.Components.BasicTable do
  use Phoenix.Component

  slot :column do
    attr :label, :string, required: true
  end

  attr :rows, :list, default: []

  def basic_table(assigns) do
    ~H"""
    <div class="-mx-4 ring-1 ring-gray-200 sm:mx-0 sm:rounded-lg">
      <table class="min-w-full divide-y divide-gray-200">
        <thead>
          <tr>
            <%= for col <- @column do %>
              <th
                scope="col"
                class="hidden px-3 py-3.5 text-left text-xs font-semibold text-gray-900 lg:table-cell"
              >
                <%= col.label %>
              </th>
            <% end %>
          </tr>
        </thead>
        <tbody>
          <%= for row <- @rows do %>
            <tr class="hover:bg-gray-50">
              <%= for col <- @column do %>
                <td class=" border-t border-gray-200 px-3 py-3.5 text-sm text-gray-500">
                  <%= render_slot(col, row) %>
                </td>
              <% end %>
            </tr>
          <% end %>
        </tbody>
      </table>
    </div>
    """
  end
end
