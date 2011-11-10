module FakeEnumerable
  def all?
    unless block_given?
      each { |e| return false unless e }
    else
      each { |e| return false unless yield(e) }
    end
    true
  end

  def any?
    if block_given?
      each { |e| return true if yield(e) }
    else
      each { |e| return true if e }
    end
    false
  end

  def count(obj = nil)
    count = 0
    if obj
      each { |e| count += 1 if obj == e }
    elsif block_given?
      each { |e| count += 1 if yield(e) }
    else
      each { |e| count += 1 }
    end
    count
  end

  def detect(ifnone = nil)
    return FakeEnumerator.new(self, :detect) unless block_given?

    each { |e| return e if yield(e) }
    ifnone.call if ifnone
  end

  def drop(n)
    array = to_a
    return [] if n > array.size
    array[n...array.size]
  end

  def drop_while
    out = []

    each { |e| out << e unless yield(e) }

    out
  end

  def each_cons(size)
    return FakeEnumerator.new(self, :each_cons, size) unless block_given?

    out = []
    each do |e|
      out << e
      if out.size == size
        yield(out)
        out = [e]
      end
    end
  end

  def each_entry
    return FakeEnumerator.new(self, :each_entry) unless block_given?

    each do |*args|
      yield args.size == 1 ? args[0] : args
    end
  end

  def each_slice(length)
    return FakeEnumerator.new(self, :each_slice, length) unless block_given?

    out = []
    each do |e|
      out << e
      if out.length == length
        yield out
        out = []
      end
    end
    yield out unless out.empty?
  end

  def each_with_index
    return FakeEnumerator.new(self, :each_with_index) unless block_given?

    i = 0
    each { |e| yield i, e; i += 1 }
  end

  def each_with_object(memo)
    return FakeEnumerator.new(self, :each_with_object, memo) unless block_given?

    each { |e| yield e, memo }
    memo
  end

  def find_all
    return FakeEnumerator.new(self, :find_all) unless block_given?

    out = []
    each do |e|
      out << e if yield(e)
    end
    out
  end

  def flat_map(&block)
    map(&block).flatten!
  end

  def group_by
    hash = {}

    each do |item|
      key = yield(item)

      if hash.key?(key)
        hash[key] << item
      else
        hash[key] = [item]
      end
    end

    hash
  end

  def map
    if block_given?
      out = []

      each { |e| out << yield(e) }

      return out
    else
      FakeEnumerator.new(self, :map)
    end
  end

  def reduce(operation_or_value = nil)
    case operation_or_value
    when Symbol
      return reduce { |s, e| s.send(operation_or_value, e) }
    else
      acc = operation_or_value
    end

    each { |a| acc = acc.nil? ? a : yield(acc, a) }

    acc
  end

  def select
    out = []

    each { |e| out << e if yield(e) }

    out
  end

  def sort_by
    map { |a| [yield(a), a] }.sort.map { |a| a[1] }
  end

  def to_a
    out = []
    each { |e| out << e }
  end

  alias_method :entries, :to_a

end
