defmodule PigeonWeb.Components.Status do
  use Phoenix.Component
  import PigeonWeb.CoreComponents, only: [icon: 1]

  attr :status, :string, required: true
  attr :class, :string, default: nil

  def status(assigns) do
    ~H"""
    <%= if @status in [:up, :resolved] do %>
      <.icon name="hero-arrow-up-circle" class={"size-8 text-green-400 #{@class}"} />
    <% end %>
    <%= if @status in [:down, :ongoing] do %>
      <.icon name="hero-arrow-down-circle" class={"size-8 text-red-400 #{@class}"} />
    <% end %>
    <%= if @status == :paused do %>
      <.icon name="hero-pause-circle" class={"size-8 text-yellow-400 #{@class}"} />
    <% end %>
    """
  end
end
