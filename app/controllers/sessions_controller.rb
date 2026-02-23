class SessionsController < ApplicationController
  skip_before_action :require_user, only: [ :new, :create ]

  def new
  end

  def create
    user = User.find_by(email: params[:session][:email])

    if user&.authenticate(params[:session][:password])
      session[:user_id] = user.id

      if user.admin?
        redirect_to admin_root_path
      else
        redirect_to root_path
      end

    else
      flash.now[:alert] = "Invalid email or password"
      render :new
    end
  end

  def destroy
    session[:user_id] = nil
    redirect_to login_path
  end
end
