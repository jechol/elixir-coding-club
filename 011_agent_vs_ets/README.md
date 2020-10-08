## Agent vs ETS

### 구현

Agent 와 ETS 를 사용하여 counter 를 구현해보자.

(ETS 는 read_concurreny: true, write_concurrency: true 를 적용할 것.)

### 벤치마크

```
mix run bench/counter_tests.exs
```

counter 예제에 대한 ETS와 Agent의 성능을 비교해보고, 어떤 솔루션이 더 적합한지 생각해보자.
