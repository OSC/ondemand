module MotdFormatter
  require 'rss'

  class Markdown

    attr_reader :content, :title

    # @param [MotdFile] motd_file an MotdFile object that contains a URI path to a message of the day in OSC format
    def initialize(motd_file)
      motd_file = MotdFile.new unless motd_file
      @title = motd_file.title
      @content = OodAppkit.markdown.render(motd_file.content)
    end

    def to_partial_path
      "dashboard/motd_markdown"
    end
  end

  class MarkdownErb
    attr_reader :content, :title

    def initialize(motd_file)
      motd_file ||= MotdFile.new unless motd_file
      @title = motd_file.title
      @content = OodAppkit.markdown.render(MotdFormatter::parse_erb_motd_file(motd_file))
    end
    
    def to_partial_path
      "dashboard/motd_markdown"
    end
  end 
  
  class Osc

    attr_reader :content, :title

    # Parse the MOTD in OSC style
    # See: https://github.com/OSC/ood-dashboard/wiki/Message-of-the-Day
    #
    # @param [MotdFile] motd_file an MotdFile object that contains a URI path to a message of the day in OSC format
    def initialize(motd_file)
      motd_file = MotdFile.new unless motd_file
      @title = motd_file.title
      @content = motd_file.content
    end

    Message = Struct.new :date, :title, :body do
      def self.from(str)
        if str =~ /(\d+[-\/\.]\d+[-\/\.]\d+)\n--- ([ \S ]*)\n(.*)/m
          Message.new(Date.parse($1), $2, $3)
        else
          nil
        end
      rescue ArgumentError => e
        Rails.logger.warn("MOTD message poorly formatted: #{e} => #{e.message}")

        nil
      end
    end

    def to_partial_path
      "dashboard/motd_osc"
    end

    # since this actually splits the file content into separate messages
    # we can still use this as it is
    def messages
      if content
        # get array of sections which are delimited by a row of ******
        sections = content.split(/^\*+$/).map(&:strip).select { |x| ! x.empty?  }
        return sections.map { |s| Message.from(s) }.compact.sort_by {|s| s.date }.reverse
      else
        []
      end
    end
  end

  class Plaintext

    attr_reader :content, :title

    def initialize(motd_file)
      motd_file = MotdFile.new unless motd_file
      @title = motd_file.title
      @content = motd_file.content
    end

    def to_partial_path
      "dashboard/motd_plaintext"
    end
  end

  class PlaintextErb
    attr_reader :content, :title

    def initialize(motd_file)
      motd_file = MotdFile.new unless motd_file
      @title = motd_file.title
      @content = MotdFormatter::parse_erb_motd_file(motd_file)
    end

    def to_partial_path
      "dashboard/motd_plaintext"
    end
  end

  class Rss

    attr_reader :content, :title

    # @param [MotdFile] motd_file an MotdFile object that contains a URI path to a message of the day in OSC format
    def initialize(motd_file)
      motd_file = MotdFile.new unless motd_file
      @title = motd_file.title
      @content = parse_rss(motd_file.content)
    end

    def to_partial_path
      "dashboard/motd_rss"
    end

    private

    def parse_rss(rss_content)
      RSS::Parser.parse(rss_content)
    rescue RSS::NotWellFormedError
      Rails.logger.warn "MOTD is not parseable RSS"
      RSS::Parser.parse("")
    end
  end

  def self.parse_erb_motd_file(motd_file)
    # begin
      ERB.new(motd_file.content).result
    # rescue StandardError => e
    #   flash.now[:alert] = t('dashboard.motd_erb_render_error', error_message: e.message)
    # end
  end
end
