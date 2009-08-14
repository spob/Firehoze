require 'test_helper'

class ApplicationHelperTest < ActionView::TestCase
  context "with raw text" do
    setup { @raw_text = "This is a test" }

    should "italics text" do
      assert_equal @raw_text, italics(@raw_text, false)
      assert_equal "<i>#{@raw_text}</i>", italics(@raw_text, true)
    end

    should "strike_through text" do
      assert_equal @raw_text, strike_through(@raw_text, false)
      assert_equal "<strike>#{@raw_text}</strike>", strike_through(@raw_text, true)
    end
  end

  context "with long raw text" do
    setup do
      @raw_text = <<END
These are bullets
* one
* two
* three

and that's the end
END
      @formatted_raw_text = <<END
These are bullets
<ul><li>one</li>
<li>two</li>
<li>three</li></ul>

and that's the end
END
    end

    should 'bulletize text' do
      assert_equal @formatted_raw_text, mini_formatter(@raw_text)
    end
  end
end
