require "fiber"

class FakeEnumerator
  include FakeEnumerable

  def initialize(target, method)
    @target = target
    @method = method
  end

  def each(&block)
    @target.send(@method, &block)
  end

  def next
    @fiber ||= Fiber.new do
      each { |e| Fiber.yield(e) }

      raise StopIteration
    end

    if @fiber.alive?
      @fiber.resume
    else
      raise StopIteration
    end
  end

  def with_index
    i = 0
    each do |e|
      out = yield(e, i)
      i += 1
      out
    end
  end

  def rewind
    @fiber = nil
  end
end
