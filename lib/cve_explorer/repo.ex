defmodule CveExplorer.Repo do
  use Ecto.Repo,
    otp_app: :cve_explorer,
    adapter: Ecto.Adapters.Postgres
end
