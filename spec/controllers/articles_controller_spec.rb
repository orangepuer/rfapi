require 'rails_helper'

RSpec.describe ArticlesController, type: :controller do
  describe '#index' do
    it 'should return success response' do
      get :index
      expect(response).to have_http_status(:ok)
    end
  end
end