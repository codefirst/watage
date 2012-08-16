require 'net/https'
require 'uri'

module HTTPUtil
  def https_put(uri, file, headers={}, boundary="A300x")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.start do
      request = Net::HTTP::Put.new(uri.path, headers)
      request.set_content_type "multipart/form-data; boundary=#{boundary}"
      request.body = "#{file.read}"
      http.request request
    end        
  end

  def https_post(uri, headers={}, params={})
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    data = params.keys.map{|k| "#{k}=#{params[k]}"}.join "&"
    http.post(uri.path, data, headers)
  end

  def post_multipart(uri, file, boundary="A300x")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.start do
      request = Net::HTTP::Post.new(uri.path + "?" + (uri.query || ""))
      request.set_content_type "multipart/form-data; boundary=#{boundary}"
      body = "--#{boundary}\r\n"
      body += "Content-Disposition: form-data; name=\"file\"; filename=\"#{file.original_filename}\"\r\n"
      body += "Content-Type: #{file.content_type}\r\n"
      body += "\r\n"
      body += "#{file.read}\r\n"
      body += "\r\n"
      body += "--#{boundary}--\r\n"
      request.body = body
      http.request request
    end
  end
end
