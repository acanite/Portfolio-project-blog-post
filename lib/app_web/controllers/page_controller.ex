defmodule AppWeb.PageController do
  use AppWeb, :controller

  def index(conn, _params) do
    url_oauth_google = ElixirAuthGoogle.generate_oauth_url()
    IO.inspect(url_oauth_google)
    render(conn, "index.html", url_oauth_google: url_oauth_google)
  end
end
