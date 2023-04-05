class Video < ApplicationRecord
  has_one_attached :video_file

  validates :name, presence: true
end
