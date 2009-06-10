require 'spec_helper'

describe ActiveUrl do
  before(:each) do
    ActiveUrl::Config.stub!(:secret).and_return("secret")
  end
  
  context "instance" do
    before(:each) do
      @url = ActiveUrl::Base.new
    end
    
    it "should have nil id" do
      @url.id.should be_nil
    end
  
    it "should be a new_record" do
      @url.should be_new_record
    end
    
    it "should be saveable" do
      @url.save.should be_true
    end
  
    context "after saving" do
      before(:each) do
        @url.save
      end
    
      it "should have an id" do
        @url.id.should_not be_blank
      end
      
      it "should not be a new record" do
        @url.should_not be_new_record
      end
    end
  end
  
  context "derived" do
    before(:all) do  
      class ::DerivedClass < ActiveUrl::Base
        attribute :foo, :bar
        attribute :baz, :accessible => true
        attr_accessible :bar
          
        attr_accessor :x, :y
        attr_accessible :y
      end
    end
    
    context "instance" do
      it "should have individually accessible attribute readers" do
        @url = DerivedClass.new
        [ :foo, :bar, :baz ].each { |reader| @url.public_methods.map(&:to_sym).should include(reader) }
      end

      it "should have individually accessible attribute setters" do
        @url = DerivedClass.new
        [ :foo=, :bar=, :baz= ].each { |setter| @url.public_methods.map(&:to_sym).should include(setter) }
      end
      
      it "should not mass-assign attributes by default" do
        @url = DerivedClass.new(:foo => "foo")
        @url.foo.should be_nil
      end
    
      it "should mass-assign attributes declared as attr_accessible" do
        @url = DerivedClass.new(:bar => "bar")
        @url.bar.should == "bar"
      end
    
      it "should mass-assigned attributes with :accessible specified on declaration" do
        @url = DerivedClass.new(:baz => "baz")
        @url.baz.should == "baz"
      end

      it "should not mass-assign virtual attributes by default" do
        @url = DerivedClass.new(:x => "x")
        @url.x.should be_nil
      end
    
      it "should mass-assign its accessible virtual attributes" do
        @url = DerivedClass.new(:y => "y")
        @url.y.should == "y"
      end
      
      it "should know its mass-assignable attribute names" do
        @url = DerivedClass.new
        [ :bar, :baz, :y ].each { |name| @url.accessible_attributes.should     include(name) }
        [ :foo, :x       ].each { |name| @url.accessible_attributes.should_not include(name) }
      end
      
      it "should know its attribute names" do
        @url = DerivedClass.new
        [ :foo, :bar, :baz ].each { |name| @url.attribute_names.should     include(name) }
        [ :x, :y           ].each { |name| @url.attribute_names.should_not include(name) }
      end
      
      context "equality" do
        before(:all) do
          class ::OtherClass < DerivedClass
          end
        end
        
        it "should be based on class and attributes only" do
          @url  = DerivedClass.new(:bar => "bar", :baz => "baz")
          @url2 = DerivedClass.new(:bar => "bar", :baz => "baz")
          @url3 = DerivedClass.new(:bar => "BAR", :baz => "baz")
          @url4 =   OtherClass.new(:bar => "bar", :baz => "baz")
          @url.should == @url2
          @url.should_not == @url3
          @url.should_not == @url4
        end
      end
    end
    
    context "class" do
      it "should know its mass-assignable attribute names" do
        [ :bar, :baz, :y ].each { |name| DerivedClass.accessible_attributes.should     include(name) }
        [ :foo, :x       ].each { |name| DerivedClass.accessible_attributes.should_not include(name) }
      end
      
      it "should know its attribute names" do
        [ :foo, :bar, :baz ].each { |name| DerivedClass.attribute_names.should     include(name) }
        [ :x, :y           ].each { |name| DerivedClass.attribute_names.should_not include(name) }
      end
    end
  end
end
