## Agent vs ETS

### 구현

Agent 와 ETS 를 사용하여 cache 를 구현해보자.

(ETS 는 read_concurrency: true, write_concurrency: true 를 적용할 것.)

### 검증

```
mix test
```

### 벤치마크

(agent_cache.ex, ets_cache.ex 를 구현 후에만 benchmark 가능. lib_sol/ 참고)

```
mix run bench/cache_read_bench.exs
mix run bench/cache_write_bench.exs
```

counter 예제에 대한 ETS와 Agent의 성능을 비교해보고, 어떤 솔루션이 더 적합한지 생각해보자.
