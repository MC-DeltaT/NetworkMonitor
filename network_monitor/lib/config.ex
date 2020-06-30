defmodule NetworkMonitor.Config do
    defmodule Error do
        defexception message: "Configuration error.", reason: nil

        @type t() :: %__MODULE__{
            message: String.t(),
            reason: term()
        }
    end


    alias NetworkMonitor.Utility

    require Logger


    @spec env() :: :mix | :release
    def env() do
        Application.fetch_env!(:network_monitor, :env)
    end

    @spec runtime_config_file() :: String.t()
    def runtime_config_file() do
        if env() === :release do
            Path.join([System.get_env("RELEASE_ROOT"), "config.json"])
        else
            Path.absname("config.json", File.cwd!)
        end
    end

    @spec load_runtime_config(Path.t()) :: :ok | {:error, Error.t()}
    def load_runtime_config(file_path) do
        file_path = Path.expand(file_path)
        Logger.info("Loading config from \"#{file_path}\"")
        with {:data, {:ok, data}} <- {:data, File.read(file_path)},
             {:json, {:ok, json}} <- {:json, Jason.decode(data)},
             {:config, {:ok, config}} <- {:config, parse_config(json, file_path)} do
            apply_config(config)
        else
            {:data, {:error, reason}} -> {:error, %Error{message: "Failed to read from config file \"#{file_path}\" : #{:file.format_error(reason)}", reason: reason}}
            {:json, {:error, reason}} -> {:error, %Error{message: "Config file is not valid JSON: #{Exception.message(reason)}", reason: reason}}
            {:config, {:error, reason}} -> {:error, reason}
        end
    end

    @spec log_schedule() :: Crontab.CronExpression.t()
    def log_schedule() do
        Application.fetch_env!(:network_monitor, :log_schedule)
    end

    @spec log_file_path() :: String.t()
    def log_file_path() do
        Application.fetch_env!(:network_monitor, :log_file_path)
    end

    @spec default_gateway() :: :inet.ip4_address()
    def default_gateway() do
        Application.fetch_env!(:network_monitor, :default_gateway)
    end

    @spec internet_check_host() :: {:inet.ip4_address(), :inet.port_number()}
    def internet_check_host() do
        Application.fetch_env!(:network_monitor, :internet_check_host)
    end


    defp apply_config(%{log_schedule: log_schedule, log_file_path: log_file_path, default_gateway: default_gateway}) do
        Application.put_env(:network_monitor, :log_schedule, log_schedule)
        Logger.info("Log schedule set to \"#{Crontab.CronExpression.Composer.compose(log_schedule)}\"")
        Application.put_env(:network_monitor, :log_file_path, log_file_path)
        Logger.info("Log file path set to \"#{log_file_path}\"")
        Application.put_env(:network_monitor, :default_gateway, default_gateway)
        Logger.info("Default gateway set to #{Utility.ipv4_address_to_string(default_gateway)}")
        :ok
    end

    @spec parse_config(map(), Path.t()) :: {:ok, map()} | {:error, Error.t()}
    defp parse_config(root, file_path) do
        with {:ok, log_schedule} <- get_field(root, "log_schedule") |> parse_log_schedule(),
             {:ok, log_file_path} <- get_field(root, "log_file_path") |> parse_log_file_path(file_path),
             {:ok, default_gateway} <- get_field(root, "default_gateway") |> parse_default_gateway() do
            {:ok, %{
                log_schedule: log_schedule,
                log_file_path: log_file_path,
                default_gateway: default_gateway
            }}
        else
            {:error, reason} -> {:error, reason}
        end
    end

    @spec parse_log_schedule(term()) :: {:ok, Crontab.CronExpression.t()} | {:error, Error.t()}
    def parse_log_schedule(value) do
        with {:present, true} <- {:present, value !== :not_present},
             {:type, true} <- {:type, is_binary(value)},
             {:parse, {:ok, crontab_expr}} <- {:parse, Crontab.CronExpression.Parser.parse(value)} do
            {:ok, crontab_expr}
        else
            {:present, false} -> {:error, %Error{message: "Missing required field log_schedule."}}
            {:type, false} -> {:error, %Error{message: "log_schedule is not a string."}}
            {:parse, {:error, reason}} -> {:error, %Error{message: "log_schedule is not a valid crontab expression.", reason: reason}}
        end
    end

    @spec parse_log_file_path(term(), Path.t()) :: {:ok, String.t()} | {:error, Error.t()}
    defp parse_log_file_path(value, config_file_path) do
        with {:present, true} <- {:present, value !== :not_present},
             {:type, true} <- {:type, is_binary(value)} do
            # If log file path is relative, make it relative to config file (otherwise leave it as-is).
            path = Path.absname(value, Path.dirname(config_file_path))
            {:ok, path}
        else
            {:present, false} -> {:error, %Error{message: "Missing required field log_file_path."}}
            {:type, false} -> {:error, %Error{message: "log_file_path is not a string."}}
        end
    end

    @spec parse_default_gateway(term()) :: {:ok, :inet.ip4_address()} | {:error, Error.t()}
    defp parse_default_gateway(value) do
        with {:present, true} <- {:present, value !== :not_present},
             {:type, true} <- {:type, is_binary(value)},
             {:parse, {:ok, ip}} <- {:parse, :inet.parse_ipv4_address(String.to_charlist(value))} do
            {:ok, ip}
        else
            {:present, false} -> {:error, %Error{message: "Missing required field default_gateway."}}
            {:type, false} -> {:error, %Error{message: "default_gateway is not a string."}}
            {:parse, {:error, :einval}} -> {:error, %Error{message: "default_gateway is not a valid IPv4 address."}}
        end
    end

    @spec get_field(map(), String.t()) :: term() | :not_present
    defp get_field(object, field) do
        Map.get(object, field, :not_present)
    end
end
