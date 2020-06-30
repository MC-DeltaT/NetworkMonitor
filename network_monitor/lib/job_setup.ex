defmodule NetworkMonitor.JobSetup do
    alias NetworkMonitor.Config, as: AppConfig
    alias NetworkMonitor.Scheduler
    alias NetworkMonitor.StatusLogging

    require Logger


    def child_spec(_opts) do
        %{
            id: __MODULE__,
            start: {__MODULE__, :start_link, []},
            restart: :transient
        }
    end

    @spec start_link() :: {:ok, pid()}
    def start_link() do
        {:ok, spawn_link(&add_jobs/0)}
    end

    @spec add_jobs() :: :ok
    defp add_jobs() do
        Logger.info("Adding jobs to scheduler.")

        jobs = [
            log_network_status_job()
        ]

        Enum.each(jobs, fn job ->
            Scheduler.add_job(job)
        end)
    end

    @spec log_network_status_job() :: Quantum.Job.t()
    def log_network_status_job() do
        Scheduler.new_job()
        |> Quantum.Job.set_name(:log_network_status)
        |> Quantum.Job.set_schedule(AppConfig.log_schedule())
        |> Quantum.Job.set_task({StatusLogging, :log_network_status!, [AppConfig.log_file_path()]})
    end
end
