require 'net/http'
require 'uri'
require 'json'

def get_image_tags(image_path, headers = {})
  url = URI.parse("http://alb-beta.dev.moemate.io/ram")
  model_id = "ram"

  begin
    # Prepare request
    form_data = { 'img' => File.open(image_path, 'rb') }
    request = Net::HTTP::Post.new(url)
    request['model_id'] = model_id
    headers.each { |key, value| request[key] = value }
    request.set_form form_data, 'multipart/form-data'

    # Set up HTTP connection
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = (url.scheme == 'https')

    # Send request
    response = http.request(request)

    # Check response
    if response.code == '200'
      result = JSON.parse(response.body)
      return result['tags']
    else
      raise "Failed to get image tags. Response code: #{response.code}"
    end
  rescue => e
    raise "Error: #{e.message}"
  end
end
