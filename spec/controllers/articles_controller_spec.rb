require 'rails_helper'

RSpec.describe ArticlesController, type: :controller do
  describe '#index' do
    let(:articles) { create_list(:article, 2) }
    let!(:article) { articles.first }
    let(:articles_response) { json['data'] }
    let(:article_response) { articles_response.first['attributes'] }

    before { get :index }

    it 'should return success response' do
      expect(response).to have_http_status(:ok)
    end

    it 'return list of articles' do
      expect(articles_response.size).to eq(2)
    end

    %w(title content slug).each do |attribute|
      it "article object contain #{attribute}" do
        expect(article_response[attribute]).to eq article.send(attribute)
      end
    end
  end
end
