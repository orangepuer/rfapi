require 'rails_helper'

RSpec.describe User, type: :model do
  describe '#validates' do
    it 'should have valid factory' do
      user = build(:user)
      expect(user).to be_valid
    end

    it 'should validate presence of the login' do
      user = build(:user, login: nil)
      expect(user).to_not be_valid
      expect(user.errors.messages[:login]).to include("can't be blank")
    end

    it 'should validate presence of the password for standard provider' do
      user = build(:user, login: 'user_login', password: nil, provider: 'standard')
      expect(user).to_not be_valid
      expect(user.errors.messages[:password]).to include("can't be blank")
    end

    it 'should validate presence of the provider' do
      user = build(:user, provider: nil)
      expect(user).to_not be_valid
      expect(user.errors.messages[:provider]).to include("can't be blank")
    end

    it 'should validate uniqueness of login' do
      first_user = create(:user)
      second_user = build(:user, login: first_user.login)
      expect(second_user).to_not be_valid
      second_user.login = 'NewLogin'
      expect(second_user).to be_valid
    end
  end
end
