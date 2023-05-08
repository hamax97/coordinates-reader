require "coordinates_extractor"

class VideosController < ApplicationController
  def extract_coordinates
    @video = Video.new
    @videos_processed = Video.all
  end

  def upload
    # TODO: Add copy to clipboard button to each coordinate.
    # TODO: add progress bar when processing a video.

    begin
      video_file = video_params[:video_file]

      CoordinatesExtractor.new(video_file.path) do |video_coordinates|

        # TODO: change size to be an integer of bytes.
        @video = Video.create!(name: video_file.original_filename, size: get_video_size(video_file))

        video_coordinates.each do |image_path, image_info|
          image = save_image_in_db(@video, image_path, image_info)
          store_image(image, image_path, image_info[:image_name])
        end
      end

      redirect_to action: :extract_coordinates

    rescue => err
      @video.destroy if @video
      render_error err
    end
  end

  def show
    @video = Video.find(params[:id])
  end

  def destroy
    Video.destroy(params[:id])

    redirect_to action: :extract_coordinates, status: :see_other
  end

private
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

  def save_image_in_db(video, image_path, image_info)
    image_name = image_info[:image_name]
    lat, long = image_info[:coordinates].map { |x| x.to_f }
    image_text = image_info[:image_text]
    image_size = File.size(image_path)

    # TODO: change lat, long to be strings, the match might not always be a float.
    video.images.create!(
      name: image_name, size: image_size, latitude: lat, longitude: long, extracted_text: image_text
    )
  end

  def store_image(image, image_path, image_name)
    image.image_file.attach(
      io: File.open(image_path),
      filename: image_name,
      content_type: "image/#{CoordinatesExtractor::IMAGE_EXTENSION}",
      identify: false
    )
  end
end
