class User < ApplicationRecord
  include BCrypt

  has_many :articles, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_one :access_token, dependent: :destroy

  validates :login, :provider, presence: true
  validates :login, uniqueness: true

  def password
    @password ||= Password.new(encrypted_password) if encrypted_password.present?
  end

  def password=(new_password)
    @password = Password.create(new_password)
    self.encrypted_password = @password
  end
end
