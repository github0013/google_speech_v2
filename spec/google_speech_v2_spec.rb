require 'spec_helper'

describe GoogleSpeechV2 do
  before{ GoogleSpeechV2::Config.api_key = ENV["API_KEY"]}

  describe :speech_to_text_block do
    before{ GoogleSpeechV2.clear_speech_to_text_block }

    describe "setting a block" do
      it do
        expect{ GoogleSpeechV2.speech_to_text_block{} }.
          to change{ 
            GoogleSpeechV2.module_eval{ @block } 
          }.from(nil).to be_instance_of(Proc)
      end
    end
  end

  describe :available_lang_list do
    it{ expect(GoogleSpeechV2.available_lang_list).to be_instance_of Array }
  end

  describe :speech_to_text do
    before do
      allow(Kernel).to receive(:system)
      GoogleSpeechV2.clear_speech_to_text_block
    end

    context :block_given do 
      it do 
        VCR.use_cassette("GoogleSpeechV2::SpeechToText#ensure_upload - has key") do
          expect{|block| 
            GoogleSpeechV2.speech_to_text &block 
          }.to yield_with_args "good morning Google how are you feeling today", Array
        end
      end
    end

    context "no block given" do

      context "no speech_to_text_block set" do
        it do 
          expect{ GoogleSpeechV2.speech_to_text }.to raise_error GoogleSpeechV2::BlockNotSet
        end
      end

      context "speech_to_text_block set" do
        before do
          GoogleSpeechV2.speech_to_text_block{}
          expect( 
            GoogleSpeechV2.module_eval{ @block }
          ).to receive(:call).with("good morning Google how are you feeling today", Array)
        end

        it do 
          VCR.use_cassette("GoogleSpeechV2::SpeechToText#ensure_upload - has key") do
            expect{ GoogleSpeechV2.speech_to_text }.not_to raise_error
          end
        end

      end

    end
  end
end