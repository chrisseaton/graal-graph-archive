RANDOM = Random.new

def example(x, y)
  a = x + y
  opaque_call
  a * 2 + a
end

def opaque_call
end

loop do
  example RANDOM.rand(1000), RANDOM.rand(1000)
end
