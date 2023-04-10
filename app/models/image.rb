class Image < ApplicationRecord
  include UtilsHelper

  has_one_attached :image_file
  belongs_to :video

  validates :name, presence: true

  def summary
    "#{self.name}: #{self.size_in_mb}"
  end
end
