class User < ApplicationRecord
  include BCrypt

  has_many :articles, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_one :access_token, dependent: :destroy

  validates :login, :provider, presence: true
  validates :password, presence: true, if: -> { provider == 'standard' }
  validates :login, uniqueness: true

  def password
    @password ||= Password.new(encrypted_password) if encrypted_password.present?
  end

  def password=(new_password)
    return @password = new_password if new_password.blank?
    @password = Password.create(new_password)
    self.encrypted_password = @password
  end
end
