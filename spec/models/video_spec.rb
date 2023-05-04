require 'rails_helper'

RSpec.describe Video, type: :model do
  describe "validations" do
    it "should raise when not given a name" do
      expect { Video.create! }.to raise_error(ActiveRecord::RecordInvalid)
    end

    it "should create and save when given at least a name" do
      video = nil
      expect { video = Video.create!(name: "fake_video.mp4") }.not_to raise_error
      expect(Video.find(video.id)).not_to be_nil
    end
  end

  describe "#summary" do
    it "should include the name and size in MB" do
      video = Video.create!(name: "fake_video.mp4", size: "10284 MB")
      expect(video.summary).to match(/fake_video.mp4.*MB/)
    end
  end

  describe "#images" do
    def create_images(video)
      image_ids = []
      2.times do
        image_ids << video.images.create!(name: "fake_image.jpg").id
      end

      image_ids
    end

    it "should be able to save multiple images" do
      video = Video.create!(name: "fake_video.mp4")
      image_ids = create_images(video)

      expect(Image.find(image_ids)).to contain_exactly(
        an_object_having_attributes(id: image_ids[0]),
        an_object_having_attributes(id: image_ids[1])
      )
    end

    it "should delete all images associated when destroyed" do
      video = Video.create!(name: "fake_video.mp4")
      image_ids = create_images(video)

      Video.destroy(video.id)
      expect { Image.find(image_ids) }.to raise_error(ActiveRecord::RecordNotFound, /found 0/)
      expect { Video.find(video.id) }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
