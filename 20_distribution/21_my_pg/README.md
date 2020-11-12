# Rpg (Re-impl of Erlang/OTP pg)

(Copied from https://github.com/jechol/rpg)

This is re-implementation of Erlang/OTP pg module in Elixir for learning purpose.

Major differences are summarized below.

|                            	| pg                          	| Rpg                      	|
|----------------------------	|-----------------------------	|--------------------------	|
| Language                   	| Erlang                      	| Elixir                   	|
| Component                  	| gen_server + ets (scalable) 	| GenServer (not scalable) 	|
| Code size (except comment) 	| 349 lines                   	| 222 lines                	|
| Production ready           	| Absolutely                  	| Definitely NO            	|


# 학습 주제

* pg 사용법 (https://erlang.org/doc/man/pg.html)
  * start
  * join, leave
  * which_groups, get_members, get_local_members
* 테스트 환경에서 분산 환경 시뮬레이션
  * test/support/cluster.ex (Phoenix.PubSub에서 복사후 수정함)
  * [epmd 를 자동으로 켜는 법](https://github.com/jechol/rpg/blob/df968ebeb69c0a46f8ecaa54b45be0a86bc82372/test/support/cluster.ex#L54) 
  * [분산 노드를 켜는 법](https://github.com/jechol/rpg/blob/df968ebeb69c0a46f8ecaa54b45be0a86bc82372/test/support/cluster.ex#L65)
  * [분산 노드에 코드 실행을 지시하는 법](https://github.com/jechol/rpg/blob/df968ebeb69c0a46f8ecaa54b45be0a86bc82372/test/support/cluster.ex#L12)
  * [분산 노드를 끄는 법](https://github.com/jechol/rpg/blob/df968ebeb69c0a46f8ecaa54b45be0a86bc82372/test/support/cluster.ex#L21)
* pg 프로토콜 이해
  * [scope을 기준으로 한 overlay network](https://github.com/jechol/rpg/blob/df968ebeb69c0a46f8ecaa54b45be0a86bc82372/lib/rpg.ex#L61)
  * discover -> sync
    * [send discover](https://github.com/jechol/rpg/blob/df968ebeb69c0a46f8ecaa54b45be0a86bc82372/lib/rpg.ex#L62)
    * [receive discover](https://github.com/jechol/rpg/blob/df968ebeb69c0a46f8ecaa54b45be0a86bc82372/lib/rpg.ex#L116)
      * [send sync](https://github.com/jechol/rpg/blob/df968ebeb69c0a46f8ecaa54b45be0a86bc82372/lib/rpg.ex#L128)
      * [receive sync](https://github.com/jechol/rpg/blob/db3ca9f661a6b478934168d8b8618a7b47eaf4a2/lib/rpg.ex#L144)
  * [overlay network down 감시](https://github.com/jechol/rpg/blob/db3ca9f661a6b478934168d8b8618a7b47eaf4a2/lib/rpg.ex#L138)
  * [local process down 감시](https://github.com/jechol/rpg/blob/db3ca9f661a6b478934168d8b8618a7b47eaf4a2/lib/rpg.ex#L280)