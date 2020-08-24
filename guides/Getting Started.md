# Getting started

## Installation

Commanded scheduler can be installed from hex as follows.

1. Add `commanded_scheduler` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:commanded_scheduler, "~> 0.2"}]
    end
    ```

2. Fetch mix dependencies:

    ```console
    mix deps.get
    ```

## Configuration

Commanded scheduler uses its own Ecto repo for persistence.

You must configure the database connection settings for the Ecto repo in the environment config files:

```elixir
# config/config.exs
config :commanded_scheduler, Commanded.Scheduler.Repo,
  adapter: Ecto.Adapters.Postgres,
  database: "commanded_scheduler_dev",
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  pool_size: 1
```

You can use an existing database for the Scheduler. It will create a table named `schedules` to store scheduled commands and a `projection_versions`, if not present, used for Commanded's read model projections.

OR Configure your own Repo, that can be configured dynamically

```
config :commanded_scheduler, repo: MyApp.Repo
```

And Add two migrations to your repo

```
    create table(:schedules, primary_key: false) do
      add :schedule_uuid, :text, primary_key: true
      add :name, :text, primary_key: true
      add :command, :map
      add :command_type, :text
      add :due_at, :naive_datetime
      add :schedule, :text

      timestamps()
    end
```
```
    create_if_not_exists table(:projection_versions, primary_key: false) do
      add :projection_name, :text, primary_key: true
      add :last_seen_event_number, :bigint

      timestamps()
    end
```


Configure the commanded app where you want to use the Scheduler

```
config :commanded_scheduler, application: MyApp
```

### Create Commanded scheduler database

Once configured, you can create and migrate the scheduler database using Ecto's mix tasks.

Specify the Commanded scheduler's Ecto repo for the mix tasks using the `--repo` or `-r` command line option:

```console
mix ecto.create --repo Commanded.Scheduler.Repo
mix ecto.migrate --repo Commanded.Scheduler.Repo
```

Alternatively, you can include `Commanded.Scheduler.Repo` in the `ecto_repos` config for your own application:

```elixir
# config/config.exs
config :my_app,
  ecto_repos: [
    MyApp.Repo,
    Commanded.Scheduler.Repo
  ]

config :my_app, Commanded.Scheduler.Repo,
  migration_source: "scheduler_schema_migrations"
```

You _must set_ the `migration_source` for the scheduler repo to a different table name from Ecto's default (`schema_migrations`) as shown above. This ensures that migrations for your own application's Ecto repo do not interfere with the Scheduler migrations when running `mix ecto.migrate`.

Then using Ecto's mix tasks will include the Commanded scheduler repository at the same time as your own app's:

```console
mix do ecto.create, ecto.migrate
```

To handle migrations in production (since mix is not accessible in a release) then you will need to add this as a release task.
```elixir
def migrate_database() do
 Ecto.Migrator.with_repo(Commanded.Scheduler.Repo, fn repo ->
   path = Ecto.Migrator.migrations_path(repo)
   Ecto.Migrator.run(repo, path, :up, [all: true])
 end)
end
```