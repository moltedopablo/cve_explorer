defmodule CveExplorer.CVEParserTest do
  use CveExplorer.DataCase
  alias CveExplorerWeb.Test.Utils.CVEJSON
  alias CveExplorer.CVEParser

  describe "cves" do
    test "parse_cve/1 returns ok with valid json" do
      valid = CVEJSON.valid()
      expected_raw_json = Jason.decode!(valid)

      assert {:ok,
              %{
                "cve_id" => "CVE-2025-12345",
                "date_published" => "2025-07-02 15:24:00Z",
                "date_updated" => "2025-07-02 15:24:00Z",
                "description" => "Some description of the vulnerability.",
                "raw_json" => ^expected_raw_json
              }} = CVEParser.parse_cve(valid)
    end

    test "parse_cve/1 returns error if json format is invalid" do
      assert {:error, %Jason.DecodeError{}} = CVEParser.parse_cve(CVEJSON.invalid_json_format())
    end

    test "parse_cve/1 returns error when cve_id is missing" do
      assert {:error, ["Missing cveId"]} = CVEParser.parse_cve(CVEJSON.missing_cve_id())
    end

    test "parse_cve/1 returns error when date_published is missing" do
      assert {:error, ["Missing datePublished"]} =
               CVEParser.parse_cve(CVEJSON.missing_date_published())
    end

    test "parse_cve/1 returns error when date_updated is missing" do
      assert {:error, ["Missing dateUpdated"]} =
               CVEParser.parse_cve(CVEJSON.missing_date_updated())
    end

    test "parse_cve/1 returns error when description is missing" do
      assert {:error, ["Missing description"]} =
               CVEParser.parse_cve(CVEJSON.missing_description())
    end

    test "parse_cve/1 returns error with multiple missing fields" do
      result = CVEParser.parse_cve(CVEJSON.multiple_missing_fields())
      assert {:error, errors} = result
      assert length(errors) == 3
      assert "Missing cveId" in errors
      assert "Missing datePublished" in errors
      assert "Missing description" in errors
    end
  end
end
