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

    deftimedp my_priv_fun_with_meta(a), [:some, :metric], %{env: "Something"}, do: a

    deftimed multi_clause(:a), [:some, :metric], do: :ok
    deftimed multi_clause(:b), [:some, :metric], do: :bad
  end

  defmodule DummyHandler do
    def handle([:some, :metric], measurement, meta, pid), do: send(pid, {measurement, meta})

    def handle([:timing, fun_name], measurement, meta, pid),
      do: send(pid, {fun_name, {measurement, meta}})
  end

  setup do
    :telemetry.attach(:handler, [:some, :metric], &DummyHandler.handle/4, self())
    on_exit(fn -> :telemetry.detach(:handler) end)
  end

  test "Function call emit events" do
    assert 6 == TestModule.my_fun(6)

    assert_received {%{call: _},
                     %{env: 6, function: :my_fun, module: TelemetryWrappersTest.TestModule}}
  end

  test "Private function call emit events" do
    assert 6 == TestModule.wrapper(6)

    assert_receive {%{call: _},
                    %{function: :my_priv_fun, module: TelemetryWrappersTest.TestModule}}
  end

  test "Private function call emit events with metadata" do
    assert 6 == TestModule.wrapper_with_meta(6)

    assert_receive {%{call: _},
                    %{
                      env: "Something",
                      function: :my_priv_fun_with_meta,
                      module: TelemetryWrappersTest.TestModule
                    }}
  end

  test "Function call emit default events" do
    :telemetry.attach(
      :default_handler,
      [:timing, :my_fun_with_default],
      &DummyHandler.handle/4,
      self()
    )

    assert 6 == TestModule.my_fun_with_default(6)

    assert_received {:my_fun_with_default,
                     {%{call: _},
                      %{function: :my_fun_with_default, module: TelemetryWrappersTest.TestModule}}}
  end

  test "Multi-clause timed function" do
    assert :ok == TestModule.multi_clause(:a)

    assert_receive {%{call: _},
                    %{function: :multi_clause, module: TelemetryWrappersTest.TestModule}}

    assert :bad == TestModule.multi_clause(:b)

    assert_receive {%{call: _},
                    %{function: :multi_clause, module: TelemetryWrappersTest.TestModule}}
  end
end
