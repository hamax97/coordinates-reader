class VideosController < ApplicationController
  def extract_coordinates
    @video = Video.new
  end

  def upload
    # TODO: Continue here ...
    # - Error: cannot redirect to nil
    # - Seems like @video is set to nil when calling this action.
    # - Is the controller instantiated again?
    # - See request response cycle.
    # - Why instantiating @video in extract_coordinates then? Is it needed for the view rendering and that's it?

    puts "============================= uploading, #{url_for @video}, #{@video},"
    redirect_to @video
  end
end
