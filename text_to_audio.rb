require 'net/http'
require 'uri'
require 'openssl'

def convert_text_to_speech(text)
  url = URI.parse("https://azure.dev.moemate.io")
  auth_token = TOKEN
  output_format = "audio-48khz-192kbitrate-mono-mp3"

  http = Net::HTTP.new(url.host, url.port)
  http.use_ssl = true
  http.verify_mode = OpenSSL::SSL::VERIFY_NONE

  request = Net::HTTP::Post.new(url)
  request['Content-Type'] = 'application/ssml+xml'
  request['WebaAuth'] = "Bearer #{auth_token}"
  request['X-Microsoft-OutputFormat'] = output_format

  post_data = "
    <speak xmlns='http://www.w3.org/2001/10/synthesis' xmlns:mstts='http://www.w3.org/2001/mstts' xmlns:emo='http://www.w3.org/2009/10/emotionml' version='1.0' xml:lang='en-US'>
      <voice name='en-US-JennyNeural'>
        <mstts:viseme type='FacialExpression'/>
        <mstts:express-as style='assistant'>
          <prosody rate='15%' pitch='15%'>
            <lang xml:lang='en-US'>#{text}</lang>
          </prosody>
        </mstts:express-as>
      </voice>
    </speak>
  "

  request.body = post_data

  response = http.request(request)

  if response.code == "200"
    audio_file_path = "output_file_#{Time.now.to_i}.mp3"
    File.open(audio_file_path, "wb") do |file|
      file.write(response.body)
    end
    puts "Audio file saved at: #{audio_file_path}"
    audio_file_path
  else
    puts "Error: #{response.message}"
    nil
  end
end
