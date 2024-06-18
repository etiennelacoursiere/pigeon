defmodule PigeonWeb.Router do
  use PigeonWeb, :router

  import PigeonWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {PigeonWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  # Other scopes may use custom stacks.
  # scope "/api", PigeonWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:pigeon, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: PigeonWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  ## Authentication routes

  scope "/", PigeonWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    live_session :redirect_if_user_is_authenticated,
      on_mount: [{PigeonWeb.UserAuth, :redirect_if_user_is_authenticated}] do
      live "/users/register", Live.Users.Registration, :new
      live "/users/log_in", Live.Users.Login, :new
      live "/users/reset_password", Live.Users.ForgotPassword, :new
      live "/users/reset_password/:token", Live.Users.ResetPassword, :edit
    end

    post "/users/log_in", UserSessionController, :create
  end

  scope "/", PigeonWeb.Live do
    pipe_through [:browser, :require_authenticated_user]

    live_session :require_authenticated_user,
      on_mount: [{PigeonWeb.UserAuth, :ensure_authenticated}] do
      live "/users/settings", Users.Settings, :edit
      live "/users/settings/confirm_email/:token", Users.Settings, :confirm_email

      live "/", Monitors.Index
      live "/monitors", Monitors.Index
      live "/monitors/new", Monitors.Form, :new
      live "/monitors/:id/", Monitors.Show
      live "/monitors/:id/edit", Monitors.Form, :edit

      live "/incidents", Incidents.Index
      live "/incidents/:id", Incidents.Show
    end
  end

  scope "/", PigeonWeb do
    pipe_through [:browser]

    delete "/users/log_out", UserSessionController, :delete

    live_session :current_user,
      on_mount: [{PigeonWeb.UserAuth, :mount_current_user}] do
      live "/users/confirm/:token", Live.Users.Confirmation, :edit
      live "/users/confirm", Live.Users.ConfirmationInstructions, :new
    end
  end
end
