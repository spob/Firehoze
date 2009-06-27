require File.dirname(__FILE__) + '/base'

describe HttpClient do
  describe "API" do
    it "GET" do
      HttpClient::Request.should_receive(:execute).with(:method => :get, :url => 'http://some/resource', :headers => {})
      HttpClient.get('http://some/resource')
    end

    it "POST" do
      HttpClient::Request.should_receive(:execute).with(:method => :post, :url => 'http://some/resource', :payload => 'payload', :headers => {})
      HttpClient.post('http://some/resource', 'payload')
    end

    it "PUT" do
      HttpClient::Request.should_receive(:execute).with(:method => :put, :url => 'http://some/resource', :payload => 'payload', :headers => {})
      HttpClient.put('http://some/resource', 'payload')
    end

    it "DELETE" do
      HttpClient::Request.should_receive(:execute).with(:method => :delete, :url => 'http://some/resource', :headers => {})
      HttpClient.delete('http://some/resource')
    end

    it "HEAD" do
      HttpClient::Request.should_receive(:execute).with(:method => :head, :url => 'http://some/resource', :headers => {})
      HttpClient.head('http://some/resource')
    end
  end

  describe "logging" do
    after do
      HttpClient.log = nil
    end

    it "gets the log source from the HTTPCLIENT_LOG environment variable" do
      ENV.stub!(:[]).with('HTTPCLIENT_LOG').and_return('from env')
      HttpClient.log = 'from class method'
      HttpClient.log.should == 'from env'
    end

    it "sets a destination for log output, used if no environment variable is set" do
      ENV.stub!(:[]).with('HTTPCLIENT_LOG').and_return(nil)
      HttpClient.log = 'from class method'
      HttpClient.log.should == 'from class method'
    end

    it "returns nil (no logging) if neither are set (default)" do
      ENV.stub!(:[]).with('HTTPCLIENT_LOG').and_return(nil)
      HttpClient.log.should == nil
    end
  end
end
