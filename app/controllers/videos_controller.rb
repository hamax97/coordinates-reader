require "coordinates_extractor"

class VideosController < ApplicationController
  def extract_coordinates
    @videos_processed = ["asd.mp4"] # TODO: get this from DB.
  end

  def upload
    puts "======================== #{params} ============================"
    @videos_processed = ["asd.mp4"] # TODO: add to db.
    CoordinatesExtractor.new(video_path: params["video"]["video_file"].path).run
    render :extract_coordinates
  end

  # TODOs:
  # - Store images in DB using the ActiveStorage.
  # - Together with each image store the coordinates.
  # - Create a dynamic view for each video processed.
  #   - Show the list of images and their coordinates next to them.
  #   - Eeach image item should have a link to a preview of the image.
end
