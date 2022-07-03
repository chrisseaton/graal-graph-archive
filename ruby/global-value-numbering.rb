RANDOM = Random.new

def example(x, y)
  (x + y) * 2 + (x + y)
end

loop do
  example RANDOM.rand(1000), RANDOM.rand(1000)
end
