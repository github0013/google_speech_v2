require "tempfile"
require 'active_support'
require 'active_support/core_ext'
require 'active_support/core_ext/hash/indifferent_access'
require "mechanize"
require "jsonpath"

module GoogleSpeechV2
  class SpeechToText
    class WrongLangName < StandardError ;end

    FLAC_RATE = 44100
    LANGS = Pathname(__FILE__).dirname.join("langs.txt").readlines.collect{|line| line.strip }


    attr_reader *(GoogleSpeechV2::Config::ATTRIBUTES.select{|attribute| not [:api_key].include? attribute })

    def initialize(lang: GoogleSpeechV2::Config.lang, duration_in_sec: GoogleSpeechV2::Config.duration_in_sec)
      @lang             = lang
      @duration_in_sec  = duration_in_sec
    end

    def ensure_upload
      raise ApiKeyMissing if GoogleSpeechV2::Config.api_key.nil?

      ensure_flac_path do |flac_path|
        params = {
          key:    GoogleSpeechV2::Config.api_key,
          lang:   param_lang,
          output: :json,
        }
        
        file = Mechanize.new.post "https://www.google.com/speech-api/v2/recognize?#{params.to_param}",
          {data: File.open(flac_path)}, 
          {'Content-type' => "audio/x-flac; rate=#{FLAC_RATE}"}


        # {"result":[]}
        # {"result":[{"alternative":[{"transcript":"good morning Google how are you feeling today","confidence":0.987629}],"final":true}],"result_index":0}
        raw = file.body.lines.collect do |line|
          JSON.parse(line).with_indifferent_access
        end

        transcripts = raw.collect do |json|
                        JsonPath.on(json, "$..alternative").flatten
                      end.flatten

        text = if transcripts.any?{|hash| hash.has_key? :confidence }
                transcripts.sort_by do |hash|
                  hash[:confidence].to_f
                end.reverse.first
              else
                transcripts.first
              end[:transcript]

        yield(text, raw)
      end
    end

    private

      def param_lang
        LANGS.find{|language| language.downcase == self.lang.downcase }.tap do |lang|
          raise WrongLangName unless lang
        end
      end

      def ensure_temp_path
        Tempfile.open("gsv2") do |temp|
          yield temp.path
        end
      end

      def ensure_flac_path
        ensure_temp_path do |temp_path|
          Kernel.system "arecord -q -t wav -d #{self.duration_in_sec} -f cd | flac - -f --best --sample-rate #{FLAC_RATE} -s -o #{temp_path}"
          yield temp_path
        end
      end

  end
end
