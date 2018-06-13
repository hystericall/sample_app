class SessionsController < ApplicationController
  before_action :find_user_by_email, only: :create

  def new; end

  def create
    if @user && @user.authenticate(params[:session][:password])
      if user.activated?
        login_and_redirect
      else
        show_not_activated
      end
    else
      flash.now[:danger] = t "invalid"
      render :new
    end
  end

  def destroy
    log_out if logged_in?
    redirect_to root_url
  end

  private

  def find_user_by_email
    @user = User.find_by email: params[:session][:email].downcase
  end

  def login_and_redirect
    log_in @user
    params[:session][:remember_me] == Settings.remembered ? remember(@user) : forget(@user)
    redirect_back_or @user
  end

  def show_not_activated
    message = t "not_activated"
    flash[:warning] = message
    redirect_to root_path
  end
end
