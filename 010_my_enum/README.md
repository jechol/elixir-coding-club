# Collection

### Enumerable

`Enumerable` protocol 을 구현하면, `Enum` 과 `Stream` 의 첫번째 아규먼트로 사용할 수 있게 됩니다.

Binary 는 Enumerable 이 구현되어 있지 않은데, 이를 구현해보고 왜 List와 달리 Enumerable 이 기본적으로 구현되어 있지 않는지 생각해 봅시다.

### Collectable

`Collectable` protocol 을 구현하면, `Enum.into` 함수의 2번째 아규먼트로 쓸수 있게 됩니다.

Tuple 은 Collectable 이 구현되어 있지 않은데, 이를 구현해보고 왜 List와 달리 Collectable이 기본적으로 구현되어 있지 않는지 생각해 봅시다.
