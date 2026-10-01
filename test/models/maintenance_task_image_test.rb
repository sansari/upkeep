require "test_helper"

class MaintenanceTaskImageTest < ActiveSupport::TestCase
  test "requires a local guide SVG and alt text" do
    image = MaintenanceTaskImage.new(
      maintenance_task: maintenance_tasks(:replace_shower_filter),
      image_path: "https://example.com/image.png",
      alt_text: ""
    )

    assert_not image.valid?
    assert image.errors[:image_path].present?
    assert image.errors[:alt_text].present?
  end

  test "task orders instruction images by position" do
    images = maintenance_tasks(:replace_shower_filter).instruction_images

    assert_equal [ 1, 2 ], images.map(&:position)
  end
end
