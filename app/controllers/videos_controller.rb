require "coordinates_extractor"

class VideosController < ApplicationController
  def extract_coordinates
    @videos_processed = Video.select(:name, :size).map { |v| "#{v.name} - #{v.size}" }
  end

  def upload
    # TODO: process video and check if successful, otherwise cleanup.
    # TODO: return path to folder with images, hash with image and coordinates.
    # TODO: store each of the images together with their coordinates using Active Storage.
    # TODO: make video.name not null in db.
    # CoordinatesExtractor.new(video_path: params["video"]["video_file"].path).run

    video_file = video_params
    video = Video.new(name: video_file.original_filename, size: get_video_size(video_file))
    if video.save
      redirect_to action: :extract_coordinates
    else
      render :extract_coordinates, status: :unprocessable_entity
    end
  end

private
  def video_params
    filtered_params = params.require(:video).permit(:video_file)
    filtered_params[:video_file]
  end

  def get_video_size(video_file)
    to_kb = 1024
    to_mb = 1024
    return "#{video_file.size / to_kb / to_mb} MB"
  end

  # TODOs:
  # - Store images in DB using the ActiveStorage.
  # - Together with each image store the coordinates.
  # - Create a dynamic view for each video processed.
  #   - Show the list of images and their coordinates next to them.
  #   - Eeach image item should have a link to a preview of the image.
end
