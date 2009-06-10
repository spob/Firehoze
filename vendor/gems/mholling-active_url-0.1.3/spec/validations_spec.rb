require 'spec_helper'

describe ActiveUrl do
  before(:each) do
    ActiveUrl::Config.stub!(:secret).and_return("secret")
  end
  
  context "instance with validations" do
    before(:all) do
      class ::Registration < ActiveUrl::Base  
        attribute :name, :email, :password, :age, :accessible => true
        validates_presence_of :name
        validates_format_of :email, :with => /^[\w\.=-]+@[\w\.-]+\.[a-zA-Z]{2,4}$/ix
        validates_length_of :password, :minimum => 8
        validates_numericality_of :age
        after_save :send_registration_email
      
        def send_registration_email
          @sent = true
        end
      end
    end
    
    context "when invalid" do
      before(:each) do
        @registration = Registration.new(:email => "user @ example . com", :password => "short", :age => "ten")
      end
      
      it "should not validate" do
        @registration.should_not be_valid
      end
  
      it "should not save" do
        @registration.save.should_not be_true
        @registration.id.should be_nil
      end

      it "should raise ActiveUrl::InvalidRecord when saved with bang" do
        lambda { @registration.save! }.should raise_error(ActiveUrl::RecordInvalid)
      end
      
      context "and saved" do
        before(:each) do
          @registration.save
        end

        it "should have errors" do
          @registration.errors.should_not be_empty
        end
        
        it "should validate presence of an attribute" do
          @registration.errors[:name].should_not be_blank
        end
        
        it "should validate format of an attribute" do
          @registration.errors[:email].should_not be_blank
        end
        
        it "should validate length of an attribute" do
          @registration.errors[:password].should_not be_nil
        end
        
        it "should validate numericality of an attribute" do
          @registration.errors[:age].should_not be_nil
        end
        
        it "should not execute any after_save callbacks" do
          @registration.instance_variables.should_not include("@sent")
        end
      end
    end
    
    context "when valid" do
      before(:each) do
        @registration = Registration.new(:name => "John Doe", :email => "user@example.com", :password => "password", :age => "10")
      end
      
      it "should validate" do
        @registration.should be_valid
      end
      
      context "and saved" do
        before(:each) do
          @registration.save
        end
        
        it "should have an id" do
          @registration.id.should_not be_blank
        end
        
        it "should have a param equal to its id" do
          @registration.id.should == @registration.to_param
        end
        
        it "should execute any after_save callbacks" do
          @registration.instance_variables.map(&:to_s).should include("@sent")
        end
        
        context "and re-found by its class" do
          before(:each) do
            @found = Registration.find(@registration.id)
          end
          
          it "should exist" do
            @found.should_not be_nil
          end
          
          it "should have the same id" do
            @found.id.should == @registration.id
          end
          
          it "should have the same attributes" do
            @found.attributes.should == @registration.attributes
          end
          
          it "should be valid" do
            @found.should be_valid
          end
        end
        
        context "and subsequently made invalid" do
          before(:each) do
            @registration.password = "short"
            @registration.stub!(:valid?).and_return(true)
            @registration.save
          end
                              
          it "should not be found by its class" do
            @registration.id.should_not be_blank
            lambda { Registration.find(@registration.id) }.should raise_error(ActiveUrl::RecordNotFound)
          end
        end
      end
    end
    
    it "should raise ActiveUrl::RecordNotFound if id does not exist" do
      lambda { Registration.find("blah") }.should raise_error(ActiveUrl::RecordNotFound)
    end
  end
end
