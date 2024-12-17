class MarkCartAsAbandonedJob
  include Sidekiq::Job
  queue_as :default

  def perform(*args)
    mark_carts_as_abandoned

    delete_abandoned_carts
  end

  private

  def mark_carts_as_abandoned
    Cart.inactive_for(3.hours.ago).find_each do |cart|
      cart.update!(status: :abandoned)
    end
  end

  def delete_abandoned_carts
    Cart.abandoned_for(7.days.ago).find_each do |cart|
      cart.destroy!
    end
  end
end
