module AccountsHelper

  def instructor_wizard_breadcrumbs(step)
    link_text("Instructor Agreement", 1, step,
              @user.author_agreement_accepted_on, instructor_wizard_step1_account_path(@user)) +
            " > " +
            link_text("Exclusivity", 2, step,
                      (@user.author_agreement_accepted_on and @user.payment_level),
                      instructor_wizard_step2_account_path(@user)) +
            " > " +
            link_text("Postal Address", 3, step,
                      (@user.author_agreement_accepted_on and @user.payment_level),
                      instructor_wizard_step3_account_path(@user)) +
            " > " +
            link_text("Confirm Contact Information", 4, step,
                      (@user.address_provided? and @user.author_agreement_accepted_on and @user.payment_level),
                      instructor_wizard_step4_account_path(@user)) +
            " > " +
            link_text("Tax Witholding", 5, step,
                      (@user.address_provided? and @user.author_agreement_accepted_on and @user.payment_level and @user.verified_address_on and @user.verified_address_on),
                      instructor_wizard_step5_account_path(@user))
  end

  def formatted_address newline_character = "\n"
    "#{@user.address1}#{newline_character}#{@user.address2 + newline_character unless (@user.address2.nil? or @user.address2.empty?)}#{@user.city}, #{@user.state} #{@user.postal_code}#{newline_character}#{I18n.t(@user.country, :scope => 'countries')}"
  end

  private
  
  def link_text text, text_step, step, enabled, url
    if text_step == step or !enabled
      bold(italics(text, text_step < step), text_step == step)
    else
      italics(link_to(text, url), text_step < step)
    end
  end
end
