require 'spec_helper'

describe ActiveUrl do
  before(:each) do
    ActiveUrl::Config.stub!(:secret).and_return("secret")
  end
  
  describe "crypto" do
    it "should raise ArgumentError when no secret is set" do
      ActiveUrl::Config.stub!(:secret).and_return(nil)
      lambda { ActiveUrl::Crypto.encrypt("clear") }.should raise_error(ArgumentError)
    end
  
    it "should decode what it encodes" do
      ActiveUrl::Crypto.decrypt(ActiveUrl::Crypto.encrypt("clear")).should == "clear"
    end
  
    it "should always yield URL-safe output characters" do
      url_safe = /^[\w\-]*$/
      (1..20).each do |n|
        clear = (0...8).inject("") { |string, n| string << rand(255).chr } # random string
        cipher = ActiveUrl::Crypto.encrypt(clear)
        cipher.should =~ url_safe
      end
    end
  end
end
