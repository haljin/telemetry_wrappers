# TelemetryWrappers
![Hex.pm](https://img.shields.io/hexpm/v/telemetry_wrappers.svg)
[![Build Status](https://travis-ci.org/haljin/telemetry_wrappers.svg?branch=master)](https://travis-ci.org/haljin/telemetry_wrappers)

Simple wrapper functions for Telemetry to make taking some metrics a bit easier.

## Function timing

 With Telemetry wrappers you can define a function that will have its execution time measured and sent as a `:telemetry` event. To use the wrappers simply include `use TelemetryWrappers` in your module

 You can then define a function using `deftimed` macro:

  ```elixir
      deftimed timed_function(a, b), [:a, :b] do
        a + b
      end
  ```

  This will define a `timed_function/2` function like you would expect from `def` but it will also emit a `:telemetry` event `[:a, :b]` with the contents `%{call: timing}` where `timing` is the time the function took to execute in microseconds.

  The metric name is optional and will default to `[:timing, name]` where `name` is the name of the function (without arity).

  If you would like to define a private function you can instead use `deftimedp`

  ```elixir
      deftimedp timed_priv_function(a, b), [:a, :b] do
        a + b
      end
  ```