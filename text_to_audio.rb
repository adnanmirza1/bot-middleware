require 'net/http'
require 'uri'
require 'openssl'

def convert_text_to_speech(text)
  url = URI.parse("https://azure.dev.moemate.io")
  auth_token = "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IlMzLUstVWhieEtHYnExbF8tbEloMiJ9.eyJhcHBfbWV0YWRhdGEiOnsic3RyaXBlX2N1c3RvbWVyX2lkIjoiY3VzX1BsdEFmTEdmZHFDU1BiIiwic3ViX3N0YXR1cyI6InBybyIsInVzZXJuYW1lIjoiVGVzdCBEZXYifSwibmlja25hbWUiOiJ0ZXN0ZGV2MCIsIm5hbWUiOiJ0ZXN0ZGV2MEBnbWFpbC5jb20iLCJwaWN0dXJlIjoiaHR0cHM6Ly9zLmdyYXZhdGFyLmNvbS9hdmF0YXIvOTViMTljNWI1ODBhOTVjNjk5YTQ2ODg3OWE4MmUwYTQ_cz00ODAmcj1wZyZkPWh0dHBzJTNBJTJGJTJGY2RuLmF1dGgwLmNvbSUyRmF2YXRhcnMlMkZ0ZS5wbmciLCJ1cGRhdGVkX2F0IjoiMjAyNC0wMy0yMFQxODoxNjo0MS42ODZaIiwiZW1haWwiOiJ0ZXN0ZGV2MEBnbWFpbC5jb20iLCJlbWFpbF92ZXJpZmllZCI6ZmFsc2UsImlzcyI6Imh0dHBzOi8vbW9lbWF0ZS1kZXYudXMuYXV0aDAuY29tLyIsImF1ZCI6IlIzOTBCNFNMdnA2OTRTWmN4T2NEYk1Pd3NFdDd0ZWJBIiwiaWF0IjoxNzExMDk5MTI4LCJleHAiOjE3MTExMzUxMjgsInN1YiI6ImF1dGgwfDY1Zjg3N2I5NWMyY2QxNGNmYmQzMDU1NyIsInNpZCI6Ii1SSW5aUnBUdlpuTWhaTk0zQlpaRG8zRjNCTGY2UTh6In0.KjsDhC3Ou58mjN0inWf_4VJJ-vUjOTZnfia1KreTNm0odDAivi6VOUVCr79Wa_m2R4vaChTrqJvwmEII-5rWtGgH1YpiKBKSOzMqcpui0x_sjHHH9BV6-Dm1Wg7d84P5w9k1bbRki_CzX7-u5hLZFBFzQPGHET0z0DWK5v0i3Tz6g38eCitjXoq4cdOsXxpu-HtOtXJ1_PwfkWp7fIFBzqLYladOgVniu-dlJFQIJ94Jgsvb44fQcSiYr21sCYipNtMzLfqN4tLGa3y7FRO-YdBq7122s24aMQQb8TdOrIvnOVwgMFP46b-MRMjzPKjTd9IKOFjXGbMKNIMRkKECUw"
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
  puts response
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
