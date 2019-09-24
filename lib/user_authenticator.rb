class UserAuthenticator
  attr_reader :authenticator, :access_token

  def initialize(code: nil, login: nil, password: nil)
    if code.present?
      @authenticator = Oauth.new(code)
    else
      @authenticator = Standard.new(login, password)
    end
  end

  def perform
    authenticator.perform

    set_access_token
  end

  def user
    authenticator.user
  end

  private

  def set_access_token
    if user.access_token.present?
      @access_token = user.access_token
    else
      @access_token = user.create_access_token
    end
  end
end