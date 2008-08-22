require 'net/http'
require 'net/https'
require 'http_encoding_helper'

# Silicon Beach Australia Module
# Authors:
#   Jason Stirk <jstirk@gmail.com>

module SBA

  USER_AGENT='Silicon Beach Australia (http://www.siliconbeachaustralia.org/)'

  # Performs a request for a remote URI, optionally using If-Modified-Since
  # header. Method handles gzip encoding, and follows redirects to a maximum
  # depth as specified.
  # Returns a hash of the following :
  #  { :status => status code (eg. 200),
  #    :content => server response,
  #    :headers => reponse headers,
  #    :final_uri => the URI finally returned. Useful after redirects.
  #  }
  # If the content hasn't been modified since the data provided, status
  # will reflect this (eg. 304) and content will contain nil.
  # Options:
  #   :last_modified => time that the URI was last requested
  #   :max_depth => Maximum number of redirects to follow. Defaults to 20.
  #   :skip_head => Set to TRUE to make a GET without the HEAD first. Disables
  #                 checking with If-Modified-Since. 
  #                 Defaults to FALSE (HEAD request before GET)
  # Raises exceptions on any responses that don't get us closer to data.
  # That is, only 200 OK, 301 302 307 Redirects and 304 Not Modified are
  # handled. Anything else will throw and exception.
  def self.request(uri, options={})
    # TODO: Check the options better and warn on unsupported options
    last_modified=options[:last_modified] || nil
    max_depth=options[:max_depth] || 20
    if !options[:skip_head].nil? then
      skip_head=options[:skip_head]
    else
      skip_head=false
    end
    
    # Parse our URL, as this makes it trivial to support https connections
    # or connections with weird ports in the URL.
    puri=URI.parse(uri)
    raise 'Bad URL' if puri.host.nil? or puri.port.nil?
    
    http = Net::HTTP.new(puri.host, puri.port)
    http.use_ssl=(puri.scheme == 'https')
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    # Prepare the headers that we'll send in the request    
    headers={ 'User-Agent' => USER_AGENT, 'Accept-Encoding' => 'gzip, deflate' }
    
    # Add the If-Modified-Since header if we have relevant data
    headers['If-Modified-Since']=last_modified.rfc2822 if last_modified
    
    return_data={}
      
    http.start do |h|
      query="?#{query}" unless puri.query.nil?
      if skip_head then
        request = Net::HTTP::Get.new("#{puri.path}#{query}", headers)
      else
        request = Net::HTTP::Head.new("#{puri.path}#{query}", headers)
      end
      
      response = http.request(request)
      return_data[:status]=response.code.to_i
      return_data[:headers]=response.to_hash
      return_data[:final_uri]=uri
      
      case response.code.to_i
        when 301, 302, 307
          # It's a redirect - recurse and follow it to our max depth - 1
          # However. If the max_depth is 1, we can't redirect any more, so
          # raise an exception/
          raise 'Too many redirects' if max_depth == 1
          options[:max_depth] = max_depth - 1
          
          # TODO: location is an array!?! Why!?!
          return request(response.to_hash['location'].first, options)
          
        when 304
          # It's not been modified since the last check.
          return_data[:content]=nil          
          return return_data
          
        when 200
          # Seems there's valid data there
          # If we've just run a HEAD request, we need to perform a GET.
          if !skip_head then
            # Recurse, but specify to "Skip HEAD"
            return request(uri, options.merge(:skip_head => true))
          else
            # We made a GET this request, so handle the content now.
            # Extend the response object with our helper which will
            # decode gzip and deflate content automagically.
            response=response.extend(HTTPEncodingHelper)
            return_data[:content]=response.plain_body
            return return_data
          end
          
        else
          # Unknown HTTP code
          raise "Unknown HTTP Status: #{response.code} #{response.msg}"
      end  
    end
  end
end
