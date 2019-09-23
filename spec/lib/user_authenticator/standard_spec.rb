require 'rails_helper'

describe UserAuthenticator::Standard do
  describe '#perform' do
    let(:authenticator) { described_class.new('user_login', '12345') }
    subject { authenticator.perform }

    shared_examples_for 'invalid authentication' do
      it 'should raise an error' do
        expect{ subject }.to raise_error(UserAuthenticator::Standard::AuthenticationError)
        expect(authenticator.user).to be_nil
      end
    end

    context 'when invalid login' do
      let!(:user) { create(:user, login: 'invalid_login', password: '12345') }
      it_behaves_like 'invalid authentication'
    end

    context 'when invalid password' do
      let!(:user) { create(:user, login: 'user_login', password: 'invalid_password') }
      it_behaves_like 'invalid authentication'
    end

    context 'when valid login and password' do

    end
  end
end