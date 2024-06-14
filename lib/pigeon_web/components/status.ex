defmodule PigeonWeb.Components.Status do
  use Phoenix.Component

  attr :status, :string, required: true

  def status(assigns) do
    ~H"""
    <%= if @status in [:up, :resolved] do %>
      <div class="size-5 bg-green-400 rounded-full"></div>
    <% end %>
    <%= if @status in [:down, :ongoing] do %>
      <div class="size-5 bg-red-400 rounded-full"></div>
    <% end %>
    <%= if @status == :paused do %>
      <div class="size-5 bg-yellow-400 rounded-full"></div>
    <% end %>
    """
  end
end
