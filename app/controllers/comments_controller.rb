class CommentsController < ApplicationController
  skip_before_action :authorize!, only: [:index]
  before_action :set_article

  def index
    comments = @article.comments.page(params[:page]).per(params[:per_page])

    render json: comments
  end

  def create
    @comment = @article.comments.new(comment_params.merge(user: current_user))

    @comment.save!
    render json: @comment, status: :created, location: @article
  rescue
    render json: @comment, adapter: :json_api, serializer: ErrorSerializer, status: :unprocessable_entity
  end

  private

  def set_article
    @article = Article.find(params[:article_id])
  end

  def comment_params
    params.require(:data).require(:attributes).permit(:content) || ActionController::Parameters.new
  end
end
