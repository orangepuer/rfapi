require 'rails_helper'

RSpec.describe ArticlesController, type: :controller do
  describe '#index' do
    let!(:articles) { create_list(:article, 2) }
    let(:old_article) { articles.first }
    let(:newer_article) { articles.last }
    let(:article_response) { json_data.first['attributes'] }

    before { get :index }

    it 'should return success response' do
      expect(response).to have_http_status(:ok)
    end

    it 'return list of articles' do
      expect(json_data.size).to eq(2)
    end

    %w(title content slug).each do |attribute|
      it "article object contain #{attribute}" do
        expect(article_response[attribute]).to eq newer_article.send(attribute)
      end
    end

    it 'should return articles in the proper order' do
      expect(json_data.first['id']).to eq newer_article.id.to_s
      expect(json_data.last['id']).to eq old_article.id.to_s
    end
  end
end
