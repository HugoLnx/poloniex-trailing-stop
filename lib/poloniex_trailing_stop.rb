require "bundler/setup"
require 'benchmark'
require 'json'
require 'yaml'

require 'openssl'
require 'rest_client'
require 'addressable/uri'

require './lib/poloniex_trailing_stop/monitor'
require './lib/poloniex_trailing_stop/coin'
require './lib/poloniex_trailing_stop/settings'
require './lib/poloniex_trailing_stop/poloniex_api'
require './lib/poloniex_trailing_stop/log'

module PoloniexTrailingStop
  def self.start
    Log.log :info, "Starting at: #{DateTime.now}"
    monitor = Monitor.new
    loop do
      deltatime = Benchmark.measure do
        monitor.update_from_balances
      end.real

      Log.log(:debug, "Time: #{deltatime}")

      sleep 1
    end
  end
end
