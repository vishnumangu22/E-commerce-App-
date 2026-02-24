module Admin
  class UsersController < ApplicationController
    before_action :require_admin

    def index
      @users = User.order(created_at: :desc)
    end

    def show
      @user = User.find(params[:id])
    end

    def destroy
      user = User.find(params[:id])

      if user == current_user
        redirect_to admin_users_path, alert: "You cannot delete yourself"
      else
        user.destroy
        redirect_to admin_users_path, notice: "User deleted successfully"
      end
    end
  end
end
