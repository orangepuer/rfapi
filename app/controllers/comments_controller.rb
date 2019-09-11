class CommentsController < ApplicationController
  skip_before_action :authorize!, only: [:index]

  def index
    @comments = Comment.all

    render json: @comments
  end

  def create
    @comment = Comment.new(comment_params)

    if @comment.save
      render json: @comment, status: :created, location: @comment
    else
      render json: @comment.errors, status: :unprocessable_entity
    end
  end

  private

    def comment_params
      params.require(:comment).permit(:content, :user_id, :article_id)
    end
end
