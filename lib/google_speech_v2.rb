require "pathname"
require "google_speech_v2/version"
require "google_speech_v2/warning"
require "google_speech_v2/config"
require "google_speech_v2/speech_to_text"

module GoogleSpeechV2
  extend self
  class ApiKeyMissing < StandardError ;end
  class BlockNotSet < StandardError ;end

  def speech_to_text_block(&block)
    @block = block
  end

  def clear_speech_to_text_block
    @block = nil
  end

  def speech_to_text(lang: GoogleSpeechV2::Config.lang, duration_in_sec: GoogleSpeechV2::Config.duration_in_sec)
    unless block_given?
      raise BlockNotSet.new("set a block by #speech_to_text_block") unless @block.instance_of? Proc 
    end

    gsv2 = GoogleSpeechV2::SpeechToText.new(lang: lang, duration_in_sec: duration_in_sec)
    gsv2.ensure_upload do |text, raw|
      if block_given?
        yield(text, raw)
      else
        @block.call(text, raw)
      end
    end
  end

  def available_lang_list
    SpeechToText::LANGS
  end

  unless defined?(Rspec).nil?
    Warning.check! 
  end
end

