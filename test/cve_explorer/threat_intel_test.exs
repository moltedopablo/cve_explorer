defmodule CveExplorer.ThreatIntelTest do
  use CveExplorer.DataCase

  alias CveExplorer.ThreatIntel

  describe "cves" do
    alias CveExplorer.ThreatIntel.CVE

    import CveExplorer.ThreatIntelFixtures

    @invalid_attrs %{
      description: nil,
      cve_id: nil,
      date_published: nil,
      date_updated: nil,
      raw_json: nil
    }

    @valid_attrs %{
      "cve_id" => "CVE-2025-12345",
      "date_published" => "2025-07-02 15:24:00Z",
      "date_updated" => "2025-07-02 15:24:00Z",
      "description" => "Some description of the vulnerability.",
      "raw_json" => %{
        "containers" => %{
          "cna" => %{
            "descriptions" => [
              %{"lang" => "en", "value" => "Some description of the vulnerability."}
            ]
          }
        },
        "cveMetadata" => %{
          "cveId" => "CVE-2025-12345",
          "datePublished" => "2025-07-02 15:24:00Z",
          "dateUpdated" => "2025-07-02 15:24:00Z"
        }
      }
    }
    test "list_cves/0 returns all cves" do
      cve = cve_fixture()
      assert ThreatIntel.list_cves() == [cve]
    end

    test "get_cve!/1 returns the cve with given id" do
      cve = cve_fixture()
      assert ThreatIntel.get_cve!(cve.id) == cve
    end

    test "create_cve/1 with valid data creates a cve" do
      assert {:ok, %CVE{} = cve} = ThreatIntel.create_cve(@valid_attrs)
      assert cve.description == "Some description of the vulnerability."
      assert cve.cve_id == "CVE-2025-12345"
      assert cve.date_published == ~U[2025-07-02 15:24:00Z]
      assert cve.date_updated == ~U[2025-07-02 15:24:00Z]
      assert cve.raw_json == @valid_attrs["raw_json"]
    end

    test "create_cve/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = ThreatIntel.create_cve(@invalid_attrs)
    end

    test "get_cve_by_cve_id/1 returns cve when found" do
      cve = cve_fixture()
      assert {:ok, returned_cve} = ThreatIntel.get_cve_by_cve_id(cve.cve_id)
      assert returned_cve.id == cve.id
      assert returned_cve.cve_id == cve.cve_id
    end

    test "get_cve_by_cve_id/1 returns error when not found" do
      assert {:error, :not_found} = ThreatIntel.get_cve_by_cve_id("CVE-2025-99999")
    end

    test "list_cves/0 returns cves ordered by date_published desc" do
      # Create CVEs with different published dates
      older_cve =
        cve_fixture(%{
          cve_id: "CVE-2025-11111",
          date_published: ~U[2025-07-01 10:00:00Z]
        })

      newer_cve =
        cve_fixture(%{
          cve_id: "CVE-2025-22222",
          date_published: ~U[2025-07-03 10:00:00Z]
        })

      cves = ThreatIntel.list_cves()
      assert length(cves) == 2
      [first, second] = cves
      assert first.id == newer_cve.id
      assert second.id == older_cve.id
    end

    test "create_cve/1 with invalid cve_id format returns error changeset" do
      invalid_cve_ids = [
        # year too short
        "CVE-25-1234",
        # number too short
        "CVE-2025-123",
        # number too long
        "CVE-2025-12345678901234567890",
        # lowercase
        "cve-2025-1234",
        # missing number
        "CVE-2025-",
        # missing dash and number
        "CVE-2025",
        # missing CVE prefix
        "2025-1234",
        # non-numeric
        "CVE-2025-ABC"
      ]

      for invalid_id <- invalid_cve_ids do
        attrs = Map.put(@valid_attrs, "cve_id", invalid_id)
        assert {:error, %Ecto.Changeset{} = changeset} = ThreatIntel.create_cve(attrs)

        assert {"has invalid format", _} = changeset.errors[:cve_id]
      end
    end

    test "create_cve/1 with empty cve_id returns error changeset" do
      attrs = Map.put(@valid_attrs, "cve_id", "")
      assert {:error, %Ecto.Changeset{} = changeset} = ThreatIntel.create_cve(attrs)
      assert {"can't be blank", _} = changeset.errors[:cve_id]
    end

    test "create_cve/1 with duplicate cve_id returns error changeset" do
      # Create first CVE
      assert {:ok, _cve} = ThreatIntel.create_cve(@valid_attrs)

      # Try to create another with same cve_id
      assert {:error, %Ecto.Changeset{} = changeset} = ThreatIntel.create_cve(@valid_attrs)
      assert {"has already been taken", _} = changeset.errors[:cve_id]
    end

    test "create_cve/1 with missing cve_id returns error changeset" do
      attrs = Map.delete(@valid_attrs, "cve_id")
      assert {:error, %Ecto.Changeset{} = changeset} = ThreatIntel.create_cve(attrs)
      assert {"can't be blank", _} = changeset.errors[:cve_id]
    end

    test "create_cve/1 with missing description returns error changeset" do
      attrs = Map.delete(@valid_attrs, "description")
      assert {:error, %Ecto.Changeset{} = changeset} = ThreatIntel.create_cve(attrs)
      assert {"can't be blank", _} = changeset.errors[:description]
    end

    test "create_cve/1 with missing date_published returns error changeset" do
      attrs = Map.delete(@valid_attrs, "date_published")
      assert {:error, %Ecto.Changeset{} = changeset} = ThreatIntel.create_cve(attrs)
      assert {"can't be blank", _} = changeset.errors[:date_published]
    end

    test "create_cve/1 with missing date_updated returns error changeset" do
      attrs = Map.delete(@valid_attrs, "date_updated")
      assert {:error, %Ecto.Changeset{} = changeset} = ThreatIntel.create_cve(attrs)
      assert {"can't be blank", _} = changeset.errors[:date_updated]
    end

    test "create_cve/1 with missing raw_json returns error changeset" do
      attrs = Map.delete(@valid_attrs, "raw_json")
      assert {:error, %Ecto.Changeset{} = changeset} = ThreatIntel.create_cve(attrs)
      assert {"can't be blank", _} = changeset.errors[:raw_json]
    end

    test "create_cve/1 with valid edge case cve_id formats" do
      valid_cve_ids = [
        # minimum 4 digits
        "CVE-2025-1234",
        # maximum 19 digits
        "CVE-1999-1234567890123456789"
      ]

      for valid_id <- valid_cve_ids do
        attrs =
          @valid_attrs
          |> Map.put("cve_id", valid_id)
          |> Map.put("description", "Some description")

        assert {:ok, %CVE{} = cve} = ThreatIntel.create_cve(attrs)
        assert cve.cve_id == valid_id
      end
    end
  end
end
