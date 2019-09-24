require 'rails_helper'

describe UserAuthenticator do
  describe '#initialize' do
    let(:user) { create(:user, login: 'user_login', password: '12345') }

    shared_examples_for 'authenticator' do
      it 'should create and set user access token' do
        expect(authenticator.authenticator).to receive(:perform).and_return(true)
        expect(authenticator.authenticator).to receive(:user).at_least(:once).and_return(user)
        expect{ authenticator.perform }.to change{ AccessToken.count }.by(1)
        expect(authenticator.access_token).to be_present
      end
    end

    context 'when initialized with code' do
      let(:authenticator) { described_class.new(code: 'sample') }
      let(:authenticator_class) { UserAuthenticator::Oauth }

      it 'should initialize proper authenticator' do
        expect(authenticator_class).to receive(:new).with('sample')
        authenticator
      end

      it_behaves_like 'authenticator'
    end

    context 'when initialized with login and password' do
      let(:authenticator) { described_class.new(login: 'user_login', password: '12345' ) }
      let(:authenticator_class) { UserAuthenticator::Standard }

      it 'should initialize proper authenticator' do
        expect(authenticator_class).to receive(:new).with('user_login', '12345' )
        authenticator
      end

      it_behaves_like 'authenticator'
    end
  end
end