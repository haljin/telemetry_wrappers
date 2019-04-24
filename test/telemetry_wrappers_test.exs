defmodule TelemetryWrappersTest do
  use ExUnit.Case
  doctest TelemetryWrappers

  defmodule TestModule do
    use TelemetryWrappers

    deftimed my_fun(a), [:some, :metric], do: a

    def wrapper(a), do: my_priv_fun(a)

    deftimedp my_priv_fun(a), [:some, :metric], do: a

    deftimed my_fun_with_default(a), do: a
  end

  defmodule DummyHandler do
    def handle([:some, :metric], measurement, _, pid), do: send(pid, measurement)
    def handle([:timing, fun_name], measurement, _, pid), do: send(pid, {fun_name, measurement})
  end

  setup do
    :telemetry.attach(:handler, [:some, :metric], &DummyHandler.handle/4, self())
    on_exit(fn -> :telemetry.detach(:handler) end)
  end

  test "Function call emit events" do
    assert 6 == TestModule.my_fun(6)
    assert_received %{call: _}
  end

  test "Private function call emit events" do
    assert 6 == TestModule.wrapper(6)
    assert_receive %{call: _}
  end

  test "Function call emit default events" do
    :telemetry.attach(
      :default_handler,
      [:timing, :my_fun_with_default],
      &DummyHandler.handle/4,
      self()
    )

    assert 6 == TestModule.my_fun_with_default(6)
    assert_received {:my_fun_with_default, %{call: _}}
  end
end
