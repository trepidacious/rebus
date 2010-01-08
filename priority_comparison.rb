# Compare self to another, according to the results of a priority method
module PriorityComparison
  def <=>(other)
    priority <=> other.priority
  end
end