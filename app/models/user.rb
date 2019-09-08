class User < ApplicationRecord
  has_many :articles, dependent: :destroy
  has_one :access_token, dependent: :destroy

  validates :login, :provider, presence: true
  validates :login, uniqueness: true
end
