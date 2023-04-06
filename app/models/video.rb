class Video < ApplicationRecord

  # Not attaching the video file, this is used for easily building the upload form.
  has_one_attached :video_file

  has_many :images, dependent: :destroy

  validates :name, presence: true
end
