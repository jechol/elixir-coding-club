## MyTask

아래를 참고하여 spawn_link, make_ref, send, receive 를 사용하여
Task.async, await 을 직접 구현해 보자.

```
iex(1)> Task.async(fn -> :foo end)
%Task{
  owner: #PID<0.165.0>,
  pid: #PID<0.167.0>,
  ref: #Reference<0.1470435912.721158150.77392>
}
iex(2)> flush
{#Reference<0.1470435912.721158150.77392>, :foo}
```

### 검증

```
mix test
```

