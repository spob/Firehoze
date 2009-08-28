module AccountsHelper
  def done_text(done)
    t("user.#{done ? '' : 'not_'}done")
  end

  def done_color(done)
    if done
      "style='color: green;'"
    else
      "style='color: red;'"
    end
  end

  def formatted_address newline_character = "\n"
    "#{@user.address1}#{newline_character}#{@user.address2 + newline_character unless (@user.address2.nil? or @user.address2.empty?)}#{@user.city}, #{@user.state} #{@user.postal_code}#{newline_character}#{I18n.t(@user.country, :scope => 'countries')}"
  end

  private

  def completed yes_no
    (yes_no ? "Complete" : "Incomplete")
  end
end
