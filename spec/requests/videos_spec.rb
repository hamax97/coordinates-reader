require 'rails_helper'

RSpec.describe "Coordinates extraction", type: :request do
  describe "GET /videos" do
    it "shows the already processed videos" do
      videos = [ Video.create!(name: "fake_video1.mp4"), Video.create!(name: "fake_video2.mp4") ]

      get videos_path

      expect(response.body).to match a_string_including(videos[0].name, videos[1].name)
    end
  end

  describe "POST /videos" do
    it "processes a video and adds it to the list of processed videos" do
      pending "fix the call to post, it's expecting only one arg??"

      video_filename = "example_video.mp4"
      example_video = fixture_file_upload(video_filename)

      post "/videos", params: { video: { video_file: example_video }}

      expect(response).to redirect_to(:extract_coordinates)
      follow_redirect!

      expect(response.body).to match a_string_including(video_filename)
    end
  end
end
