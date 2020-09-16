defmodule DoorLockTest do
  use ExUnit.Case

  alias DoorLock.Data

  @code [1, 2]

  describe "Goal 1: State transition" do
    @describetag :pending

    test "init" do
      assert DoorLock.init(@code) == {:ok, :locked, %Data{code: @code, input: []}}
    end

    test "locked" do
      assert DoorLock.locked(:cast, {:button, 2}, %Data{code: @code, input: []}) ==
               {:keep_state, %Data{code: @code, input: [2]}}

      assert DoorLock.locked(:cast, {:button, 1}, %Data{code: @code, input: [2]}) ==
               {:keep_state, %Data{code: @code, input: [2, 1]}}

      assert DoorLock.locked(:cast, {:button, 2}, %Data{code: @code, input: [2, 1]}) ==
               {:next_state, :open, %Data{code: @code, input: []}}
    end

    test "open" do
      assert DoorLock.open(:cast, {:button, 1}, %Data{code: @code, input: @code}) ==
               :keep_state_and_data
    end
  end

  describe "Goal 2: State timeout" do
    @describetag :pending

    test "locked" do
      assert DoorLock.locked(:cast, {:button, 2}, %Data{code: @code, input: [2, 1]}) ==
               {:next_state, :open, %Data{code: @code, input: []},
                [{:state_timeout, 5000, :lock}]}
    end

    test "open" do
      assert DoorLock.open(:state_timeout, :lock, %Data{code: @code, input: []}) ==
               {:next_state, :locked, %Data{code: @code, input: []}}
    end
  end

  describe "Goal 3: Event timeout" do
    @describetag :pending

    test "locked" do
      assert DoorLock.locked(:cast, {:button, 1}, %Data{code: @code, input: []}) ==
               {:keep_state, %Data{code: @code, input: [1]}, 5000}

      assert DoorLock.locked(:timeout, 5000, %Data{code: @code, input: [1]}) ==
               {:keep_state, %Data{code: @code, input: []}}
    end
  end

  describe "Goal 4: Convert to Moore machine from Mealy machine" do
    @describetag :pending

    test "init" do
      assert DoorLock.init(@code) == {:ok, :locked, %Data{code: @code, input: []}}
    end

    test "locked" do
      assert DoorLock.locked(:enter, :open, %Data{code: @code, input: []}) == :keep_state_and_data
    end

    test "open" do
      assert DoorLock.open(:enter, :locked, %Data{code: @code, input: []}) == :keep_state_and_data
    end
  end

  describe "Goal 5: Replace side effect on test with definject" do
    @describetag :pending

    test "init" do
      assert DoorLock.init(@code, %{
               &DoorLock.do_lock/0 => fn -> send(self(), :do_lock) end,
               strict: false
             }) == {:ok, :locked, %Data{code: @code, input: []}}

      refute_receive :do_lock
    end

    test "locked" do
      assert DoorLock.locked(:enter, :open, %Data{code: @code, input: []}, %{
               &DoorLock.do_lock/0 => fn -> send(self(), :do_lock) end
             }) == :keep_state_and_data

      assert_receive :do_lock
    end

    test "open" do
      assert DoorLock.open(:enter, :locked, %Data{code: @code, input: []}, %{
               &DoorLock.do_unlock/0 => fn -> send(self(), :do_unlock) end
             }) == :keep_state_and_data

      assert_receive :do_unlock
    end
  end
end
