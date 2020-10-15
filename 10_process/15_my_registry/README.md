# MyRegistry

Registry 는

- keys: :unique 인 경우 process registry 기능을 하고, (local node 에서 :global 와 유사한 기능)
- keys: :duplicate 인 경우 process group 기능을 한다. (local node 에서 :pg 와 유사한 기능)

## Process registry 구현

Registry의 축소 버전 MyRegistry 을 Agent를 사용하여 구현하자.

- start_link(keys: :unique, name: name)
- register/3
- lookup/2
- unregister/2

```
mix test test/my_registry_test.exs:10
```

## :via 튜플 기능 구현

Registry는 :via 튜플을 통한 등록, 조회 기능을 제공한다.

```elixir
{:ok, reg} = Registry.start_link(keys: :unique, name: Foo)
Agent.start_link(fn -> 0 end, name: {:via, Registry, {Foo, :some_key}})
0 = Agent.get({:via, Registry, {Foo, :some_key}}, & &1)
```

Registry의 숨겨진 API 인 register_name, whereis_name 을 구현하여 같은 동작을 구현해보자.

### 검증

```
mix test
```