require 'rest-client'

class HTTPUtil
  def HTTPUtil.https_put(uri, file, headers={})
    RestClient.put uri.to_s, { "upload[file]" => file }, headers
  end

  def HTTPUtil.https_post(uri, headers={}, params={})
    data = params.keys.map{|k| "#{k}=#{params[k]}"}.join "&"
    RestClient.post uri.to_s, data, headers
  end

  def HTTPUtil.post_multipart(uri, file)
    RestClient.post uri.to_s, { "upload[file]" => file }
  end
end
