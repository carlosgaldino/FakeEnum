require_relative "spec_helper"

describe "FakeEnumerator" do
  before do
    @list = SortedList.new

    @list << 3 << 13 << 42 << 4 << 7
  end

  it "supports next" do
    enum = @list.each

    enum.next.must_equal(3)
    enum.next.must_equal(4)
    enum.next.must_equal(7)
    enum.next.must_equal(13)
    enum.next.must_equal(42)

    assert_raises(StopIteration) { enum.next }
  end

  it "supports rewind" do
    enum = @list.each

    4.times { enum.next }
    enum.rewind

    2.times { enum.next }
    enum.next.must_equal(7)
  end

  it "supports with_index" do
    enum     = @list.map
    expected = ["0. 3", "1. 4", "2. 7", "3. 13", "4. 42"]

    enum.with_index { |e, i| "#{i}. #{e}" }.must_equal(expected)
  end
end
