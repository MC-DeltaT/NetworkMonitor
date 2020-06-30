import Config


config :network_monitor,
    env: :mix,
    internet_check_host: {{8, 8, 8, 8}, 53}

import_config("#{Mix.env()}.exs")
