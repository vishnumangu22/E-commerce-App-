class UsersController < ApplicationController
  skip_before_action :require_user, only: [ :new, :create ]
  before_action :require_user, only: [ :profile, :destroy ]

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)

    if @user.save
      session[:user_id] = @user.id
      redirect_to root_path, notice: "Account created successfully"
    else
      render :new
    end
  end


  def profile
    @user = current_user
  end

  def destroy
    if current_user.admin?
      redirect_to root_path, alert: "Admin account cannot be deleted"
    else
      current_user.destroy
      reset_session
      redirect_to root_path, notice: "Account deleted successfully"
    end
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end
end
