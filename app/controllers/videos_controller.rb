require "coordinates_extractor"

class VideosController < ApplicationController
  def extract_coordinates
    @video = Video.new
    setup_extract_coordinates_view
  end

  def upload
    # TODO: return path to folder with images, hash with image and coordinates.
    # TODO: store each of the images together with their coordinates using Active Storage.
    # TODO: add progress bar.

    begin
      video_file = video_params[:video_file]
      video_coordinates = CoordinatesExtractor.new(video_path: video_file.path).run

      # TODO: save images. Before or after video? What if something happens? How to rollback?

      @video = Video.new(name: video_file.original_filename, size: get_video_size(video_file))
      if @video.save
        redirect_to action: :extract_coordinates
      else
        setup_extract_coordinates_view
        render :extract_coordinates, status: :unprocessable_entity
      end
    rescue => err
      render_error err
    end
  end

private
  def setup_extract_coordinates_view
    @videos_processed = get_videos_processed
  end

  def get_videos_processed
    Video.select(:name, :size).map { |v| "#{v.name} - #{v.size}" }
  end

  def video_params
    params.require(:video).permit(:video_file)
  end

  def get_video_size(video_file)
    to_kb = 1024
    to_mb = 1024
    return "#{video_file.size / to_kb / to_mb} MB"
  end

  def render_error(err)
    @coordinates_extraction_error = err
    render :error, status: :internal_server_error
  end

  # TODOs:
  # - Store images in DB using the ActiveStorage.
  # - Together with each image store the coordinates.
  # - Create a dynamic view for each video processed.
  #   - Show the list of images and their coordinates next to them.
  #   - Eeach image item should have a link to a preview of the image.
end
