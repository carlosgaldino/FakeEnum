require_relative "spec_helper"

describe "FakeEnumerable" do
  before do
    @list = SortedList.new

    # will get stored internally as 3, 4, 7, 13, 42
    @list << 3 << 13 << 42 << 4 << 7
  end

  it "supports drop" do
    @list.drop(2).must_equal([7, 13, 42])
    @list.drop(10).must_equal([])
  end

  it "supports drop_while" do
    @list.drop_while { |item| item < 10 }.must_equal([13, 42])
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
