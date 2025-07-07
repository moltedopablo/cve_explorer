defmodule CveExplorerWeb.Router do
  use CveExplorerWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {CveExplorerWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", CveExplorerWeb do
    pipe_through :browser

    live "/", CVELive.Index, :index
    live "/cves/new", CVELive.New, :new
    live "/cves/:id/edit", CVELive.Index, :edit
    live "/cves/:id", CVELive.Show, :show
    live "/cves/:id/show/edit", CVELive.Show, :edit
  end

  # Other scopes may use custom stacks.
  scope "/api", CveExplorerWeb do
    pipe_through :api
    get "/cves", APIController, :index
    get "/cves/:cve_id", APIController, :raw_json
  end

  scope "/api/swagger" do
    forward "/", PhoenixSwagger.Plug.SwaggerUI,
      otp_app: :cve_explorer,
      swagger_file: "swagger.json"
  end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:cve_explorer, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: CveExplorerWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  def swagger_info do
    %{
      info: %{
        version: "1.0",
        title: "CVE Explorer API",
        description: "API for exploring CVE (Common Vulnerabilities and Exposures) data"
      },
      basePath: "/"
    }
  end
end
