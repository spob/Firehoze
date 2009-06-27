require File.dirname(__FILE__) + '/base'

describe HttpClient::Response do
  before do
    @net_http_res = mock('net http response')
    @response = HttpClient::Response.new('abc', @net_http_res)
  end

  it "behaves like string" do
    @response.should == 'abc'
  end

  it "accepts nil strings and sets it to empty for the case of HEAD" do
    HttpClient::Response.new(nil, @net_http_res).should == ""
  end
end
