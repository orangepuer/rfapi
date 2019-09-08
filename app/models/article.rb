class Article < ApplicationRecord
  belongs_to :user

  validates :title, :content, :slug, presence: true
  validates :slug, uniqueness: true

  scope :recent, -> { order(created_at: :desc) }
end
