require "coordinates_extractor"

class VideosController < ApplicationController
  def extract_coordinates
    @video = Video.new
    @videos_processed = Video.all
  end

  def upload
    # TODO: delete images created by ffmpeg.
    # TODO: fix issue with SQLite3 ... busy exception.
    # TODO: Add copy to clipboard button to each coordinate.
    # TODO: add progress bar when processing a video.

    begin
      video_file = video_params[:video_file]

      coordinates_extractor = CoordinatesExtractor.new(video_path: video_file.path)
      video_coordinates = coordinates_extractor.run

      # TODO: change size to be an integer of bytes.
      @video = Video.create!(name: video_file.original_filename, size: get_video_size(video_file))

      # TODO: extract this to a new function.
      video_coordinates.each do |image_path, info|
        image_name = image_path.rpartition("/")[-1]
        lat, long = info[:coordinates].map { |x| x.to_f }
        image_text = info[:image_text]
        image_size = File.size(image_path)
        begin
          # TODO: change lat, long to be strings, the match might not always be a float.
          image = @video.images.create!(
            name: image_name, size: image_size, latitude: lat, longitude: long, extracted_text: image_text
          )
        rescue ActiveRecord::RecordInvalid => invalid_image
          @video.destroy
          return render_error invalid_image
        end

        image.image_file.attach(
          io: File.open(image_path),
          filename: image_name,
          content_type: "image/#{coordinates_extractor.image_extension}",
          identify: false
        )

        break # TODO: Remove this break.
        # TODO: Fix issue: SQLite3::BusyException: database is locked.
        # - read: https://discuss.rubyonrails.org/t/failed-write-transaction-upgrades-in-sqlite3/81480
      end

      redirect_to action: :extract_coordinates

    rescue ActiveRecord::RecordInvalid => invalid_video
      render_error invalid_video
    rescue => err
      render_error err
    end
  end

  def show
    @video = Video.find(params[:id])
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
end
