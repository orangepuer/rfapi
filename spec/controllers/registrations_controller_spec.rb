require 'rails_helper'

RSpec.describe RegistrationsController, type: :controller do
  describe '#create' do
    subject { post :create, params: params }

    context 'when invalid data provided' do
      let(:params) do
        {
            data: {
                attributes: {
                    login: nil,
                    password: nil
                }
            }
        }
      end

      it 'should return unprocessable_entity status code' do
        subject
        expect(response).to have_http_status(:unprocessable_entity)
      end
      
      it 'should not created a user' do
        expect{ subject }.to_not change{ User.count }
      end

      it 'should return error messages in response body' do
        subject
        expect(json['errors']).to include(
                                      {
                                          'source' => { 'pointer' => '/data/attributes/login' },
                                          'detail' => "can't be blank"
                                      },
                                      {
                                          'source' => { 'pointer' => '/data/attributes/password' },
                                          'detail' => "can't be blank"
                                      },
                                  )
      end
    end

    context 'when valid data provided' do
      let(:params) do
        {
            data: {
                attributes: {
                    login: 'user_login',
                    password: '12345'
                }
            }
        }
      end

      it 'should return 201 status code' do
        subject
        expect(response).to have_http_status(:created)
      end

      it 'should created a user' do
        expect(User.exists?(login: 'user_login')).to be_falsey
        expect{ subject }.to change{ User.count }.by(1)
        expect(User.exists?(login: 'user_login')).to be_truthy
      end
    end
  end
end