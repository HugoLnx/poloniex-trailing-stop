require './lib/poloniex_trailing_stop'
PoloniexTrailingStop::Log.level = :info

def start
  begin
    PoloniexTrailingStop.start
  rescue SignalException => e
    raise e
  rescue Exception => e
    start
  end
end

start
