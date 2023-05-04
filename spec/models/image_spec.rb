require "rails_helper"

RSpec.describe Image, type: :model do
  let(:video) { Video.create!(name: "fake_video.mp4"); }

  describe "validations" do
    it "should raise when not given a name" do
      expect { Image.create! }.to raise_error(ActiveRecord::RecordInvalid)
    end

    it "should raise when not associated to a video" do
      expect { Image.create!(name: "fake_name.jpg") }.to raise_error(ActiveRecord::RecordInvalid, /Video must exist/)
    end

    it "should create and save to db when given at least a name" do
      image = nil

      expect { image = video.images.create!(name: "fake_name.jpg") }.not_to raise_error
      expect(image.id).to_not be_nil
      expect(Image.find(image.id)).to_not be_nil
    end
  end

  describe "#summary" do
    it "should include the name and size in mb" do
      name = "fake_name.jpg"
      size_in_bytes = 10240
      image = Image.new(name: name, size: size_in_bytes)

      expect(image.summary).to match(/#{name}.*MB/)
    end
  end

  describe "#image_file" do
    it "should attach the given file" do
      image = video.images.create!(name: "fake_name.jpg")
      image.image_file.attach(io: File.open("spec/fixtures/example_image.jpg"), filename: "example_image.jpg")

      expect(image.image_file).to be_attached

      image.image_file.purge
    end
  end

  # after(:context) do
  #   Video.destroy(video.id)
  # end
end
