# MySupervisor

목표: 기본적 기능만 하는 supervisor 를 만들어 보자.

### 요구사항

- restart: :permanent 만 지원. (transient, temporary 지원 안함)
- strategy: :one_for_one 만 지원.
- max_restart 무시. (연속해서 terminate 하더라도 계속 restart)

### 도구

- Process.flag(:trap_exit, true)
- Process.monitor(child_pid)
- receive

### 검증

```
mix test
```
