# Observing

### Observer

```
:observer.start
```

### Process Tree

observer 의 applications 에 나타나는 process tree 는 어떤 원리로 구성되는지 실험해 보자.

### ETS

observer 의 ets 에서 parent ets 를 찾아보자.

### Remote observer

이번에는 release 를 실행한 후 remote iex 로 observer 를 실행해보자.

(remote observer 실행을 위해 runtime_tools 를 extra_applications 에 추가했음.)

```
$ mix release
$ _build/dev/rel/observing/bin/observing daemon

$ iex --cookie (cat **/COOKIE) --sname dbg

iex> Node.connect(:"observing@jechol-mbp15a")
iex> :observer.start

# 30 초 정도 기다리면, 메뉴의 Nodes 에서 observing 으로 전환 가능.

_build/dev/rel/observing/bin/observing stop
```
