defmodule PigeonWeb.Components do
  defmacro __using__(_) do
    quote do
      import PigeonWeb.Components.{
        BasicTable,
        LinkList,
        Status,
        Button,
        Input
      }
    end
  end
end
