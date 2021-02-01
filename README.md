# Überauth Tonies

> Tonies strategy for Überauth

## Installation

 Add `:ueberauth_tonies` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:ueberauth_tonies, "~> 0.1.0"}
  ]
end
```

Add the strategy to your Überauth configuration:

```elixir
config :ueberauth, Ueberauth,
  providers: [
    tonies: {Ueberauth.Strategy.Tonies, []}
  ]
```

Include the Überauth plug in your controller:

```elixir
defmodule MyApp.AuthController do
  use MyApp.Web, :controller
  plug Ueberauth
  ...
end
```

Create the request and callback routes if you haven't already:

```elixir
scope "/auth", MyApp do
  pipe_through :browser

  get "/:provider", AuthController, :request
  get "/:provider/callback", AuthController, :callback
end
```

Implement a `request/2` callback within your controller and collect `username` and `password` via a form in the template.

```elixir
def request(conn, %{"provider" => "tonies"}) do
  conn
  |> render("tonies_auth.html", callback_url: Helpers.callback_url(conn))
end
```

Implement the `callback/2` controller functions and deal with `Ueberauth.Auth` and `Ueberauth.Failure` responses.
See the docs of Überauth on how to handle callbacks.
