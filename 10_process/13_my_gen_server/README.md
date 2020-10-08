# MyGenServer

아래와 같이 GenServer.call 이 보내는 메시지를 염탐하여

```
iex(3)> pid = spawn(fn -> receive do; x -> IO.inspect(x); end; end)
#PID<0.158.0>
iex(4)> GenServer.call(pid, :foo)
{:"$gen_call", {#PID<0.152.0>, #Reference<0.2833509647.2609119234.221258>}, :foo}
```

1. start_link/2
2. call/2

위 2가지 기능을 가진 GenServer 의 최소 버전을 구현해보자.

### Test

```
mix test
```
