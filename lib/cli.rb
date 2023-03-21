#!/usr/bin/env ruby
require "optparse"
require_relative "core"

options = {}
OptionParser.new do |parser|
  parser.on("-v", "--video PATH_TO_VIDEO", "Path to video file") do |v|
    options[:video_path] = v
  end
end.parse!

raise ArgumentError("Missing --video flag") unless options.has_key?(:video_path)

CoordinatesExtractor.new(options).run()
