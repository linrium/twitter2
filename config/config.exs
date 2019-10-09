# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :twitter2, Twitter2.Guardian,
  issuer: "twitter2",
  secret_key: "OXb/zRcs1HkTHfxyiu4Lj6vZjcI46z0mAt3Tq+2bWyvhMRIIgkUVLkkrb7RousuI"

config :guardian, Guardian.DB,
  # Add your repository module
  repo: Twitter2.Repo,
  # default
  schema_name: "guardian_tokens",
  # default: 60 minutes
  sweep_interval: 120

config :twitter2,
  ecto_repos: [Twitter2.Repo]

# Configures the endpoint
config :twitter2, Twitter2Web.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "D68lqFb6IArHnNXIE1D6Wcdp1C3TKloXzkcvWguhQIIBwk7NpHeCVBWDiZ2whjp9",
  render_errors: [view: Twitter2Web.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Twitter2.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
