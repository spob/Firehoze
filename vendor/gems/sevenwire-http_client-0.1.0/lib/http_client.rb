require 'uri'
require 'net/https'
require 'zlib'
require 'stringio'

require File.dirname(__FILE__) + '/http_client/request'
require File.dirname(__FILE__) + '/http_client/mixin/response'
require File.dirname(__FILE__) + '/http_client/response'
require File.dirname(__FILE__) + '/http_client/raw_response'
require File.dirname(__FILE__) + '/http_client/resource'
require File.dirname(__FILE__) + '/http_client/exceptions'

# This module's static methods are the entry point for using the HTTP client.
#
#   # GET
#   xml = HttpClient.get 'http://example.com/resource'
#   jpg = HttpClient.get 'http://example.com/resource', :accept => 'image/jpg'
#
#   # authentication and SSL
#   HttpClient.get 'https://user:password@example.com/private/resource'
#
#   # POST or PUT with a hash sends parameters as a urlencoded form body
#   HttpClient.post 'http://example.com/resource', :param1 => 'one'
#
#   # nest hash parameters
#   HttpClient.post 'http://example.com/resource', :nested => { :param1 => 'one' }
#
#   # POST and PUT with raw payloads
#   HttpClient.post 'http://example.com/resource', 'the post body', :content_type => 'text/plain'
#   HttpClient.post 'http://example.com/resource.xml', xml_doc
#   HttpClient.put 'http://example.com/resource.pdf', File.read('my.pdf'), :content_type => 'application/pdf'
#
#   # DELETE
#   HttpClient.delete 'http://example.com/resource'
#
#   # retreive the response http code and headers
#   res = HttpClient.get 'http://example.com/some.jpg'
#   res.code                    # => 200
#   res.headers[:content_type]  # => 'image/jpg'
#
#   # HEAD
#   HttpClient.head('http://example.com').headers
#
# To use with a proxy, just set HttpClient.proxy to the proper http proxy:
#
#   HttpClient.proxy = "http://proxy.example.com/"
#
# Or inherit the proxy from the environment:
#
#   HttpClient.proxy = ENV['http_proxy']
#
# For live tests of HttpClient, try using http://http-test.heroku.com, which echoes back information about the http call:
#
#   >> HttpClient.put 'http://http-test.heroku.com/resource', :foo => 'baz'
#   => "PUT http://http-test.heroku.com/resource with a 7 byte payload, content type application/x-www-form-urlencoded {\"foo\"=>\"baz\"}"
#
module HttpClient
  def self.get(url, headers={})
    Request.execute(:method => :get, :url => url, :headers => headers)
  end

  def self.post(url, payload, headers={})
    Request.execute(:method => :post, :url => url, :payload => payload, :headers => headers)
  end

  def self.put(url, payload, headers={})
    Request.execute(:method => :put, :url => url, :payload => payload, :headers => headers)
  end

  def self.delete(url, headers={})
    Request.execute(:method => :delete, :url => url, :headers => headers)
  end

  def self.head(url, headers={})
    Request.execute(:method => :head, :url => url, :headers => headers)
  end

  class << self
    attr_accessor :proxy
  end

  # Print log of HttpClient calls.  Value can be stdout, stderr, or a filename.
  # You can also configure logging by the environment variable HTTPCLIENT_LOG.
  def self.log=(log)
    @@log = log
  end

  def self.log    # :nodoc:
    return ENV['HTTPCLIENT_LOG'] if ENV['HTTPCLIENT_LOG']
    return @@log if defined? @@log
    nil
  end
end
