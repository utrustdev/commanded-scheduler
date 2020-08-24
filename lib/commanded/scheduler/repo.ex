defmodule Commanded.Scheduler.Repo do
  @moduledoc false

  use Ecto.Repo,
    otp_app: :commanded_scheduler,
    adapter: Ecto.Adapters.Postgres
end
