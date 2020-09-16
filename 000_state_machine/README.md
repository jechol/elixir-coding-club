Reference : https://erlang.org/doc/design_principles/statem.html

# State machine 이란

1. State machine 이란?
   1. State + Input => (State', Output)
   2. Erlang process 자체가 state machine임.
      1. state = process dictionary + recursive call argument
      2. input = receive
      3. output = send
2. 그럼 gen_statem 은 무슨 용도?
   1. State별로 input handler가 달라질 경우
   2. State별로 output이 정해지는 경우
   3. State/Event별로 Timeout이 필요할 경우
   4. 위와 같은 경우 코드를 훨씬 가독성 있게 구조적으로 작성할수 있음.
3. state 와 data 구분?
   1. state + data = process state
   2. state : select input handler
4. GenStateMachine
   1. Erlang의 gen_statem을 간단히 wrap한 Elixir 라이브러리.
   2. GenStateMachine은 리턴값이나 동작 방식에 대한 설명이 부족하므로, gen_statem까지 읽어야 함.
      1. https://hexdocs.pm/gen_state_machine/GenStateMachine.html
      2. https://erlang.org/doc/design_principles/statem.html
      3. https://erlang.org/doc/man/gen_statem.html

# Goal 1 : State transition

<img src="img/code_lock.svg" width="400px">

1. state : locked, open
2. init state : locked
3. init data : %{code :: [1, 2], input :: []}
4. event handler:
   1. locked 에서 이벤트 {:button, 3} -> {:button, 1} -> {:button, 2} 를 받으면 open으로 전이하고 input clear.
   2. open 상태에서는 {:button, \_} 무시.

# Goal 2 : State timeout

1. locked -> open 으로 변할때 state_timeout 5000ms 걸고,
2. state_timeout 발생시 locked 로 transition.

# Goal 3 : Event timeout

<img src="img/code_lock_2.svg" width="400px">

1. locked 상태에서 {:button, \_} 이벤트 발생마다 timeout 5000ms 를 걸고,
2. timeout 발생시 input clear.

# Goal 4 : Moore machine

1. 현재 구현은 event handler 에서 side effect(=do_unlock)가 발생하는 Mealy machine임.
2. callback_mode 를 [:state_functions, :state_enter] 로 변경하고, state진입시 발생하는 enter event에서 side effect를 발생하도록 변경.

# Goal 5 : Test w/o side effect

1. 문제점 : mix test 시마다 do_lock, do_unlock이 실행되어 Locked, Unlocked 메시지가 출력된다.
2. 해결법 : definject 라이브러리를 사용.
