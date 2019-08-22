class User < ApplicationRecord
  validates :login, :provider, presence: true
  validates :login, uniqueness: true
end
