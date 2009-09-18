require File.dirname(__FILE__) + '/../../test_helper'

class ApplicationHelperTest < ActionView::TestCase
  context "with raw text" do
    setup { @raw_text = "This is a test" }

    should "italics text" do
      assert_equal @raw_text, italics(@raw_text, false)
      assert_equal "<em>#{@raw_text}</em>", italics(@raw_text, true)
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
and so are these
* one
* two
* three

and that's the end
END
      @formatted_raw_text = <<END
<p>These are bullets
<br />and so are these
<ul><li>one</li>
<li>two</li>
<li>three</li></ul></p>

<p>and that's the end
</p>
END
    end

    should 'bulletize text' do
      assert_equal @formatted_raw_text.rstrip, rbs_formatter(@raw_text)
    end
  end

  context "with embedded hyperlinks and bold and italics" do
    setup do
      @raw_text = "this *is* link http://www.google.com _yes_!"
      @formatted_raw_text =
"<p>this <b>is</b> link <a href=\"http://www.google.com\">http://www.google.com</a> <i>yes</i>!</p>"
    end

    should 'bulletize text' do
      assert_equal @formatted_raw_text, rbs_formatter(@raw_text)
    end
  end

  context "testing flag_link" do
    should "show flag link" do
      
    end
  end
end
