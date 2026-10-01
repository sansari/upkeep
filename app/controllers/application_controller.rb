class ApplicationController < ActionController::Base
  before_action :require_authentication
  helper_method :authenticated?

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  private

  def authenticated?
    expected_token = authentication_token
    actual_token = cookies.encrypted[:upkeep_authentication]

    expected_token.present? && actual_token.present? &&
      ActiveSupport::SecurityUtils.secure_compare(actual_token, expected_token)
  end

  def require_authentication
    return if authenticated?

    if request.format.json?
      head :unauthorized
    else
      session[:return_to_after_authenticating] = request.fullpath if request.get?
      redirect_to new_session_path
    end
  end

  def password_matches?(password)
    expected_token = authentication_token
    actual_token = Digest::SHA256.hexdigest(password.to_s)

    expected_token.present? && ActiveSupport::SecurityUtils.secure_compare(actual_token, expected_token)
  end

  def start_authenticated_session
    cookies.encrypted[:upkeep_authentication] = {
      value: authentication_token,
      expires: 1.year.from_now,
      httponly: true,
      secure: Rails.env.production?,
      same_site: :lax
    }
  end

  def authentication_token
    password = ENV["UPKEEP_PASSWORD"]
    Digest::SHA256.hexdigest(password) if password.present?
  end
end
