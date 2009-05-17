module Paperclip

  class Transcode < Processor

    def initialize file, options = {}, attachment = nil
      @file           = file
      @geometry       = options[:geometry]
      @format         = options[:format]
      @options        = options[:options]
      @current_format = File.extname(@file.path)
      @basename       = File.basename(@file.path, @current_format)
    end

    def make
      dst = Tempfile.new([@basename, @format].compact.join("."))

      cmd = []
      cmd << "ffmpeg"
      cmd << "-i \"#{File.expand_path(@file.path)}\""
      cmd << "-s #{@geometry}" if @geometry
      cmd << @options if @options
      cmd << "-y"
      cmd << "\"#{File.expand_path(dst.path)}\""
      cmd = cmd.join(' ')

      begin
        success = system cmd
      rescue
        raise PaperclipError, "There was an error transcoding #{@basename} to #{@format}"
      end

      dst
    end

  end

end
