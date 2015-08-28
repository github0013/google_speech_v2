module GoogleSpeechV2
  module Warning
    extend self
    class RequiredCommandMissing < StandardError ;end

    module Unindent
      refine String do
        def unindent
          gsub(/^#{scan(/^\s*/).min_by{|l|l.length}}/, "")
        end
      end
    end
    using Unindent


    def check!
      %w[arecord flac].each do |command|
        if %x|which #{command}|.size == 0
          raise RequiredCommandMissing.new <<-ERROR.unindent

            ==================================================
            "REQUIRED `#{command}` IS MISSING!!!!!!"
            ==================================================
            make sure you have this command installed.

          ERROR
        end
      end
    end
  end

end