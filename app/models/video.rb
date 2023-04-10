class Video < ApplicationRecord
  include UtilsHelper

  has_many :images, dependent: :destroy
  validates :name, presence: true

  def summary
    # TODO: use self.size_in_mb instead.
    "#{self.name} - #{self.size}"
  end
end
