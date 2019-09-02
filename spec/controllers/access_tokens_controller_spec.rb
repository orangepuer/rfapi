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
      let(:user_data) do
        { login: 'User', name: 'MyName', url: "http://example.com", avatar_url: "http://example.com/avatar" }
      end

      before do
        allow_any_instance_of(Octokit::Client).to receive(:exchange_code_for_token).and_return('validaccesstoken')
        allow_any_instance_of(Octokit::Client).to receive(:user).and_return(user_data)
      end

      subject { post :create, params: { code: 'valid_code' } }

      it 'should return 201 status code' do
        subject
        expect(response).to have_http_status(:created)
      end

      it 'save the new user in the database' do
        expect{ subject }.to change{ User.count }.by 1
      end

      it 'save the new access_token in the database' do
        expect{ subject }.to change{ AccessToken.count }.by 1
      end

      it 'should return proper json body' do
        subject
        user = User.find_by(login: 'User')
        expect(json_data['attributes']).to eq({ 'token' => user.access_token.token })
      end
    end
  end

  describe '#destroy' do
    subject { delete :destroy }

    context 'when no authorization header provided' do
      it_behaves_like 'forbidden_requests'
    end

    context 'when invalid authorization header provided' do
      before { request.headers['authorization'] = 'Invalid token' }

      it_behaves_like 'forbidden_requests'
    end

    context 'when valid request' do
      let(:user) { create(:user) }
      let(:access_token) { user.create_access_token }

      before { request.headers['authorization'] = "Bearer #{access_token.token}" }

      it 'should return 204 status code' do
        subject
        expect(response).to have_http_status(:no_content)
      end

      it 'should remove the proper access token' do
        expect{ subject }.to change{ AccessToken.count }.by -1
      end
    end
  end
end
