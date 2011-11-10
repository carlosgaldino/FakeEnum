require_relative "fake_enumerable"
require_relative "fake_enumerator"

class SortedList
  include FakeEnumerable

  def initialize
    @data = []
  end

  def <<(value)
    @data << value
    @data.sort!
    self
  end

  def each
    if block_given?
      @data.each { |e| yield(e) }
    else
      FakeEnumerator.new(self, :each)
    end
  end
end
