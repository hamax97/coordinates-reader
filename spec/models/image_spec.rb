require "rails_helper"

RSpec.describe Image, type: :model do
  let(:video) { Video.create!(name: "fake_video.mp4"); }

  describe "validations" do

    subject { Image.new }
    it { should_not be_valid }

    it "should raise when not associated to a video" do
      expect { Image.create!(name: "fake_name.jpg") }.to
        raise_error(ActiveRecord::RecordInvalid, /Video must exist/)
    end

    it "should create and save to db when given at least a name" do
      image = video.images.create!(name: "fake_name.jpg")
      expect(Image.find(image.id)).to_not be_nil
    end
  end

  describe "#summary" do
    it "should include the name and size in MB" do
      image = Image.new(name: "fake_name.jpg", size: 10240)
      expect(image.summary).to match(/fake_name.*MB/)
    end
  end

  describe "#image_file" do
    it "should attach the given file" do
      image = video.images.create!(name: "fake_name.jpg")
      image.image_file.attach(
        io: File.open("spec/fixtures/files/example_image.jpg"),
        filename: "example_image.jpg"
      )

      expect(image.image_file).to be_attached

      image.image_file.purge
    end
  end
end
