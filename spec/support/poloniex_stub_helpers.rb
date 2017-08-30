module PoloniexStubHelpers
  def stub_sell(coin:, rate:, amount:)
    params = "command=sell&currencyPair=BTC_#{coin}&rate=%.10f&amount=%.10f" % [rate, amount]
    stub_request(:post, "https://poloniex.com/tradingApi")
      .with(:body => /#{params}&nonce=\d+/)
      .to_return(:status => 200, :body => "{}", :headers => {})
  end
  
  def stub_coin_values_over_time(coin_name, values)
    stub = stub_request(:get, "https://poloniex.com/public?command=returnTicker")
    values.reduce(stub) do |stub, value|
      stub.to_return(body: JSON.dump({
        "BTC_#{coin_name}" => {"last" => "%.10f" % value}
      })).then
    end
  end
end
