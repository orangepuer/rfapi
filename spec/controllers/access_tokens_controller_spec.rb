require 'rails_helper'

RSpec.describe AccessTokensController, type: :controller do
  describe '#create' do
    context 'when no code provided' do
      subject { post :create }
      it_behaves_like 'unauthorized_requests'
    end

    context 'when invalid code provided' do
      let(:github_error) { double("Sawyer::Resource", error: "bad_verification_code") }
      before { allow_any_instance_of(Octokit::Client).to receive(:exchange_code_for_token).and_return(github_error) }
      subject { post :create, params: { code: 'invalid_code' } }
      it_behaves_like 'unauthorized_requests'
    end

    context 'when success request' do

    end
  end
end
