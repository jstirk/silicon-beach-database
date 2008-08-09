require 'zlib'
# Intended to extend the Net::HTTP response object
# and adds support for decoding gzip and deflate encoded pages
# Author: Jason Stirk <http://griffin.oobleyboo.com>
# Created: 5 September 2007
# Usage:
#
# require 'net/http'
# require 'http_encoding_helper'
# headers={'Accept-Encoding' => 'gzip, deflate' }
# http = Net::HTTP.new('http://griffin.oobleyboo.com/', 80)
# http.start do |h|
#   request = Net::HTTP::Get.new('/feed.rss', headers)
#   response = http.request(request)
#   response=response.extend(HTTPEncodingHelper)
#   content=response.plain_body  
# end
	
module HTTPEncodingHelper
  def plain_body
    encoding=self.to_hash['content-encoding']
    content=nil
    if encoding then
      encoding=encoding.join('')
      case encoding
        when 'gzip'
          i=Zlib::GzipReader.new(StringIO.new(self.body))
          content=i.read
        when 'deflate'
          i=Zlib::Inflate.new
          content=i.inflate(self.body)
        else
          raise "Unknown encoding - #{encoding}"
      end
    else
      content=self.body
    end
    return content
  end
end
