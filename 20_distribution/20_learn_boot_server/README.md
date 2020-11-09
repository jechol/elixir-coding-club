# Distribution

## Setup EPMD

distributed node 에 필요한 API 들은 node discovery 를 위해 epmd 에 연결을 시도한다.
epmd 는 iex 와 별개로 미리 실행되어 있어야 한다.
(erlang release 는 distributed release 인 경우 자동으로 epmd를 실행함.)

```console
$ epmd -daemon
```

epmd 가 응답하는지 확인하려면

```console
$ epmd -names
```





