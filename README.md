# Google Speech API v2 gem

This gem lets you record your voice from microphone (for a fixed amount of seconds) and gets you back with the voice text.

## References
* https://github.com/gillesdemey/google-speech-v2
* http://www.chromium.org/developers/how-tos/api-keys
* https://aminesehili.wordpress.com/2015/02/08/on-the-use-of-googles-speech-recognition-api-version-2/


## Prerequisites

1. ruby2
2. both `arecord` and `flac` commands  
   originally meant to use on Raspberry Pi... you don't have `arecord` on OSX. 
3. create a project at https://console.developers.google.com
4. enable Speech API  
   1. read http://www.chromium.org/developers/how-tos/api-keys if you can't find Speech API
   2. [subscribe](https://groups.google.com/a/chromium.org/forum/?fromgroups#!forum/chromium-dev) to chromium-dev and choose not to receive mail
   3. go back to google developer's console and add Speech API
5. create a key
   1. go to credentials
   2. create new
   3. choose API key
   4. choose browser key
   5. and you get a key to use APIs



## Installation

Add this line to your application's Gemfile:

```ruby
gem 'google_speech_v2', git: "https://github.com/github0013/google_speech_v2.git"
```

And then execute:

    $ bundle


## Usage

### configs
```ruby
require "google_speech_v2"

# make sure you set your API KEY before using
GoogleSpeechV2::Config.api_key = "__YOUR_KEY_HERE__"

# available list -> GoogleSpeechV2.available_lang_list
GoogleSpeechV2::Config.lang = "en-us" # default, the language you speak

# you have to speak within the seconds. MAX 10-15secs.
GoogleSpeechV2::Config.duration_in_sec = 5 # default, fixed recording time.  
```

### usage.1 setup a block then call it on demand
```ruby
GoogleSpeechV2.speech_to_text_block do |text, raw|
  puts text
  p raw
end

# this will call the block above when done
GoogleSpeechV2.speech_to_text # blocks till recording ends
```

### usage.2 set a block on call
```ruby
# blocks till recording ends
GoogleSpeechV2.speech_to_text do |text, raw|
  puts text
  p raw
end
```

### usage.3 set lang or/and duration_in_sec on call
```ruby
GoogleSpeechV2.speech_to_text(lang: "ja-JP", duration_in_sec: 3) do |text, raw|
  puts text
  p raw
end
```


## Testing

```bash
# you need to setup your API key if you want to run spec files
# create .env file at this gem's root directory (where Gemfile is)
echo "API_KEY=__YOUR_KEY_HERE__" > .env
```
