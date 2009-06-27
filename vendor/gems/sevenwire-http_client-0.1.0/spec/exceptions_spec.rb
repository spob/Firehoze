require File.dirname(__FILE__) + '/base'

describe HttpClient::Exception do
  it "sets the exception message to ErrorMessage" do
    HttpClient::ServerBrokeConnection.new.message.should == 'Server broke connection'
  end

  it "contains exceptions in HttpClient" do
    HttpClient::ServerBrokeConnection.new.should be_a_kind_of(HttpClient::Exception)
    HttpClient::RequestTimeout.new.should be_a_kind_of(HttpClient::Exception)
  end
end
