start = Time.now
require 'rails_helper'
tend = Time.now
puts tend - start

RSpec.describe Image, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"

  it "should not save image without a name" do
    image = Image.create
    expect(image.save).to_not be(true)
  end
end
