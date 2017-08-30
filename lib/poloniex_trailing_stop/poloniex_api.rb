module PoloniexTrailingStop
  module PoloniexAPI
    extend self

    TRADING_API = "https://poloniex.com/tradingApi"

    def balances
      post(command: "returnCompleteBalances")
        .find_all{|k, v| !v["available"].to_f.zero?}
        .reduce({}){|h,(k,v)| h[k] = v; h}
    end

    def sell(coin_name, price, amount)
      Log.log(:info, "Selling #{amount} of #{coin_name} for #{price}BTC")
      post(command: "sell", currencyPair: "BTC_#{coin_name}", rate: ("%.10f" % price), amount: ("%.10f" % amount))
    end

    def all_prices
      prices = JSON.parse RestClient.get("https://poloniex.com/public?command=returnTicker").body
      prices
        .find_all{|currency_pair, hash| currency_pair.split("_").include?("BTC")}
        .reduce({}){|h, (currency_pair, values)| h[(currency_pair.split("_") - ["BTC"]).first] = values["last"]; h}
    end

    private
    def post(params)
      nonce = (Time.now.to_f * 10000000).to_i
      params["nonce"] = nonce
      post_body = Addressable::URI.form_encode(params)
      sign = OpenSSL::HMAC.hexdigest("sha512", Settings.api_secret, post_body)
      headers = {Key: Settings.api_key, Sign: sign}
      request_details = "#{TRADING_API}?#{post_body} (#{headers.inspect})"

      begin
        r = RestClient.post(TRADING_API, post_body, headers)
        hash = JSON.parse(r.body)
        if hash.has_key?("error")
          log_error_response(r, request_details)
          {}
        else
          hash
        end
      rescue RestClient::ExceptionWithResponse => e
        log_error_response(e.response, request_details)
        {}
      rescue StandardError => e
        Log.log(:error, "An error ocurred when requesting #{request_details}: #{e.inspect}")
        {}
      end
    end

    def log_error_response(response, request_details)
      Log.log(:error, "Poloniex responded error for #{request_details}: [#{response.code}] #{response.body}")
    end
  end
end
