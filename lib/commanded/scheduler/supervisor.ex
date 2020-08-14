defmodule Commanded.Scheduler.Supervisor do
    @moduledoc false
  
    use Supervisor
  
    def start_link(_) do
      Supervisor.start_link(__MODULE__, :ok)
    end
  
    def init(:ok) do
      children = [
        {Task.Supervisor, [name: Commanded.Scheduler.JobRunner]},
        Commanded.Scheduler.Repo,
        Commanded.Scheduler.JobSupervisor,
        Commanded.Scheduler.Jobs,
        Commanded.Scheduler.Projection,
        Commanded.Scheduler.Scheduling
      ]
  
      Supervisor.init(children, strategy: :one_for_one)
    end
  end