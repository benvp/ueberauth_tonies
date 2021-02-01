defmodule Ueberauth.Strategy.Tonies do
  @moduledoc """
  Tonies strategy for Überauth.
  """

  use Ueberauth.Strategy,
    uid_field: :uuid,
    callback_methods: ["POST"]

  alias Ueberauth.Auth.{Info, Credentials, Extra}
  alias Ueberauth.Strategy.Tonies

  @doc """
  Handles the callback from the request controller.
  """
  def handle_callback!(
        %Plug.Conn{params: %{"username" => username, "password" => password}} = conn
      ) do
    case Tonies.OAuth.get_token(Tonies.OAuth.client(), username: username, password: password) do
      {:ok, token} ->
        fetch_user(conn, token)

      {:error, %OAuth2.Response{body: body}} ->
        set_errors!(conn, [
          error(
            body["error"],
            body["error_description"]
          )
        ])
    end
  end

  def handle_cleanup!(conn) do
    conn
    |> put_private(:tonies_user, nil)
    |> put_private(:tonies_token, nil)
  end

  def uid(conn) do
    uid_field =
      conn
      |> option(:uid_field)
      |> to_string

    conn.private.tonies_user[uid_field]
  end

  def credentials(conn) do
    token = conn.private.tonies_token
    scopes = token.other_params["scope"] || ""
    scopes = String.split(scopes, " ")

    %Credentials{
      token: token.access_token,
      refresh_token: token.refresh_token,
      expires_at: token.expires_at,
      token_type: token.token_type,
      expires: !!token.expires_at,
      scopes: scopes,
      other: %{
        refresh_expires_in: token.other_params["refresh_expires_in"],
        not_before_policy: token.other_params["not_before_policy"],
        session_state: token.other_params["session_state"]
      }
    }
  end

  def info(conn) do
    user = conn.private.tonies_user

    %Info{
      first_name: user["firstName"],
      last_name: user["lastName"],
      name: user["firstName"] <> " " <> user["lastName"],
      nickname: user["uuid"],
      email: user["email"],
      image: user["profileImage"],
      location: user["region"]
    }
  end

  def extra(conn) do
    %Extra{
      raw_info: %{
        token: conn.private.tonies_token,
        user: conn.private.tonies_user
      }
    }
  end

  defp option(conn, key) do
    Keyword.get(options(conn), key, Keyword.get(default_options(), key))
  end

  defp fetch_user(conn, token) do
    conn = put_private(conn, :tonies_token, token)

    case Tonies.OAuth.get(token, "/me") do
      {:ok, %OAuth2.Response{status_code: 400, body: _body}} ->
        set_errors!(conn, [error("OAuth2", "400 - bad request")])

      {:ok, %OAuth2.Response{status_code: 404, body: _body}} ->
        set_errors!(conn, [error("OAuth2", "404 - not found")])

      {:ok, %OAuth2.Response{status_code: 401, body: _body}} ->
        set_errors!(conn, [error("token", "unauthorized")])

      {:ok, %OAuth2.Response{status_code: status_code, body: user}}
      when status_code in 200..399 ->
        put_private(conn, :tonies_user, user)

      {:error, %OAuth2.Error{reason: reason}} ->
        set_errors!(conn, [error("OAuth2", reason)])
    end
  end
end
