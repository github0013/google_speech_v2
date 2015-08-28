$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'google_speech_v2'
require 'dotenv'

Dotenv.load

require 'vcr'
VCR.configure do |c|
  c.cassette_library_dir = 'spec/vcr_cassettes'
  c.hook_into :webmock # or :fakeweb
  c.allow_http_connections_when_no_cassette = true
end

RSpec.configure do |config|

  config.filter_run :focus
  config.run_all_when_everything_filtered = true
  config.order = :random

end