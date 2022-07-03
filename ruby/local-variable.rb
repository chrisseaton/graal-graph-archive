RANDOM = Random.new

def example(x, y)
  a = x + y
  a * 2 + a
end

loop do
  example RANDOM.rand(1000), RANDOM.rand(1000)
end
