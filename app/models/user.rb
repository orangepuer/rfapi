class User < ApplicationRecord
  has_one :access_token, dependent: :destroy

  validates :login, :provider, presence: true
  validates :login, uniqueness: true
end
