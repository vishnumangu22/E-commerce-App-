class ApplicationController < ActionController::Base
  before_action :require_user

  helper_method :current_user, :logged_in?


  def current_user
    @current_user ||= User.find_by(id: session[:user_id])
  end

  def logged_in?
    current_user.present?
  end

  def require_user
    unless logged_in?
      redirect_to login_path,
                  alert: "You must be logged in",
                  status: :see_other
    end
  end

  def require_admin
    unless current_user&.admin?
      redirect_to root_path,
                  alert: "Access denied",
                  status: :see_other
    end
  end
end
