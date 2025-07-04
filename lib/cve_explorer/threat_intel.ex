defmodule CveExplorer.ThreatIntel do
  @moduledoc """
  The ThreatIntel context.
  """

  import Ecto.Query, warn: false
  alias CveExplorer.Repo

  alias CveExplorer.ThreatIntel.CVE

  @doc """
  Returns the list of cves.

  ## Examples

      iex> list_cves()
      [%CVE{}, ...]

  """
  def list_cves do
    CVE
    |> order_by(desc: :date_published)
    |> Repo.all()
  end

  @doc """
  Gets a single cve.

  Raises `Ecto.NoResultsError` if the Cve does not exist.

  ## Examples

      iex> get_cve!(123)
      %CVE{}

      iex> get_cve!(456)
      ** (Ecto.NoResultsError)

  """
  def get_cve!(id), do: Repo.get!(CVE, id)

  @doc """
  Gets a single cve by its cve_id.
  Raises `Ecto.NoResultsError` if the Cve does not exist.
  ## Examples

      iex> get_cve_by_cve_id("CVE-2021-12345")
      {:ok, %CVE{}}

      iex> get_cve_by_cve_id("CVE-2021-99999")
      {:error, :not_found}

  """
  def get_cve_by_cve_id(cve_id) do
    case Repo.get_by(CVE, cve_id: cve_id) do
      nil -> {:error, :not_found}
      cve -> {:ok, cve}
    end
  end

  @doc """
  Creates a cve.

  ## Examples

      iex> create_cve(%{field: value})
      {:ok, %CVE{}}

      iex> create_cve(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_cve(attrs \\ %{}) do
    %CVE{}
    |> CVE.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a cve.

  ## Examples

      iex> update_cve(cve, %{field: new_value})
      {:ok, %CVE{}}

      iex> update_cve(cve, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_cve(%CVE{} = cve, attrs) do
    cve
    |> CVE.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a cve.

  ## Examples

      iex> delete_cve(cve)
      {:ok, %CVE{}}

      iex> delete_cve(cve)
      {:error, %Ecto.Changeset{}}

  """
  def delete_cve(%CVE{} = cve) do
    Repo.delete(cve)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking cve changes.

  ## Examples

      iex> change_cve(cve)
      %Ecto.Changeset{data: %CVE{}}

  """
  def change_cve(%CVE{} = cve, attrs \\ %{}) do
    CVE.changeset(cve, attrs)
  end
end
