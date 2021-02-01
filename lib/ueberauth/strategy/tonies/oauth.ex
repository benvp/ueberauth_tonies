defmodule Ueberauth.Strategy.Tonies.OAuth do
  @moduledoc """
  OpenID connect for Tonies.
  Relies on password flow because this is an inofficial api and there
  are no apps which could be registered on tonies.com

  No configuration required.
  """

  @defaults [
    client_id: "my-tonies",
    site: "https://api.tonie.cloud/v2",
    token_url: "https://login.tonies.com/auth/realms/tonies/protocol/openid-connect/token"
  ]

  @doc """
  Construct a clinet for requests to Tonies.

  This will be setup automatically for you in `Ueberauth.Strategy.Tonies`.
  """
  def client(opts \\ []) do
    opts =
      @defaults
      |> Keyword.merge(opts)
      |> Keyword.merge(
        strategy: OAuth2.Strategy.Password,
        serializers: %{"application/json" => Ueberauth.json_library()}
      )

    OAuth2.Client.new(opts)
  end

  def get_token(client, params) do
    client
    |> OAuth2.Client.get_token(params)
    |> case do
      {:ok, token} -> {:ok, Map.get(token, :token)}
      other -> other
    end
  end

  def get(token, url, header \\ [], opts \\ []) do
    [token: token]
    |> client()
    |> OAuth2.Client.get(url, header, opts)
  end
end
