module PoloniexTrailingStop
  module Settings
    extend self

    CONFIG_FILE = "./settings.yml"

    def trailing_stop_deltas
      load["trailing_stop_deltas"]
    end

    def api_key
      load["api"]["key"]
    end

    def api_secret
      load["api"]["secret"]
    end

    def reset
      @settings = nil
    end

    private
    def load
      @settings ||= YAML.load_file(CONFIG_FILE)
    end
  end
end
