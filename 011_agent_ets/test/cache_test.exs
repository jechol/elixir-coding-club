defmodule AgentCacheTest do
  use ExUnit.Case, async: false

  for cache <- [AgentCache, EtsCache] do
    @cache cache

    describe "#{@cache}" do
      test ":error for non-exist" do
        {:ok, cache} = @cache.start_link()
        assert @cache.get(cache, :never_cache) == :error
      end

      test "get-set" do
        {:ok, cache} = @cache.start_link()

        Task.async(fn ->
          @cache.set(cache, :a, :first)
          @cache.set(cache, :a, :second)
          @cache.set(cache, :b, :third)

          assert @cache.get(cache, :a) == {:ok, :second}
          assert @cache.get(cache, :b) == {:ok, :third}
        end)
        |> Task.await()
      end
    end
  end
end
