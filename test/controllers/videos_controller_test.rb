require "test_helper"

class VideosControllerTest < ActionDispatch::IntegrationTest
  test "should get upload" do
    get videos_upload_url
    assert_response :success
  end
end
