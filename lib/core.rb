require "streamio-ffmpeg"
require "rtesseract"

class CoordinatesExtractor
  def initialize(args = {})
    @video_paths = [args[:video_path]]
    @images_extension = "jpg"
  end

  def run
    begin
      @video_paths.each do |video_path|
        images_dir = extract_images_per_second(video_path)

        images = get_images_list(images_dir)
        images.each do |image_path|
          coordinates = extract_coordinates(image_path)
        end
      end
    rescue => err
      STDERR.puts("Error in processing: #{err}")
      exit
    end
  end

  def extract_images_per_second(video_path)
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

  def extract_coordinates(image_path)
    # TODO: checkout the tesseract help for a more accurate extraction.
    # TODO: look at page segmentation modes.
    # TODO: look at user patterns dir.
    image_text = RTesseract.new(image_path, config_file: "digits quiet").to_s.strip

    puts "** #{image_path} coordinates: #{match_coordinates(image_text)} ===(#{image_text})==="
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

  def match_coordinates(text)
    # TODO: use a multiline regex and add comments.
    # TODO: tune the regex to prefer the numbers with dot.
    # TODO: the space in the beginning might not exist.
    text.match(/(\s+|^)((\-?|\+?)?\d+(\.\d+)?)\s((\-?|\+?)?\d+(\.\d+)?)/)
  end
end