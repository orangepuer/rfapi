require 'rails_helper'

RSpec.describe CommentsController, type: :controller do
  let(:article) { create(:article) }

  describe "GET #index" do
    subject { get :index, params:{ article_id: article.id } }

    it "returns a success response" do
      subject
      expect(response).to have_http_status(:ok)
    end

    it 'should return only comments belonging to article' do
      comment = create(:comment, article: article)
      create(:comment)
      subject
      expect(json_data.length).to eq(1)
      expect(json_data.first['id']).to eq(comment.id.to_s)
    end

    it 'should paginated result' do
      comments = create_list(:comment, 3, article: article )
      get :index, params: { article_id: article.id, per_page: 1, page: 2 }
      expect(json_data.length).to eq(1)
      expect(json_data.first['id']).to eq(comments.second.id.to_s)
    end

    it 'should have proper json body' do
      comment = create(:comment, article: article)
      subject
      expect(json_data.first['attributes']).to eq({ 'content' => comment.content })
    end

    it 'should have related objects information in the response' do
      user = create(:user)
      create(:comment, user: user, article: article)
      subject
      expect(json_data.first['relationships']['user']['data']['id']).to eq(user.id.to_s)
      expect(json_data.first['relationships']['article']['data']['id']).to eq(article.id.to_s)
    end
  end

  describe "POST #create" do
    let(:valid_attributes) { { data: { attributes: { content: 'My comment for article' } } } }
    let(:invalid_attributes) { { data: { attributes: { content: '' } } } }

    context 'when not authorized' do
      before { request.headers['authorization'] = 'Invalid token' }

      subject { post :create, params: valid_attributes.merge(article_id: article.id) }
      it_behaves_like 'forbidden_requests'
    end

    context 'wen success request sent' do
      let(:user) { create(:user) }
      let(:access_token) { user.create_access_token }

      before { request.headers['authorization'] = "Bearer #{access_token.token}" }

      context "with valid params" do
        subject { post :create, params: valid_attributes.merge(article_id: article.id) }

        it 'returns 201 status code' do
          subject
          expect(response).to have_http_status(:created)
        end
        
        it "creates a new Comment" do
          expect { subject }.to change(article.comments, :count).by(1)
        end

        it "renders a JSON response with the new comment" do
          subject
          expect(json_data['attributes']).to eq({ 'content' => article.comments.first.content })
        end
      end

      context "with invalid params" do
        subject { post :create, params: invalid_attributes.merge(article_id: article.id) }

        it 'should return 422 status code' do
          subject
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it "renders a JSON response with errors for the new comment" do
          subject
          expect(json['errors']).to include({
                                                source: { pointer: "/data/attributes/content" },
                                                detail: "can't be blank"
                                            }.as_json)
        end
      end
    end
  end
end
