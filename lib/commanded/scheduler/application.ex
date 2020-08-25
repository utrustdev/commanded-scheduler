defmodule Commanded.Scheduler.Application do
  @moduledoc false

  use Application

  @repo Application.get_env(:commanded_scheduler, :repo)

  def start(_type, _args) do
    children =
      [
        {Task.Supervisor, [name: Commanded.Scheduler.JobRunner]},
        Commanded.Scheduler.Repo,
        Commanded.Scheduler.JobSupervisor,
        Commanded.Scheduler.Jobs,
        Commanded.Scheduler.Projection,
        Commanded.Scheduler.Scheduling
      ] ++ add_repo_child(@repo)

    opts = [strategy: :one_for_one, name: Commanded.Scheduler.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp add_repo_child(nil), do: []
  defp add_repo_child(repo), do: [repo]
end
