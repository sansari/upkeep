require "test_helper"

class AreaTest < ActiveSupport::TestCase
  test "validates name presence" do
    area = Area.new(name: nil)
    assert_not area.valid?
    assert_includes area.errors[:name], "can't be blank"
  end

  test "validates name uniqueness" do
    area = Area.new(name: "Kitchen")
    assert_not area.valid?
    assert_includes area.errors[:name], "has already been taken"
  end

  test "overdue_tasks_count returns count of overdue tasks in area" do
    kitchen = areas(:kitchen)
    assert_equal 1, kitchen.overdue_tasks_count
  end
end
