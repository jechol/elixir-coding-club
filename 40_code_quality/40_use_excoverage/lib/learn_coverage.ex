defmodule LearnCoverage do
  def target_called do
    "called" |> String.to_atom()
  end

  def target_not_called do
    "not_called" |> String.to_atom()
  end

  def not_target_called do
    :not_target
  end

  def not_target_not_called do
    :not_target
  end
end
