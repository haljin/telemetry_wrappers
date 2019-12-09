defmodule TelemetryWrappersTest do
  use ExUnit.Case
  doctest TelemetryWrappers

  defmodule TestModule do
    use TelemetryWrappers

    deftimed my_fun(a), [:some, :metric], %{env: a}, do: a

    def wrapper(a), do: my_priv_fun(a)

    def wrapper_with_meta(a), do: my_priv_fun_with_meta(a)

    deftimedp my_priv_fun(a), [:some, :metric], do: a

    deftimed my_fun_with_default(a), do: a

    deftimedp my_priv_fun_with_meta(a), [:some, :metric], %{env: System.get_env("DUMMY")}, do: a

    deftimed multi_clause(:a), [:some, :metric], do: :ok
    deftimed multi_clause(:b), [:some, :metric], do: :bad
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

  test "Private function call emit events with metadata" do
    assert 6 == TestModule.wrapper_with_meta(6)
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

  test "Multi-clause timed function" do
    assert :ok == TestModule.multi_clause(:a)
    assert_receive %{call: _}
    assert :bad == TestModule.multi_clause(:b)
    assert_receive %{call: _}
  end
end
