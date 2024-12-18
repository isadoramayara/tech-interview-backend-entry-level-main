require 'rails_helper'

RSpec.describe MarkCartAsAbandonedJob, type: :job do
  let!(:abandoned) { create(:shopping_cart, last_interaction_at: 4.hours.ago) }
  let!(:abandoned_to_delete) { create(:shopping_cart, abandoned_at: 8.days.ago, last_interaction_at: 10.days.ago) }

  describe '#perform' do
    it 'marks abandoned cart as abandoned' do
      MarkCartAsAbandonedJob.new.perform

      expect(abandoned.reload.abandoned_at).not_to be_nil
    end

    it 'delete abandoned_to_delete cart' do
      expect { MarkCartAsAbandonedJob.new.perform }.to change { Cart.exists?(abandoned_to_delete.id) }.from(true).to(false)
    end
  end
end