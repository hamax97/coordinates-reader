require 'rails_helper'

RSpec.describe "Videos", type: :request do
  describe "GET /videos" do
    it "shows the already processed videos" do
      videos = [
        Video.create!(name: "fake_video1.mp4"),
        Video.create!(name: "fake_video2.mp4")
      ]

      get videos_path

      expect(response.body).to match a_string_including(videos[0].name, videos[1].name)
    end
  end

  context "when a video was uploaded", order: :defined do
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

    describe "POST /videos" do
      it "processes a video and adds it to the list of processed videos" do
        expect(Video.find(@video_id)).to_not be_nil
        expect(response).to redirect_to(action: :extract_coordinates)
        follow_redirect!

        expect(response.body).to match a_string_including("example_video.mp4")
      end
    end

    describe "GET /videos/:id" do
      it "shows the video specified by :id" do
        get video_path(@video_id)

        expect(response).to have_http_status(:ok)
      end
    end

    describe "DELETE /videos/:id" do
      it "deletes the video specified by :id" do
        delete video_path(@video_id)

        expect(response).to redirect_to(action: :extract_coordinates)
      end
    end
  end
end
