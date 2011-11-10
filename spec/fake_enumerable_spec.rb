require_relative "spec_helper"

describe "FakeEnumerable" do
  before do
    @list = SortedList.new

    # will get stored internally as 3, 4, 7, 13, 42
    @list << 3 << 13 << 42 << 4 << 7
  end

  it "supports all?" do
    @list.all? { |x| x.even? }.must_equal false
    @list.all? { |x| x > 2 }.must_equal true
    @list.all?.must_equal true
    [nil, false, true].all?.must_equal false
  end

  it "supports any?" do
    @list.any? { |x| x.even? }.must_equal true
    @list.any? { |x| x > 52 }.must_equal false
    @list.any?.must_equal true
    [nil, false].any?.must_equal false
  end

  it "supports count" do
    @list.count.must_equal 5
    @list.count { |x| x.odd? }.must_equal 3
    @list << 13
    @list.count(13).must_equal 2
  end

  it "supports detect" do
    @list.detect { |x| x.even? }.must_equal 4
    @list.detect { |x| x > 42 }.must_be_nil

    mock = MiniTest::Mock.new
    mock.expect(:call, nil)
    @list.detect(mock) { |x| x > 42 }
    assert mock.verify

    @list.detect.must_be_instance_of FakeEnumerator
  end

  it "supports drop" do
    @list.drop(2).must_equal([7, 13, 42])
    @list.drop(10).must_equal([])
  end

  it "supports drop_while" do
    @list.drop_while { |item| item < 10 }.must_equal([13, 42])
  end

  it "supports each_cons" do
    expected = [[3, 4], [4, 7], [7, 13], [13, 42]]
    array = []
    @list.each_cons(2) { |a| array << a }
    array.must_equal(expected)

    @list.each_cons(3).must_be_instance_of FakeEnumerator
  end

  it "supports each_entry" do
    expected = [1, [2, 3], 4]

    list = MultipleYieldList.new

    out = []
    list.each_entry { |a| out << a }
    out.must_equal(expected)

    list.each_entry.must_be_instance_of FakeEnumerator
  end

  it "supports each_slice" do
    expected = [[3, 4], [7, 13], [42]]

    out = []
    @list.each_slice(2) { |a| out << a }
    out.must_equal(expected)

    @list << 33
    out = []
    @list.each_slice(2) { |a| out << a }
    expected = [[3, 4], [7, 13], [33, 42]]
    out.must_equal(expected)

    @list.each_slice(2).must_be_instance_of FakeEnumerator
  end

  it "supports each_with_index" do
    expected = [[0, 3], [1, 4], [2, 7], [3, 13], [4, 42]]

    out = []
    @list.each_with_index { |item, index| out << [item, index]}
    out.must_equal(expected)

    @list.each_with_index.must_be_instance_of FakeEnumerator
  end

  it "supports each_with_object" do
    expected = { "3" => 4, "4" => 5, "7" => 8, "13" => 14, "42" => 43 }

    out = @list.each_with_object({}) { |item, memo| memo[item.to_s] = item.succ }
    out.must_equal(expected)

    @list.each_with_object({}).must_be_instance_of FakeEnumerator
  end

  it "supports flat_map" do
    expected = [3, 97, 4, 96, 7, 93, 13, 87, 42, 58]
    @list.flat_map { |x| [x, 100 - x] }.must_equal(expected)
  end

  it "supports group_by" do
    expected = { "odd" => [3, 7, 13], "even" => [4, 42] }
    @list.group_by { |item| item.even? ? "even" : "odd" }.must_equal(expected)
  end

  it "supports map" do
    @list.map { |x| x + 1 }.must_equal([4, 5, 8, 14, 43])
  end

  it "supports reduce" do
    @list.reduce(:+).must_equal(69)
    @list.reduce { |s, e| s + e }.must_equal(69)
    @list.reduce(-10) { |s, e| s + e }.must_equal(59)
  end

  it "supports select" do
    @list.select { |x| x.even? }.must_equal([4, 42])
  end

  it "supports sort_by" do
    # ascii sort order
    @list.sort_by { |x| x.to_s }.must_equal([13, 3, 4, 42, 7])
  end

end

class MultipleYieldList
  include FakeEnumerable

  def each
    yield 1
    yield 2, 3
    yield 4
  end
end
