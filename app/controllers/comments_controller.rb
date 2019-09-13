class CommentsController < ApplicationController
  skip_before_action :authorize!, only: [:index]
  before_action :set_article

  def index
    @comments = Comment.all

    render json: @comments
  end

  def create
    @comment = @article.comments.new(comment_params.merge(user: current_user))

    if @comment.save
      render json: @comment, status: :created, location: @article
    else
      render json: @comment.errors, status: :unprocessable_entity
    end
  end

  private

  def set_article
    @article = Article.find(params[:article_id])
  end

  def comment_params
    params.require(:comment).permit(:content)
  end
end
