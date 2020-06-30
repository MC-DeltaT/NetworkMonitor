defmodule NetworkMonitor.StatusLogging do
    defmodule Error do
        defexception message: "Logging error.", reason: nil

        @type t() :: %__MODULE__{
            message: String.t(),
            reason: term()
        }
    end


    alias NetworkMonitor.NetworkStatus


    @log_header "Time,Localhost,Default gateway,Internet"


    @spec log_network_status(Path.t()) :: :ok | {:error, Error.t()}
    def log_network_status(file_path) do
        log_line = create_status_log() <> "\n"
        case File.write(file_path, log_line, [:append, :utf8]) do
            :ok -> :ok
            {:error, reason} -> {:error, %Error{message: "Failed to write to log file \"#{file_path}\": #{:file.format_error(reason)}", reason: reason}}
        end
    end

    @spec log_network_status!(Path.t()) :: :ok
    def log_network_status!(file_path) do
        case log_network_status(file_path) do
            :ok -> :ok
            {:error, reason} -> raise reason
        end
    end

    @spec init_log_file(Path.t()) :: :ok | {:error, Error.t()}
    def init_log_file(file_path) do
        case File.open(file_path, [:exclusive, :utf8]) do
            {:ok, file} ->
                IO.write(file, @log_header <> "\n")
                File.close(file)
                :ok
            {:error, :eexist} -> :ok
            {:error, reason} -> {:error, %Error{message: "Failed to write to log file \"#{file_path}\": #{:file.format_error(reason)}"}}
        end
    end

    @spec init_log_file!(Path.t()) :: :ok
    def init_log_file!(file_path) do
        case init_log_file(file_path) do
            :ok -> :ok
            {:error, reason} -> raise reason
        end
    end


    @spec create_status_log() :: String.t()
    defp create_status_log() do
        format_bool = fn b ->
            if b do
                "T"
            else
                "F"
            end
        end

        time = DateTime.utc_now()
        localhost_status = NetworkStatus.localhost_status()
        default_gateway_status = NetworkStatus.default_gateway_status()
        internet_status = NetworkStatus.internet_status()
        "#{DateTime.to_string(time)},#{format_bool.(localhost_status)},#{format_bool.(default_gateway_status)},#{format_bool.(internet_status)}"
    end
end
