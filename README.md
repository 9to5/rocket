# Rocket

Rocket is an Elixir client for Firebase Cloud Messaging HTTP v1.

The current maintenance focus is test coverage, correctness, and modernization. New features are intentionally deferred until the cleanup baseline is stable.

## Requirements

- Elixir 1.18.x
- Erlang/OTP 26.2.x

The local toolchain is documented in `.tool-versions`.

## Installation

Add Rocket to your dependencies:

```elixir
def deps do
  [
    {:rocket, "~> 0.1"}
  ]
end
```

## Configuration

Rocket expects Google service-account credentials as JSON. The default configuration reads credentials from the `GCP_CREDENTIALS` environment variable:

```sh
export GCP_CREDENTIALS='{"project_id":"my-project", "...":"..."}'
```

The default response handler logs request outcomes:

```elixir
config :rocket,
  response_handler: Rocket.Response.DefaultHandler,
  workers: 2
```

Custom response handlers implement `Rocket.Response.ResponseHandler`.

## Usage

`Rocket.push/1` performs a synchronous FCM request and returns a structured result:

```elixir
payload = %{
  "message" => %{
    "token" => "device-token",
    "notification" => %{
      "title" => "Hello",
      "body" => "World"
    }
  }
}

Rocket.push(payload)
```

Successful responses return `{:ok, decoded_body}`. Request, configuration, encoding, HTTP, and FCM errors return `{:error, reason}`.

The GenStage producer/consumer modules are used for queued internal processing. They are not the public boundary for new features unless that API is deliberately designed and documented.

## Development

Fetch dependencies:

```sh
mix deps.get
```

Run the verification suite:

```sh
mix format --check-formatted
mix compile --warnings-as-errors
mix deps.audit
mix credo --strict
mix test --cover
mix dialyzer --format short
```

Rocket defaults to Finch for HTTP requests and starts a supervised pool named `Rocket.Finch` when the default client is used. Finch is an optional dependency; applications that provide their own `:http_client` do not need to include it.

The coverage threshold is enforced by `mix test --cover` and is currently set to 90%.

## Release Notes

See `CHANGELOG.md`.
