defmodule NetworkMonitor.NetworkStatus do
    alias NetworkMonitor.Config, as: AppConfig
    alias NetworkMonitor.Utility


    @localhost_timeout 1            # seconds
    @default_gateway_timeout 1      # seconds
    @internet_timeout 2500          # milliseconds
    @internet_retries 2


    @spec localhost_status() :: boolean()
    def localhost_status() do
        {os_family, _os_name} = :os.type()
        localhost_status(os_family)
    end

    @spec default_gateway_status() :: boolean()
    def default_gateway_status() do
        {os_family, _os_name} = :os.type()
        default_gateway_status(os_family)
    end

    @spec internet_status() :: boolean()
    def internet_status() do
        {address, port} = AppConfig.internet_check_host()
        internet_status(address, port, @internet_retries)
    end


    defp localhost_status(:unix) do
        {_result, status} = System.cmd("ping", ["-c", "4", "-W", to_string(@localhost_timeout), "127.0.0.1"])
        status === 0
    end

    defp localhost_status(:win32) do
        {_result, status} = System.cmd("ping", ["-n", "4", "-w", to_string(@localhost_timeout), "127.0.0.1"])
        status === 0
    end

    defp default_gateway_status(:unix) do
        default_gateway_str = Utility.ipv4_address_to_string(AppConfig.default_gateway())
        {_result, status} = System.cmd("ping", ["-c", "4", "-W", to_string(@default_gateway_timeout), default_gateway_str])
        status === 0
    end

    defp default_gateway_status(:win32) do
        default_gateway_str = Utility.ipv4_address_to_string(AppConfig.default_gateway())
        {_result, status} = System.cmd("ping", ["-n", "4", "-w", to_string(@default_gateway_timeout), default_gateway_str])
        status === 0
    end

    @spec internet_status(:inet.ip4_address(), :inet.port_number(), non_neg_integer()) :: boolean()
    defp internet_status(address, port, retries) do
        case :gen_tcp.connect(address, port, [:inet], @internet_timeout) do
            {:ok, socket} ->
                :gen_tcp.close(socket)
                true
            {:error, _reason} ->
                if retries <= 0 do
                    false
                else
                    internet_status(address, port, retries - 1)
                end
        end
    end
end
