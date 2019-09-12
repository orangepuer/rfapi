require 'rails_helper'

RSpec.describe Comment, type: :model do
  describe '#validates' do
    it 'should have valid factory' do
      comment = build(:comment)
      expect(comment).to be_valid
    end

    it 'should validate the presence of the user' do
      comment = Comment.new
      expect(comment).to_not be_valid
      expect(comment.errors.messages).to include({ user: ["must exist"] })
    end

    it 'should validate the presence of the article' do
      comment = Comment.new
      expect(comment).to_not be_valid
      expect(comment.errors.messages).to include({ article: ["must exist"] })
    end

    it 'should validate the presence of the content' do
      comment = Comment.new
      expect(comment).to_not be_valid
      expect(comment.errors.messages).to include({ content: ["can't be blank"] })
    end
  end
end
