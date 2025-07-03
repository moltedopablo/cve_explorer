defmodule CveExplorer.ThreatIntelTest do
  use CveExplorer.DataCase

  alias CveExplorer.ThreatIntel

  describe "cves" do
    alias CveExplorer.ThreatIntel.CVE

    import CveExplorer.ThreatIntelFixtures

    @invalid_attrs %{description: nil, cve_id: nil, date_published: nil, date_updated: nil, raw_json: nil}

    test "list_cves/0 returns all cves" do
      cve = cve_fixture()
      assert ThreatIntel.list_cves() == [cve]
    end

    test "get_cve!/1 returns the cve with given id" do
      cve = cve_fixture()
      assert ThreatIntel.get_cve!(cve.id) == cve
    end

    test "create_cve/1 with valid data creates a cve" do
      valid_attrs = %{description: "some description", cve_id: "some cve_id", date_published: ~U[2025-07-02 15:24:00Z], date_updated: ~U[2025-07-02 15:24:00Z], raw_json: %{}}

      assert {:ok, %CVE{} = cve} = ThreatIntel.create_cve(valid_attrs)
      assert cve.description == "some description"
      assert cve.cve_id == "some cve_id"
      assert cve.date_published == ~U[2025-07-02 15:24:00Z]
      assert cve.date_updated == ~U[2025-07-02 15:24:00Z]
      assert cve.raw_json == %{}
    end

    test "create_cve/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = ThreatIntel.create_cve(@invalid_attrs)
    end

    test "update_cve/2 with valid data updates the cve" do
      cve = cve_fixture()
      update_attrs = %{description: "some updated description", cve_id: "some updated cve_id", date_published: ~U[2025-07-03 15:24:00Z], date_updated: ~U[2025-07-03 15:24:00Z], raw_json: %{}}

      assert {:ok, %CVE{} = cve} = ThreatIntel.update_cve(cve, update_attrs)
      assert cve.description == "some updated description"
      assert cve.cve_id == "some updated cve_id"
      assert cve.date_published == ~U[2025-07-03 15:24:00Z]
      assert cve.date_updated == ~U[2025-07-03 15:24:00Z]
      assert cve.raw_json == %{}
    end

    test "update_cve/2 with invalid data returns error changeset" do
      cve = cve_fixture()
      assert {:error, %Ecto.Changeset{}} = ThreatIntel.update_cve(cve, @invalid_attrs)
      assert cve == ThreatIntel.get_cve!(cve.id)
    end

    test "delete_cve/1 deletes the cve" do
      cve = cve_fixture()
      assert {:ok, %CVE{}} = ThreatIntel.delete_cve(cve)
      assert_raise Ecto.NoResultsError, fn -> ThreatIntel.get_cve!(cve.id) end
    end

    test "change_cve/1 returns a cve changeset" do
      cve = cve_fixture()
      assert %Ecto.Changeset{} = ThreatIntel.change_cve(cve)
    end
  end
end
