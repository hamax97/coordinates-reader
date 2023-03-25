require "streamio-ffmpeg"
require "rtesseract"

class CoordinatesExtractor
  def initialize(args = {})
    # TODOs:
    # - Receive tesseract config file as arg.
    # - Receive image extension as arg.

    @video_paths = [args[:video_path]]
    @images_extension = "jpg"
  end

  def run
    # TODOs:
    # - Create a hash with coordinates as keys and image_path and image_text as values.
    # - The first image is duplicated, delete duplicate coordinates.
    # - Generate text files:
    #   - One per each image containing the coordinates, or NOT FOUND.
    #   - One with all the information collected per image.

    begin
      @video_paths.each do |video_path|
        images_dir = extract_images_per_second(video_path)

        images = get_images_list(images_dir)
        images.each do |image_path|
          image_text = extract_text(image_path)
          coordinates = extract_coordinates(image_text)
          puts "** #{image_path} coordinates: #{coordinates} ===(#{image_text})==="
        end
      end
    rescue => err
      STDERR.puts("Error in processing: #{err}")
      exit
    end
  end

  def extract_images_per_second(video_path)
    # TODOs:
    # - Avoid generating images if they are already present.

    begin
      images_dir = create_images_dir(video_path)
      video = FFMPEG::Movie.new(video_path)
      video.screenshot(
        "#{images_dir}/%06d.#{@images_extension}",
        {
          # if using only the duration in seconds for vframes there might be
          # some frames at the end of the video that are not captured, so,
          # multiplying by two will always include all the number of frames
          # required and will not fail if more frames than the existing ones
          # are specified.
          vframes: video.duration.round() * 2,
          frame_rate: '1' # 1 frame per second.
        },
        validate: false
      )

      return images_dir
    rescue => err
      STDERR.puts("Error extracting images for video: #{video_path}.\n#{err}")
      raise err
    end
  end

  def extract_text(image_path)
    begin
      RTesseract.new(
        image_path, config_file: "./config/tesseract.config"
      ).to_s.strip
    rescue => err
      STDERR.puts("Error extracting text for image: #{iamge_path}.\n#{err}")
      raise err
    end
  end

  def extract_coordinates(text)
    # TODOs:
    # - For string: "10.2542 6.23891 -75.03825", it matches: "10.2542 6.23891"
    #   - Look ahead and make sure only one match follows.
    # - For string: "6.23907 -181.03824", it matches: "6.23907 81.03824"
    #   - Ensure there are no digits before the first digit, \D maybe.

    coordinates_match = text.match(%r{
      # Latitude.
      # Number between -90 and 90 with 6 decimals maximum.
      (?<latitude>
        [+-]?
        (?:
          90(?:\.\d{1,6})          # match 90.######
          |                        # or
          [1-8]?\d(?:\.\d{1,6})    # number less than 90 with .######
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
          (?:\d|1[0-7])?\d(?:\.\d{1,6})   # number less than 180 with .######
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

  def get_images_list(images_dir)
    Dir["#{images_dir}/*.#{@images_extension}"]
  end
end