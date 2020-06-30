defmodule NetworkMonitor.MixProject do
    use Mix.Project


    def project() do
        [
            app: :network_monitor,
            version: "1.0.0",
            elixir: "~> 1.10",
            deps: deps(),
            start_permanent: Mix.env() === :prod,
            aliases: aliases()
        ]
    end

    def application() do
        [
            mod: {NetworkMonitor.Application, []},
            extra_applications: [:jason, :logger, :quantum]
        ]
    end


    defp deps() do
        [
            {:jason, "~> 1.2"},
            {:quantum, "~> 3.0"}
        ]
    end

    defp aliases() do
        [
            test: "test --no-start"
        ]
    end
end
