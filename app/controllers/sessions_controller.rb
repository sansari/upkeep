class SessionsController < ApplicationController
  layout "authentication"
  skip_before_action :require_authentication
  rate_limit to: 10, within: 3.minutes, only: :create,
    with: -> { render :new, status: :too_many_requests }

  def new
    redirect_to root_path if authenticated?
  end

  def create
    if password_matches?(params[:password])
      return_to = session.delete(:return_to_after_authenticating)
      reset_session
      start_authenticated_session
      redirect_to return_to || root_path
    else
      flash.now.alert = "That password is incorrect."
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    cookies.delete(:upkeep_authentication)
    reset_session
    redirect_to new_session_path, notice: "You have been signed out."
  end
end
