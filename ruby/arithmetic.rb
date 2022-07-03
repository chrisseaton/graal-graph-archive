RANDOM = Random.new

def example(x, y)
  x + y
end

loop do
  example RANDOM.rand(1000), RANDOM.rand(1000)
end
