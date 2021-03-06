require File.dirname(__FILE__) + '/../test_helper'
require 'fast_context'

class RegistrationTest < ActiveSupport::TestCase

  fast_context "Computing hashes" do
    setup do
      @hash1 =  Registration.formatted_hash("test@example.com")
      @hash2 =  Registration.formatted_hash("test@example.com", "xxx", "yyy")
    end

    should "equate hashes" do
      assert Registration.match?("test@example.com", @hash1)
      assert !Registration.match?("test@example.com", @hash2)
      assert Registration.match?("test@example.com", @hash2, "xxx", "yyy")
      assert !Registration.match?("test@example.com", @hash1, "xxx", "yyy")
      assert !Registration.match?("test@example.com", @hash2, "xxx", "yy")
    end
  end
end
