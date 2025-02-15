defmodule TakeANumberTest do
  use ExUnit.Case

  @task_id 1
  test "starts a new process" do
    pid = TakeANumber.start()
    assert is_pid(pid)
    assert pid != self()
    assert pid != TakeANumber.start()
  end

  @task_id 2
  test "reports its own state" do
    pid = TakeANumber.start()
    send(pid, {:report_state, self()})
    assert_receive 0
  end

  @task_id 2
  test "does not shut down after reporting its own state" do
    pid = TakeANumber.start()
    send(pid, {:report_state, self()})
    assert_receive 0

    send(pid, {:report_state, self()})
    assert_receive 0
  end

  @task_id 3
  test "gives out a number" do
    pid = TakeANumber.start()
    send(pid, {:take_a_number, self()})
    assert_receive 1
  end

  @task_id 3
  test "gives out many consecutive numbers" do
    pid = TakeANumber.start()
    send(pid, {:take_a_number, self()})
    assert_receive 1

    send(pid, {:take_a_number, self()})
    assert_receive 2

    send(pid, {:take_a_number, self()})
    assert_receive 3

    send(pid, {:report_state, self()})
    assert_receive 3

    send(pid, {:take_a_number, self()})
    assert_receive 4

    send(pid, {:take_a_number, self()})
    assert_receive 5

    send(pid, {:report_state, self()})
    assert_receive 5
  end

  @task_id 4
  test "stops" do
    pid = TakeANumber.start()
    assert Process.alive?(pid)
    send(pid, {:report_state, self()})
    assert_receive 0

    send(pid, :stop)
    send(pid, {:report_state, self()})
    refute_receive 0
    refute Process.alive?(pid)
  end

  @task_id 5
  test "ignores unexpected messages and keeps working" do
    pid = TakeANumber.start()

    send(pid, :hello?)
    send(pid, "I want to speak with the manager")

    send(pid, {:take_a_number, self()})
    assert_receive 1

    send(pid, {:report_state, self()})
    assert_receive 1

    assert Keyword.get(Process.info(pid), :message_queue_len) == 0
  end
end
