module UtilsHelper
  def size_in_mb
    "#{(self.size.to_f / 1024 / 1024).round 2} MB"
  end
end
