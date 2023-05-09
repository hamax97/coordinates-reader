require 'rails_helper'

RSpec.describe "Images", type: :request do
  describe "GET /images/:id" do
    before :context do
      example_video = fixture_file_upload("example_video.mp4")

      post videos_path, params: { video: { video_file: example_video }}
      @video_id = response.get_header("video-id")
    end

    after :context do
      # for some reason calling Video.destroy(video_id) won't trigger the ActiveStorage deletion
      # process; it works when the application is running though.
      Video.find(@video_id).images.each do |i|
        i.image_file.purge
      end
    end

    it "shows the image specified by :id" do
      image = Video.find(@video_id).images.sample
      get image_path(image)
      expect(response).to have_http_status(200)
    end
  end
end
