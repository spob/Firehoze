module HttpClient
  # This is the base HttpClient exception class. Rescue it if you want to
  # catch any exception that your request might raise
  class Exception < StandardError
    def message(default=nil)
      self.class::ErrorMessage
    end
  end

  # Base HttpClient exception when there's a response available
  class ExceptionWithResponse < Exception
    attr_accessor :response

    def initialize(response=nil)
      @response = response
    end

    def http_code
      @response.code.to_i if @response
    end
  end

  # The server broke the connection prior to the request completing.  Usually
  # this means it crashed, or sometimes that your network connection was
  # severed before it could complete.
  class ServerBrokeConnection < Exception
    ErrorMessage = 'Server broke connection'
  end

  # The server took too long to respond.
  class RequestTimeout < Exception
    ErrorMessage = 'Request timed out'
  end

  # The server refused the connection
  class ConnectionRefused < Exception
    ErrorMessage = 'Server refused connection'
  end
end
