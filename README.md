 # Rocket

 A Firebase Cloud Messaging HTTP v1 client for Elixir.

 ## Installation

 Add to your `mix.exs` dependencies:

 ```elixir
 defp deps do
   [
     {:rocket, "~> 0.0.1"}
   ]
 end
 ```

 Fetch dependencies:

 ```bash
 mix deps.get
 ```

 ## Configuration

 Rocket uses [Goth](https://hexdocs.pm/goth) for authentication. Provide your GCP JSON credentials via the `GCP_CREDENTIALS` environment variable,
 or configure it in `config/config.exs`:

 ```elixir
 config :rocket,
   json: File.read!("path/to/credentials.json")
 ```

 ## Usage

 Build an FCM v1 payload and dispatch:

 ```elixir
 payload = %{
   message: %{
     token: "user_device_token",
     notification: %{title: "Hello", body: "World"},
     data: %{custom_key: "value"}
   }
 }

 {:ok, response_body} = Rocket.push(payload)
 ```

 Rocket also provides a GenStage-based producer/consumer setup. For background or batch dispatch,
 add `Rocket.PushCollector` to your supervision tree and dispatch events via `Rocket.PushCollector.push/1`:

 ```elixir
 # in your application supervisor
 children = [
   Rocket.PushCollector
 ]

 # elsewhere in your code
 Rocket.PushCollector.push(payload)
 ```

 ## Testing

 Run the test suite with:

 ```bash
 mix test
 ```

 ## Contributing

 1. Fork the repository
 2. Create a feature branch (`git checkout -b my-feature`)
 3. Commit your changes (`git commit -am 'Add feature'`)
 4. Push to your branch (`git push origin my-feature`)
 5. Open a pull request

 ## License

 MIT
