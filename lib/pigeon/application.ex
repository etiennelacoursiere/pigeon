defmodule Pigeon.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    Pigeon.Monitoring.Telemetry.attach()

    children = [
      PigeonWeb.Telemetry,
      Pigeon.Repo,
      {Oban, Application.fetch_env!(:pigeon, Oban)},
      {DNSCluster, query: Application.get_env(:pigeon, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Pigeon.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Pigeon.Finch},
      # Start a worker by calling: Pigeon.Worker.start_link(arg)
      # {Pigeon.Worker, arg},
      # Start to serve requests, typically the last entry
      PigeonWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Pigeon.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    PigeonWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
