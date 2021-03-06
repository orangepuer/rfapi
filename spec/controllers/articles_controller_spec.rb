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

    it 'should paginate result' do
      get :index, params: { page: 2, per_page: 1 }
      expect(json_data.size).to eq 1
      expect(json_data.first['id']).to eq(Article.recent.second.id.to_s)
    end
  end

  describe '#show' do
    let(:article) { create(:article) }
    subject { get :show, params: { id: article.id } }

    it 'should return success response' do
      subject
      expect(response).to have_http_status(:ok)
    end

    it 'should return proper json' do
      subject
      expect(json_data['attributes']).to eq({
          'title' => article.title,
          'content' => article.content,
          'slug' => article.slug
                                            })
    end
  end

  describe '#create' do
    subject { post :create }

    context 'when no code provided' do
      it_behaves_like 'forbidden_requests'
    end

    context 'when invalid code provided' do
      before { request.headers['authorization'] = 'Invalid token' }
      it_behaves_like 'forbidden_requests'
    end

    context 'when authorized' do
      let(:access_token) { create(:access_token) }
      before { request.headers['authorization'] = "Bearer #{access_token.token}" }

      context 'when invalid parameters provided' do
        let(:invalid_attributes) do
          {
              data: {
                  attributes: {
                      title: '',
                      content: ''
                  }
              }
          }
        end

        subject { post :create, params: invalid_attributes }

        it 'should return 422 status code' do
          subject
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it 'should return proper error json' do
          subject
          expect(json['errors']).to include({
                                                source: { pointer: "/data/attributes/title" },
                                                detail: "can't be blank"
                                            }.as_json,
                                            {
                                                source: { pointer: "/data/attributes/content" },
                                                detail: "can't be blank"
                                            }.as_json,
                                            {
                                                source: { pointer: "/data/attributes/slug" },
                                                detail: "can't be blank"
                                            }.as_json)
        end
      end

      context 'when success request sent' do
        let(:valid_attributes) do
          {
              data: {
                  attributes: {
                      title: 'This is title',
                      content: 'This is content',
                      slug: 'this-is-title'
                  }
              }
          }
        end

        subject { post :create, params: valid_attributes }

        it 'should have 201 status code' do
          subject
          expect(response).to have_http_status(:created)
        end

        it 'should create the article' do
          expect{ subject }.to change{ Article.count }.by 1
        end

        it 'should return proper json' do
          subject
          expect(json_data['attributes']).to include(valid_attributes.as_json['data']['attributes'])
        end
      end
    end
  end

  describe '#update' do
    let(:user) { create(:user) }
    let(:article) { create(:article, user: user) }
    let(:access_token) { user.create_access_token }

    subject { patch :update, params: { id: article.id } }

    context 'when no code provided' do
      it_behaves_like 'forbidden_requests'
    end

    context 'when invalid code provided' do
      before { request.headers['authorization'] = 'Invalid token' }
      it_behaves_like 'forbidden_requests'
    end

    context 'when trying to update not owned article' do
      let(:other_user) { create(:user) }
      let(:other_article) { create(:article, user: other_user) }

      subject { patch :update, params: { id: other_article.id } }
      before { request.headers['authorization'] = "Bearer #{access_token.token}" }

      it_behaves_like 'forbidden_requests'
    end

    context 'when authorized' do
      before { request.headers['authorization'] = "Bearer #{access_token.token}" }

      context 'when invalid parameters provided' do
        let(:invalid_attributes) do
          {
              data: {
                  attributes: {
                      title: '',
                      content: ''
                  }
              }
          }
        end

        subject { patch :update, params: invalid_attributes.merge(id: article.id) }

        it 'should return 422 status code' do
          subject
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it 'should return proper error json' do
          subject
          expect(json['errors']).to include(
                                        {
                                            source: { pointer: "/data/attributes/title" },
                                            detail: "can't be blank"
                                        }.as_json,
                                        {
                                            source: { pointer: "/data/attributes/content" },
                                            detail: "can't be blank"
                                        }.as_json
                                    )
        end
      end

      context 'when success request sent' do
        let(:valid_attributes) do
          {
              data: {
                  attributes: {
                      title: 'This is title',
                      content: 'This is content',
                      slug: 'this-is-title'
                  }
              }
          }
        end

        subject { patch :update, params: valid_attributes.merge(id: article.id) }

        it 'should return 200 status code' do
          subject
          expect(response).to have_http_status(:ok)
        end

        it 'should update the article' do
          subject
          expect(article.reload.title).to eq(valid_attributes.as_json['data']['attributes']['title'])
        end

        it 'should return proper json body' do
          subject
          expect(json_data['attributes']).to include(valid_attributes.as_json['data']['attributes'])
        end
      end
    end
  end

  describe '#destroy' do
    let(:user) { create(:user) }
    let(:article) { create(:article, user: user) }
    let(:access_token) { user.create_access_token }

    subject { delete :destroy, params: { id: article.id } }

    context 'when no code provided' do
      it_behaves_like 'forbidden_requests'
    end

    context 'when invalid code provided' do
      before { request.headers['authorization'] = 'Invalid token' }
      it_behaves_like 'forbidden_requests'
    end

    context 'when trying to remove not owned article' do
      let(:other_user) { create(:user) }
      let(:other_article) { create(:article, user: other_user) }

      subject { delete :destroy, params: { id: other_article } }
      before { request.headers['authorization'] = access_token.token }

      it_behaves_like 'forbidden_requests'
    end

    context 'when authorized' do
      before { request.headers['authorization'] = "Bearer #{access_token.token}" }

      context 'whe success request sent' do
        it 'should have 204 status code' do
          subject
          expect(response).to have_http_status(:no_content)
        end

        it 'should have empty json body' do
          subject
          expect(response.body).to be_blank
        end

        it 'should destroy the article' do
          article
          expect{ subject }.to change{ user.articles.count }.by -1
        end
      end
    end
  end
end
