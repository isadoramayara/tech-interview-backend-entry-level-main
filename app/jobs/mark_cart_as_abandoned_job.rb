class MarkCartAsAbandonedJob
  include Sidekiq::Job
  queue_as :default

  def perform(*args)
    mark_carts_as_abandoned

    delete_abandoned_carts
  end

  private

  def mark_carts_as_abandoned
    Cart.all.each do |cart|
      cart.mark_as_abandoned
    end
  end

  def delete_abandoned_carts
    Cart.all.each do |cart|
      cart.remove_if_abandoned
    end
  end
end
