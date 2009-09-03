module PaymentsHelper
  def round_to_penny amount
    amount = (amount * 100.0).floor
    amount/100.0
  end
end
