require 'rails_helper'

RSpec.describe User, type: :model do
  describe '#validates' do
    it 'should have valid factory' do
      user = build(:user)
      expect(user).to be_valid
    end
  end
end
