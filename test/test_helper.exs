ExUnit.start()
Ecto.Adapters.SQL.Sandbox.mode(CveExplorer.Repo, :manual)

# Compile and require test utils
Code.require_file("utils/cve_json.ex", __DIR__)
