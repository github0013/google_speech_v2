module GoogleSpeechV2
  module Config
    extend self

    ATTRIBUTES = [:api_key, :lang, :duration_in_sec]
    attr_accessor *ATTRIBUTES
  end
end

GoogleSpeechV2::Config.lang = "en-us"
GoogleSpeechV2::Config.duration_in_sec = 5