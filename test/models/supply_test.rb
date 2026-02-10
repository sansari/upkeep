require "test_helper"

class SupplyTest < ActiveSupport::TestCase
  test "low_stock? returns true when quantity_on_hand < quantity_per_use" do
    assert supplies(:water_filter_cartridge).low_stock?
  end

  test "low_stock? returns false when enough stock" do
    assert_not supplies(:shower_carbon_filter).low_stock?
  end

  test "low_stock scope returns low stock supplies" do
    low = Supply.low_stock
    assert_includes low, supplies(:water_filter_cartridge)
    assert_not_includes low, supplies(:shower_carbon_filter)
  end

  test "decrement_stock! reduces quantity" do
    supply = supplies(:shower_carbon_filter)
    supply.decrement_stock!
    assert_equal 1, supply.reload.quantity_on_hand
  end

  test "decrement_stock! floors at zero" do
    supply = supplies(:water_filter_cartridge)
    supply.decrement_stock!
    assert_equal 0, supply.reload.quantity_on_hand
  end
end
