defmodule Commanded.Scheduler.Repo do
  @moduledoc false

  use Ecto.Repo,
    otp_app: :commanded_scheduler,
    adapter: Ecto.Adapters.Postgres

  @repo_config Application.get_env(:commanded_scheduler, Commanded.Scheduler.Repo)
  @runtime_envs @repo_config[:runtime_envs] || []

  def init(_, opts) do
    changed_opts = resolve_runtime_envs(@runtime_envs)
    {:ok, Keyword.merge(opts, changed_opts)}
  end

  defp resolve_runtime_envs(runtime_envs) do
    Enum.reduce(runtime_envs, [], fn item, acc ->
      {opt, value} = get_env_var(item)

      Keyword.put(acc, opt, value)
    end)
  end

  defp get_env_var({:pool_size, name}) do
    {:pool_size, name |> System.get_env() |> String.to_integer()}
  end

  defp get_env_var({opt, name}) do
    {opt, System.get_env(name)}
  end
end
