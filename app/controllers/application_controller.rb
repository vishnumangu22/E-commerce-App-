class ApplicationController < ActionController::Base
  before_action :require_user

  helper_method :current_user, :logged_in?

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end

  def logged_in?
    !!current_user
  end

  def require_user
    unless logged_in?
      redirect_to login_path, alert: "You must be logged in"
    end
  end

  def require_admin
    redirect_to root_path, alert: "Access denied" unless current_user&.admin?
  end
  helper_method :require_admin
end
