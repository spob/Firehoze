require 'spec_helper'

describe ActiveUrl do
  before(:each) do
    ActiveUrl::Config.stub!(:secret).and_return("secret")
  end
  
  context "instance with belongs_to association" do
    before(:all) do    
      # a simple pretend-ActiveRecord model for testing belongs_to without setting up a db:
      class ::User < ActiveRecord::Base
        def self.columns() @columns ||= []; end
        def self.column(name, sql_type = nil, default = nil, null = true)
          columns << ActiveRecord::ConnectionAdapters::Column.new(name.to_s, default, sql_type.to_s, null)
        end
      end
    
      class ::Secret < ActiveUrl::Base
        belongs_to :user
      end
    end
    
    before(:each) do
      @url = Secret.new
      @user = User.new
      @user.stub!(:id).and_return(1)
    end
    
    it "should raise ArgumentError if the association name is not an ActiveRecord class" do
      lambda { Secret.belongs_to :foo }.should raise_error(ArgumentError)
    end
    
    it "should respond to association_id, association_id=, association & association=" do
      @url.attribute_names.should include(:user_id)
      @url.should respond_to(:user)
      @url.should respond_to(:user=)
    end
    
    it "should have nil association if association or association_id not set" do
      @url.user.should be_nil
    end
    
    it "should not allow mass assignment of association_id" do
      @url = Secret.new(:user_id => @user.id)
      @url.user_id.should be_nil
      @url.user.should be_nil
    end
    
    it "should not allow mass assignment of association" do
      @url = Secret.new(:user => @user)
      @url.user_id.should be_nil
      @url.user.should be_nil
    end
    
    it "should be able to have its association set to nil" do
      @url.user_id = @user.id
      @url.user = nil
      @url.user_id.should be_nil
    end
    
    it "should raise ArgumentError if association is set to wrong type" do
      lambda { @url.user = Object.new }.should raise_error(TypeError)
    end
      
    it "should find its association_id if association is set" do
      @url.user = @user
      @url.user_id.should == @user.id
    end
    
    it "should find its association if association_id is set" do
      User.should_receive(:find).with(@user.id).and_return(@user)
      @url.user_id = @user.id
      @url.user.should == @user
    end
    
    it "should return nil association if association_id is unknown" do
      User.should_receive(:find).and_raise(ActiveRecord::RecordNotFound)
      @url.user_id = 10
      @url.user.should be_nil
    end
    
    it "should know its association when found by id" do
      User.should_receive(:find).with(@user.id).and_return(@user)
      @url.user_id = @user.id
      @url.save
      @found = Secret.find(@url.id)
      @found.user.should == @user
    end
  end
end
