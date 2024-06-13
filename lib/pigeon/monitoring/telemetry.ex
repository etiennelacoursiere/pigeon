defmodule Pigeon.Monitoring.Telemetry do
  def attach() do
    :telemetry.attach("finch_request", [:finch, :recv, :stop], &__MODULE__.handle_event/4, nil)
  end

  def handle_event(
        [:finch, :recv, :stop],
        %{duration: duration},
        _metadata,
        _config
      ) do
    # TODO: Not sure this is quite right. Need to look into that
    response_time = System.convert_time_unit(duration, :native, :millisecond)

    # TODO: Save the response time in the database
    IO.inspect(response_time)
  end
end
