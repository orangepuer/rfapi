class UserAuthenticator::Oauth < UserAuthenticator
  class AuthenticationError < StandardError
  end

  attr_reader :user, :access_token

  def initialize(code)
    @code = code
  end

  def perform
    if @code.blank? || token.try(:error).present?
      raise AuthenticationError
    else
      prepare_user

      if user.access_token.present?
        @access_token = user.access_token
      else
        @access_token = user.create_access_token
      end
    end
  end

  private

  attr_reader :code

  def client
    @client ||= Octokit::Client.new(
        client_id: ENV['GITHUB_CLIENT_ID'],
        client_secret: ENV['GITHUB_CLIENT_SECRET']
    )
  end

  def token
    @token ||= client.exchange_code_for_token(code)
  end

  def user_data
    @user_data ||= Octokit::Client.new(access_token: token).user.to_h.slice(:login, :name, :avatar_url, :url)
  end

  def prepare_user
    if User.exists?(login: user_data[:login])
      @user = User.find_by(login: user_data[:login])
    else
      @user = User.create(user_data.merge(provider: 'github'))
    end
  end
end