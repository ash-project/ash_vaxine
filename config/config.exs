import Config

if config_env() == :test do
  config :ash_vaxine, ecto_repos: [AshVaxine.Test.Repo]

  config :ash_vaxine, AshVaxine.Test.Repo, address: "localhost", port: 8087, log: true
end
