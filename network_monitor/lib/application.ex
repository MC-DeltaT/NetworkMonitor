defmodule NetworkMonitor.Application do
    alias NetworkMonitor.Config, as: AppConfig
    alias NetworkMonitor.StatusLogging

    use Application


    @impl Application
    def start(_type, _args) do
        children = [
            NetworkMonitor.Scheduler,
            NetworkMonitor.JobSetup
        ]
        opts = [
            strategy: :one_for_one,
            name: NetworkMonitor.Supervisor
        ]

        with {:config, :ok} <- {:config, AppConfig.load_runtime_config(AppConfig.runtime_config_file())},
             {:init_log, :ok} <- {:init_log, StatusLogging.init_log_file!(AppConfig.log_file_path())} do
            Supervisor.start_link(children, opts)
        else
            {:config, {:error, reason}} ->
                IO.puts(:stderr, "Configuration error:\n  #{Exception.message(reason)}")
                System.stop(1)
            {:init_log, {:error, reason}} ->
                IO.puts(:stderr, "Error initialising log file:\n  #{Exception.message(reason)}")
                System.stop(1)
        end
    end
end
