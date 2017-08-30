module PoloniexTrailingStop
  class Monitor
    COINS_FILE = "./coins_data.json"

    def self.load
      if File.exists? COINS_FILE
        JSON.parse(File.read(COINS_FILE))
      else
        {}
      end
    end

    def initialize
      @saved_data = self.class.load
      @monitored_coins ||= []
    end

    def update_from_balances
      Settings.reset
      coins = all_coins
      coins.each do |coin|
        if coin.price.nil?
          Log.log(:warn, "Did not found balance for coin #{coin.name}")
        else
          if coin.should_be_sold?
            PoloniexAPI.sell(coin.name, coin.sell_order_value, coin.amount)
          end
        end
      end

      update_max_highs(coins)
    end

    def all_coins
      balances = PoloniexAPI.balances.reduce({}) do |balances, (coin_name, coin_data)|
        balances[coin_name] = {
          "price" => coin_data["btcValue"].to_f,
          "amount" => coin_data["available"].to_f,
        }
        balances
      end

      all_data(balances, PoloniexAPI.all_prices)
    end

    private

    def save
      File.open(COINS_FILE, "w") do |f|
        f.write JSON.dump(@saved_data)
      end
    end

    def update_max_highs(coins)
      coins.each do |coin|
        @saved_data[coin.name] ||= {}
        @saved_data[coin.name]["max_high"] = [@saved_data[coin.name]["max_high"].to_f, coin.price].max
      end
      save
    end

    def all_data(balances, prices)
      deltas = Settings.trailing_stop_deltas
      monitored_coins = deltas.keys & balances.keys
      log_monit_diff(monitored_coins)
      @monitored_coins = monitored_coins
      monitored_coins.map do |coin_name|
        balance = balances[coin_name]
        coin_saved_data = @saved_data[coin_name]
        Coin.new(
          name: coin_name,
          trailing_stop_delta: deltas[coin_name],
          max_high: (coin_saved_data && coin_saved_data["max_high"]).to_f,
          price: prices[coin_name].to_f,
          amount: (balance && balance["amount"]).to_f,
        )
      end
    end
    private
    def log_monit_diff(monitored_coins)
      new_coins = monitored_coins - @monitored_coins
      old_coins = @monitored_coins - monitored_coins
      Log.log(:info, "Start monitoring: #{new_coins.join(', ')}") unless new_coins.empty?
      Log.log(:info, "Stopped monitoring: #{old_coins.join(', ')}") unless old_coins.empty?
    end
  end
end
