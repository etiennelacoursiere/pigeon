# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Pigeon.Repo.insert!(%Pigeon.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias Pigeon.Repo
alias Pigeon.Accounts.User
alias Pigeon.Monitoring

urls = [
  {"Localhost", "http://localhost:4000"},
  {"Phoenix Website", "https://www.phoenixframework.org/"}
]

Enum.each(urls, fn {name, url} ->
  attrs = %{
    name: name,
    url: url,
    settings: %{
      check_ssl_errors: true,
      ssl_expiry_reminders: true,
      domain_expiry_reminders: true
    }
  }

  Monitoring.create_monitor(attrs)
end)
