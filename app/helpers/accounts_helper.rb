module AccountsHelper
  include ApplicationHelper

  def instructor_wizard_breadcrumbs(step)
    link_text("#{t('lesson.instructor').capitalize}'s Agreement", 1, step,
      @user.author_agreement_accepted_on, instructor_wizard_step1_account_path(@user)) +
      "\n\t" +

      link_text("Exclusivity", 2, step,
      (@user.author_agreement_accepted_on and @user.payment_level),
      instructor_wizard_step2_account_path(@user)) +
      "\n\t" +

      link_text("Postal Address", 3, step,
      (@user.author_agreement_accepted_on and @user.payment_level),
      instructor_wizard_step3_account_path(@user)) +
      "\n\t" +

      link_text("Confirm Contact Information", 4, step,
      (@user.address_provided? and @user.author_agreement_accepted_on and @user.payment_level),
      instructor_wizard_step4_account_path(@user)) +
      "\n\t" +

      link_text("Tax Withholding", 5, step,
      (@user.address_provided? and @user.author_agreement_accepted_on and @user.payment_level and @user.verified_address_on and @user.verified_address_on),
      instructor_wizard_step5_account_path(@user))
  end

  def formatted_address(newline_character = "\n")
    user_formatted_address(@user, newline_character)
  end

  private

  def link_text(text, text_step, step, enabled, url)
    if text_step == step or !enabled
      content_tag(:li, text)
    else
      content_tag(:li, link_to(text, url))
    end
  end
end
