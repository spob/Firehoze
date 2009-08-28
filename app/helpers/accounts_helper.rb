module AccountsHelper
  def author_progress
    "Address Information" 
  end

  private

  def completed yes_no
    (yes_no ? "Complete" : "Incomplete")
  end
end
