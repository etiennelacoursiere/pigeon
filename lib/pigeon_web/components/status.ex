defmodule PigeonWeb.Components.Status do
  use Phoenix.Component

  attr :status, :string, required: true
  attr :class, :string, default: nil

  def status(assigns) do
    ~H"""
    <%= if @status in [:up, :resolved] do %>
      <span class={"size-5 bg-green-400 rounded-full #{@class}"}></span>
    <% end %>
    <%= if @status in [:down, :ongoing] do %>
      <span class={"size-5 bg-red-400 rounded-full #{@class}"}></span>
    <% end %>
    <%= if @status == :paused do %>
      <span class={"size-5 bg-yellow-400 rounded-full #{@class}"}></span>
    <% end %>
    """
  end
end
