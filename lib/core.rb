require "streamio-ffmpeg"
require "rtesseract"

require_relative "exceptions.rb"

class CoordinatesExtractor
  def initialize(args = {})
    @video_path = args[:video_path]
    @images_extension = "jpg"
    @image_naming_pattern = "%06d.#{@images_extension}" # see ffmpeg's file numbering.
    @tesseract_config_file = "./config/tesseract.config"
  end

  def run
    # TODOs:
    # - Create a hash with coordinates as keys and image_path and image_text as values.
    # - The first image is duplicated, delete duplicate coordinates.
    # - Generate text files:
    #   - One per each image containing the coordinates, or NOT FOUND.
    #   - One with all the information collected per image.

    begin
      video_coordinates = {}

      images_dir = extract_images_per_second(@video_path, @image_naming_pattern)
      images = get_images_list(images_dir)
      images.each do |image_path|
        image_text = extract_text(image_path)
        coordinates = extract_coordinates(image_text)

        video_coordinates[image_path] = {
          coordinates: coordinates,
          image_text: image_text
        }
      end

      video_coordinates
    rescue => err
      raise CoordinatesExtractionError, err
    end
  end

  def extract_images_per_second(video_path, naming_pattern)
    # TODOs:
    # - Redirect the output of this command to a log file.
    # - Avoid generating images if they are already present.

    images_dir = create_images_dir(video_path)

    begin
      video = FFMPEG::Movie.new(video_path)
      video.screenshot(
        "#{images_dir}/#{naming_pattern}",
        {
          # if using the exact duration in seconds for vframes there might be
          # some frames at the end of the video that are not captured, so,
          # multiplying by two will always include all the number of frames
          # required and will not fail if more frames than the existing ones
          # are specified.
          vframes: video.duration.round() * 2,
          frame_rate: '1' # 1 frame per second.
        },
        validate: false
      )

      images_dir
    rescue => err
      delete_images_dir(images_dir)
      raise CoordinatesExtractionError, "Error extracting images for video: #{video_path}. #{err}"
    end
  end

  def extract_text(image_path)
    begin
      RTesseract.new(image_path, config_file: @tesseract_config_file).to_s.strip
    rescue => err
      raise CoordinatesExtractionError, "Error extracting text for image: #{image_path}. #{err}"
    end
  end

  def extract_coordinates(text)
    # TODOs:
    # - For string: "10.2542 6.23891 -75.03825", it matches: "10.2542 6.23891"
    #   - Look ahead and make sure only one match follows.
    # - For string: "6.23907 -181.03824", it matches: "6.23907 81.03824"
    #   - Longitudes of more than 180 are not valid coordinates.
    #   - Ensure there are no digits before the first digit, \D maybe.
    # - It matches only floating point values, not integers.

    coordinates_match = text.match(%r{
      # Latitude.
      # Number between -90 and 90 with 6 decimals maximum.
      (?<latitude>
        [+-]?
        (?:
          90(?:\.\d{1,6})          # match 90.######
          |                        # or
          [1-8]?\d(?:\.\d{1,6})    # number less than 90 ending with .######
        )
      )
      \s+
      # Longitude.
      # Number between -180 and 180 with 6 decimals maximum.
      (?<longitude>
        [+-]?
        (?:
          180(?:\.\d{1,6})                # match 180.######
          |                               # or
          (?:\d|1[0-7])?\d(?:\.\d{1,6})   # number less than 180 endint with .######
        )
      )
    }x)

    return [] if coordinates_match.nil?
    return coordinates_match[:latitude], coordinates_match[:longitude]
  end

private
  def create_images_dir(video_path)
    dir = video_path.rpartition(".")[0]
    unless Dir.exist?(dir)
      Dir.mkdir(dir)
    end

    dir
  end

  def delete_images_dir(images_dir)
    FileUtils.remove_dir(images_dir, force = true) if Dir.exist?(images_dir)
  end

  def get_images_list(images_dir)
    Dir["#{images_dir}/*.#{@images_extension}"]
  end
end