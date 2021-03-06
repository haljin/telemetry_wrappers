defmodule TelemetryWrappers.Support.TestModule do
  use TelemetryWrappers

  @spec timed_function(number(), number()) :: number()
  deftimed timed_function(a, b), [:a, :b] do
    a + b
  end

  deftimed timed_function2(a, b) do
    a + b
  end

  @spec timed_function_with_meta(number(), number()) :: number()
  deftimed timed_function_with_meta(a, b), [:a, :b], %{a: a} do
    a + b
  end

  def invoke_private(a) do
    private_fun(a)
  end

  deftimedp private_fun(a), [:something], do: a
end
