require "test_helper"

class ImagesControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get images_show_url
    assert_response :success
  end
end
