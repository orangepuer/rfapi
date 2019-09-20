class UserAuthenticator
  attr_reader :authenticator

  def initialize(code: nil, login: nil, password: nil)
    if code.present?
      @authenticator = Oauth.new(code)
    else
      @authenticator = Standard.new(login, password)
    end
  end

  def perform
    authenticator.perform
  end

  def user
    authenticator.user
  end

  def access_token
    authenticator.access_token
  end
end