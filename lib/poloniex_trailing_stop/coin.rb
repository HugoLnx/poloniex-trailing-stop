module PoloniexTrailingStop
  class Coin
    attr_reader :name, :price, :trailing_stop_delta, :max_high, :amount

    def initialize(name: , price: , trailing_stop_delta: , max_high: , amount: )
      @name = name
      @price = price
      @trailing_stop_delta = trailing_stop_delta
      @max_high = max_high
      @amount = amount
    end

    def should_be_sold?
      trailing_stop = @max_high - @trailing_stop_delta
      Log.log :debug, @name
      Log.log :debug, "Trailing stop: #{trailing_stop}"
      Log.log :debug, "Price: #{@price}"
      Log.log :debug, "Amount: #{@amount}"
      Log.log :debug, "\n"
      @price <= trailing_stop
    end

    def sell_order_value
      @price * 0.998
    end
  end
end
