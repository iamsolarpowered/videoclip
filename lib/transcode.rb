module Paperclip

  class Transcode < Processor

    def initialize file, options = {}, attachment = nil
      @file               = file
      @format             = options[:format]
      @options            = options
      @current_format     = File.extname(@file.path)
      @basename           = File.basename(@file.path, @current_format)
    end

    def make
      dst = Tempfile.new([@basename, @format].compact.join("."))
      dst.binmode
      begin
        Paperclip.run 'ffmpeg', cmd(dst)
      rescue
        raise PaperclipError, "There was an error transcoding #{@basename} to #{@format}" unless Paperclip.options[:suppress_errors]
      end
      dst
    end

    def cmd outfile
      a = []
      a << "-i \"#{File.expand_path(@file.path)}\""
      a << ffmpeg_options
      a << "\"#{File.expand_path(outfile.path)}\""
      a.join(' ')
    end

    def ffmpeg_options
      a = []

      # General options
      a << "-f #{@options[:force_format]}"        if @options[:force_format]
      a << "-t #{@options[:duration]}"            if @options[:duration]
      a << "-fs #{@options[:file_size]}"          if @options[:file_size]
      a << "-ss #{@options[:time_offset]}"        if @options[:time_offset]
      a << "-title #{@options[:title]}"           if @options[:title]
      a << "-timestamp #{@options[:timestamp]}"   if @options[:timestamp]
      a << "-author #{@options[:author]}"         if @options[:author]
      a << "-copyright #{@options[:copyright]}"   if @options[:copyright]
      a << "-comment #{@options[:comment]}"       if @options[:comment]
      a << "-genre #{@options[:genre]}"           if @options[:genre]
      a << "-album #{@options[:album]}"           if @options[:album]
      a << "-target #{@options[:target]}"         if @options[:target]
      a << "-b #{@options[:bitrate]}"             if @options[:bitrate]

      # Video options
      a << "-vb #{@options[:video_bitrate]}"      if @options[:video_bitrate]
      a << "-vframes #{@options[:video_frames]}"  if @options[:video_frames]
      a << "-r #{@options[:rate]}"                if @options[:rate]
      a << "-s #{@options[:size]}"                if @options[:size]
      a << "-s #{@options[:geometry]}" if !@options[:size] && @options[:geometry]
      a << "-aspect #{@options[:aspect]}"         if @options[:aspect]
      a << "-croptop #{@options[:crop_top]}"      if @options[:crop_top]
      a << "-cropbottom #{@options[:crop_bottom]}" if @options[:crop_bottom]
      a << "-cropleft #{@options[:crop_left]}"    if @options[:crop_left]
      a << "-cropright #{@options[:crop_right]}"  if @options[:crop_right]
      a << "-padtop #{@options[:pad_top]}"        if @options[:pad_top]
      a << "-padbottom #{@options[:pad_bottom]}"  if @options[:pad_bottom]
      a << "-padleft #{@options[:pad_left]}"      if @options[:pad_left]
      a << "-padright #{@options[:pad_right]}"    if @options[:pad_right]
      a << "-padcolor #{@options[:pad_color]}"    if @options[:pad_color]
      a << "-vn"                                  if @options[:disable_video]
      a << "-vcodec #{@options[:video_codec]}"    if @options[:video_codec]
      a << "-sameq"                               if @options[:same_quality]

      # Audio options
      a << "-ab #{@options[:audio_bitrate]}"      if @options[:audio_bitrate]
      a << "-aframes #{@options[:audio_frames]}"  if @options[:audio_frames]
      a << "-aq #{@options[:audio_quality]}"      if @options[:audio_quality]
      a << "-ar #{@options[:audio_rate]}"         if @options[:audio_rate]
      a << "-ac #{@options[:audio_channels]}"     if @options[:audio_channels]
      a << "-an"                                  if @options[:disable_audio]
      a << "-acodec #{@options[:audio_codec]}"    if @options[:audio_codec]
      a << "-vol #{@options[:volume]}"            if @options[:volume]

      a << @options[:options] if @options[:options] # additional options
      a << "-y" # overwrite tmp file

      a.join(' ')
    end

  end

end
