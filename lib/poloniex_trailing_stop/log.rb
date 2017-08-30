require 'logger'

module PoloniexTrailingStop
  module Log
    extend self

    def loggers
      @loggers ||= [
        Logger.new('./script.log', 10, from_megabytes(50)),
        Logger.new(STDOUT),
      ]
    end

    def log(type, msg)
      loggers.each do |logger|
        logger.public_send(type, msg)
      end
    end

    def level=(level)
      loggers.each do |logger|
        logger.level = level
      end
    end

    private
    def from_megabytes(amount)
      amount * 1024 * 1024
    end
  end
end
