require 'rails_helper'

RSpec.describe Video, type: :model do
  describe "validations" do
    subject { Video.new }
    it { should_not be_valid }

    it "should create and save when given at least a name" do
      video = Video.create!(name: "fake_video.mp4")
      expect(Video.find(video.id)).not_to be_nil
    end
  end

  describe "#summary" do
    it "should include the name and size in MB" do
      video = Video.create!(name: "fake_video.mp4", size: "10284 MB")
      expect(video.summary).to match(/fake_video.*MB/)
    end
  end

  describe "#images" do
    def create_images(video)
      images = []
      2.times do
        images << video.images.create!(name: "fake_image.jpg")
      end

      images
    end

    def get_image_ids(images)
      images.map { |i| i.id }
    end

    let(:video) { Video.create!(name: "fake_video.mp4") }

    it "should be able to save multiple images" do
      images = create_images(video)
      image_ids = get_image_ids(images)

      expect(Image.find(image_ids)).to contain_exactly(
        an_object_having_attributes(id: image_ids[0]),
        an_object_having_attributes(id: image_ids[1])
      )
    end

    context "when destroyed" do
      it "should delete all images associated" do
        images = create_images(video)
        image_ids = get_image_ids(images)

        Video.destroy(video.id)

        expect { Image.find(image_ids) }.to raise_error(ActiveRecord::RecordNotFound, /found 0/)
        expect { Video.find(video.id) }.to raise_error(ActiveRecord::RecordNotFound)
      end

      it "should delete all image_files attached" do
        images = create_images(video)

        Video.destroy(video.id)

        expect(images[0].image_file).to_not be_attached
        expect(images[1].image_file).to_not be_attached
      end
    end
  end
end
