defmodule CveExplorerWeb.ErrorJSONTest do
  use CveExplorerWeb.ConnCase, async: true

  test "renders 404" do
    assert CveExplorerWeb.ErrorJSON.render("404.json", %{}) == %{errors: %{detail: "Not Found"}}
  end

  test "renders 500" do
    assert CveExplorerWeb.ErrorJSON.render("500.json", %{}) ==
             %{errors: %{detail: "Internal Server Error"}}
  end
end
