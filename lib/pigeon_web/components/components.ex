defmodule PigeonWeb.Components do
  defmacro __using__(_) do
    quote do
      import PigeonWeb.Components.{
        BasicTable,
        DataList,
        Status,
        Button,
        Input
      }
    end
  end
end
