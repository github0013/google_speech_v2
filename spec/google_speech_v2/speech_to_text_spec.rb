require 'spec_helper'

describe GoogleSpeechV2::SpeechToText do
  before{ GoogleSpeechV2::Config.api_key = ENV["API_KEY"]}
  after do 
    # back to the default value
    GoogleSpeechV2::Config.lang             = "en-us"
    GoogleSpeechV2::Config.duration_in_sec  = 5 
  end

  describe :attributes do
    subject{ GoogleSpeechV2::SpeechToText.new }
    it{ expect(subject).to be_respond_to :lang }
    it{ expect(subject).to be_respond_to :duration_in_sec }
  end 

  describe :langs do
    it{ expect(GoogleSpeechV2::SpeechToText::LANGS).to be_instance_of Array }
  end

  describe :initialization do 
    let(:lang){ "ja-JP" }
    let(:duration_in_sec){ 10 }
    subject{ GoogleSpeechV2::SpeechToText.new lang: lang, duration_in_sec: duration_in_sec }

    it{ expect(subject.lang).to eq lang }
    it{ expect(subject.duration_in_sec).to eq duration_in_sec }

    context "default values" do
      subject{ GoogleSpeechV2::SpeechToText.new }
      it{ expect(subject.lang).to eq "en-us" }
      it{ expect(subject.duration_in_sec).to eq 5 }
    end
  end

  describe :ensure_upload do
    subject{ GoogleSpeechV2::SpeechToText.new }

    context "key missing" do
      before{ GoogleSpeechV2::Config.api_key = nil }
      it{ expect{ subject.ensure_upload{} }.to raise_error GoogleSpeechV2::ApiKeyMissing }
    end

    
    context "has key" do
      before do
        GoogleSpeechV2::Config.lang             = "en-us"
        GoogleSpeechV2::Config.duration_in_sec  = 3

        allow(subject).to receive(:ensure_flac_path).
                          and_yield(
                            Pathname(__FILE__).join("../../audio/good-morning-google.flac").to_s
                          )
      end

      describe "actual query to Google" do
        it do 
          VCR.use_cassette("GoogleSpeechV2::SpeechToText#ensure_upload - has key") do
            expect{|block| subject.ensure_upload &block }.to yield_with_args "good morning Google how are you feeling today", Array
          end
        end
      end

      describe "results" do
        let(:mechanize){ spy(:mechanize) }
        before do
          file = spy(:mechanize_file)
          allow(file).to receive(:body).and_return body
          allow(mechanize).to receive(:post).and_return file
          allow(Mechanize).to receive(:new).and_return mechanize
        end

        context "when no results" do
          let(:body) do
            <<-BODY
              {"result": []}
            BODY
          end

          it do 
            expect{|block| subject.ensure_upload &block }.to yield_with_args "", Array
          end
        end

        context "when one confidence" do
          let(:body) do
            <<-BODY
              {"result": []}
              {"result": [{"alternative": [{"transcript": "confidence no.1", "confidence": 0.99999999}, {"transcript": "confidence nil 3"}, {"transcript": "confidence nil 4"}], "final": true}], "result_index": 1}
            BODY
          end

          it do 
            expect{|block| subject.ensure_upload &block }.to yield_with_args "confidence no.1", Array
          end
        end

        context "when multiple confidences" do
          let(:body) do
            <<-BODY
              {"result": []}
              {"result": [{"alternative": [{"transcript": "confidence no.2", "confidence": 0.95207101}, {"transcript": "confidence nil 1"}, {"transcript": "confidence nil 2"}], "final": true}], "result_index": 0}
              {"result": [{"alternative": [{"transcript": "confidence no.1", "confidence": 0.99999999}, {"transcript": "confidence nil 3"}, {"transcript": "confidence nil 4"}], "final": true}], "result_index": 1}
            BODY
          end

          it do 
            expect{|block| subject.ensure_upload &block }.to yield_with_args "confidence no.1", Array
          end
        end

        context "when no confidences" do
          let(:body) do
            <<-BODY
              {"result": []}
              {"result": [{"alternative": [{"transcript": "confidence no.2"}, {"transcript": "confidence nil 1"}, {"transcript": "confidence nil 2"}], "final": true}], "result_index": 0}
              {"result": [{"alternative": [{"transcript": "confidence no.1"}, {"transcript": "confidence nil 3"}, {"transcript": "confidence nil 4"}], "final": true}], "result_index": 1}
            BODY
          end

          it do 
            expect{|block| subject.ensure_upload &block }.to yield_with_args "confidence no.2", Array
          end
        end
      end
    end

  end

  describe :privates do
    subject{ GoogleSpeechV2::SpeechToText.new }
    describe :ensure_temp_path do
      it do
        expect{|block| subject.send :ensure_temp_path, &block }.to yield_with_args(String)
      end
    end

    describe :ensure_flac_path do 
      before{ allow(Kernel).to receive(:system) }
      it do
        expect{|block| subject.send :ensure_flac_path, &block }.to yield_with_args(String)
      end

      describe "ensure_flac_path system call" do
        describe :duration do 
          before do 
            GoogleSpeechV2::Config.duration_in_sec = 7
            expect(Kernel).to receive(:system).with(/-d 7/)
          end
          it{ subject.send(:ensure_flac_path){} }
        end

        describe :rate do 
          before do 
            expect(Kernel).to receive(:system).with(/--sample-rate 44100/)
          end
          it{ subject.send(:ensure_flac_path){} }
        end

        describe :output_path do 
          before do 
            expect(Kernel).to receive(:system).with(/-o .+/)
          end
          it{ subject.send(:ensure_flac_path){} }
        end
      end

    end

  end
end
