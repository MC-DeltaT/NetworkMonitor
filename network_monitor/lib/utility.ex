defmodule NetworkMonitor.Utility do
    @spec ipv4_address_to_string(:inet.ip4_address()) :: String.t()
    def ipv4_address_to_string({o1, o2, o3, o4}) do
        "#{o1}.#{o2}.#{o3}.#{o4}"
    end
end
