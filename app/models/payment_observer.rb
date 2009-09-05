class PaymentObserver < ActiveRecord::Observer
  def after_create(payment)
    RunOncePeriodicJob.create!(
              :name => 'Payment Notificaiton',
              :job => "Notifier.deliver_payment_notification #{payment.id}")
  end
end