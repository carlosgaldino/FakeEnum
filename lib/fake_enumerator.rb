require "fiber"

class FakeEnumerator
  include FakeEnumerable

  def initialize(target, method, arg = nil)
    @target = target
    @method = method
    @arg = arg
  end

  def each(&block)
    if @arg
      @target.send(@method, @arg, &block)
    else
      @target.send(@method, &block)
    end
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
