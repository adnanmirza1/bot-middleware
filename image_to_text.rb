require 'net/http'
require 'uri'
require 'json'
require 'byebug'

def get_image_tags(blob)
  uri = URI.parse('https://ai.dev.moemate.io/api/ram/t2t')
  
  fd = {}
  fd['tags'] = 'image'
  fd['img'] = File.open(blob, 'rb')
  
  request = Net::HTTP::Post.new(uri)
  request['WebaAuth'] = TOKEN
  request['WebaHost'] = 'ram.dev.moemate.io'
  request['Access-Control-Allow-Origin'] = '*'
  request['Access-Control-Allow-Methods'] = 'GET, POST, PUT, DELETE'
  request['Access-Control-Allow-Headers'] = 'Content-Type, Authorization'
  request.set_form(fd, 'multipart/form-data')
  
  response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == 'https') do |http|
    http.request(request)
  end
  
  puts 'RAM response:', response.body
  
  if response.is_a?(Net::HTTPSuccess)
    responseData = JSON.parse(response.body)
    return responseData
  else
    errorData = JSON.parse(response.body)
    puts 'Error in RAM response:', errorData
    return errorData
  end
end
