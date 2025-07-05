defmodule CveExplorerWeb.Test.Utils.CVEJSON do
  @moduledoc """
  CVE JSON samples for testing purposes.
  """

  @doc """
  Returns a valid sample CVE JSON string
  """
  def valid do
    """
    {
      "containers": {
        "cna": {
          "descriptions": [
            {
              "lang": "en",
              "value": "Some description of the vulnerability."
            }
          ]
        }
      },
      "cveMetadata": {
        "cveId": "CVE-2025-12345",
        "dateUpdated": "2025-07-02 15:24:00Z",
        "datePublished": "2025-07-02 15:24:00Z"
      }
    }
    """
  end

  def invalid_json_format do
    "{{}"
  end

  @doc """
  Returns a CVE JSON string missing the cve_id field
  """
  def missing_cve_id do
    """
    {
      "containers": {
        "cna": {
          "descriptions": [
            {
              "lang": "en",
              "value": "Some description of the vulnerability."
            }
          ]
        }
      },
      "cveMetadata": {
        "dateUpdated": "2025-07-02 15:24:00Z",
        "datePublished": "2025-07-02 15:24:00Z"
      }
    }
    """
  end

  @doc """
  Returns a CVE JSON string missing the datePublished field
  """
  def missing_date_published do
    """
    {
      "containers": {
        "cna": {
          "descriptions": [
            {
              "lang": "en",
              "value": "Some description of the vulnerability."
            }
          ]
        }
      },
      "cveMetadata": {
        "cveId": "CVE-2025-12345",
        "dateUpdated": "2025-07-02 15:24:00Z"
      }
    }
    """
  end

  @doc """
  Returns a CVE JSON string missing the dateUpdated field
  """
  def missing_date_updated do
    """
    {
      "containers": {
        "cna": {
          "descriptions": [
            {
              "lang": "en",
              "value": "Some description of the vulnerability."
            }
          ]
        }
      },
      "cveMetadata": {
        "cveId": "CVE-2025-12345",
        "datePublished": "2025-07-02 15:24:00Z"
      }
    }
    """
  end

  @doc """
  Returns a CVE JSON string missing the description field
  """
  def missing_description do
    """
    {
      "containers": {
        "cna": {
        }
      },
      "cveMetadata": {
        "cveId": "CVE-2025-12345",
        "dateUpdated": "2025-07-02 15:24:00Z",
        "datePublished": "2025-07-02 15:24:00Z"
      }
    }
    """
  end

  @doc """
  Returns a CVE JSON string with multiple missing fields
  """
  def multiple_missing_fields do
    """
    {
      "containers": {
        "cna": {
        }
      },
      "cveMetadata": {
        "dateUpdated": "2025-07-02 15:24:00Z"
      }
    }
    """
  end
end
