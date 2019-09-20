require 'rails_helper'

describe UserAuthenticator do
  describe '#initialize' do
    context 'when initialized with code' do
      let(:authenticator) { described_class.new(code: 'sample') }
      let(:authenticator_class) { UserAuthenticator::Oauth }

      it 'should initialize proper authenticator' do
        expect(authenticator_class).to receive(:new).with('sample')
        authenticator
      end
    end

    context 'when initialized with login and password' do
      let(:authenticator) { described_class.new(login: 'user_login', password: '12345' ) }
      let(:authenticator_class) { UserAuthenticator::Standard }

      it 'should initialize proper authenticator' do
        expect(authenticator_class).to receive(:new).with('user_login', '12345' )
        authenticator
      end
    end
  end
end