# Poloniex Trailing Stop

## How it works
This bot will request your poloniex account every second to check if the price of a specific coin decreased more than your trailing stop delta. If the coin descreased that much, the bot will automatically create a sell order with 99.8% of the current value.

## Configuration
Put your API keys and the trailing stop deltas of each coin on `settings.yml`.

PS.: You can change the configuration during runtime, the script will reload the configuration automatically.

## Usage
```
$ bundle install
$ bundle exec ruby start.rb
```


## Run tests
```
$ bundle install
$ bundle exec rspec .
```
