require 'spec_helper'
require 'fileutils'

module PoloniexTrailingStop
  RSpec.describe "simulations" do
    before :each do
      stub_const("PoloniexTrailingStop::Monitor::COINS_FILE", "./spec/coins_data.json")
      FileUtils.rm "./spec/coins_data.json" rescue nil
      stub_request(:post, "https://poloniex.com/tradingApi")
        .with(:body => /command=returnCompleteBalances&nonce=\d+/)
        .to_return(body: JSON.dump({"XRP" => {"available" => "1.00000000"}}))
    end

    it "sell when coin decreases more than the trailing stop delta" do
      allow(Settings).to receive(:trailing_stop_deltas)
        .and_return("XRP" => 0.05)

      sell = stub_sell(coin: "XRP", rate: 0.05*0.998, amount: 1.0)
      stub_coin_values_over_time("XRP", [0.1, 0.05])

      Monitor.new.update_from_balances
      expect(sell).to_not have_been_requested

      Monitor.new.update_from_balances
      expect(sell).to have_been_requested
    end

    it "rises the trailing stop when coin increases" do
      allow(Settings).to receive(:trailing_stop_deltas)
        .and_return("XRP" => 0.05)

      sell = stub_sell(coin: "XRP", rate: 0.95*0.998, amount: 1.0)
      stub_coin_values_over_time("XRP", [0.1, 0.2, 0.3, 1.0, 0.95])

      Monitor.new.update_from_balances
      Monitor.new.update_from_balances
      Monitor.new.update_from_balances
      Monitor.new.update_from_balances
      expect(sell).to_not have_been_requested

      Monitor.new.update_from_balances
      expect(sell).to have_been_requested
    end

    it "does not sell if decreases less than trailing stop delta" do
      allow(Settings).to receive(:trailing_stop_deltas)
        .and_return("XRP" => 0.05)

      sell = stub_sell(coin: "XRP", rate: 0.05*0.998, amount: 1.0)
      stub_coin_values_over_time("XRP", [0.1, 0.09, 0.08, 0.06, 0.05])

      Monitor.new.update_from_balances
      Monitor.new.update_from_balances
      Monitor.new.update_from_balances
      Monitor.new.update_from_balances
      expect(sell).to_not have_been_requested

      Monitor.new.update_from_balances
      expect(sell).to have_been_requested
    end
  end
end
