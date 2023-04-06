class Image < ApplicationRecord
  has_one_attached :image_file
  belongs_to :video
end
