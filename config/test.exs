import Config

# Disable Mix.PubSub in tests to avoid socket permission errors under certain environments
config :mix, :pubsub, false
