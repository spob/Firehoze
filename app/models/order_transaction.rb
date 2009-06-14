# An order transaction contains detailed information specific to the parameters passed and the results
# returned from the interaction with the credit card gateway via the ActiveMerchant api. It is useful
# for diagnosing what happened during that interaction, and follows the design suggested by
# Ryan Bates: http://railscasts.com/episodes/145-integrating-active-merchant
class OrderTransaction < ActiveRecord::Base
  belongs_to :order
  serialize :params

  def response=(response)
    self.success = response.success?
    self.authorization = response.authorization
    self.message = response.message
    self.params = response.params
  rescue ActiveMerchant::ActiveMerchantError => e
    self.success = false
    self.authorization = nil
    self.message = e.message
    self.params = {}
  end
end
