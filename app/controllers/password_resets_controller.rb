class PasswordResetsController < ApplicationController
  before_action :find_user, :valid_user, :check_expiration, only: %i(edit update)

  def new; end

  def create
    @user = User.find_by email: params[:password_reset][:email].downcase
    if @user
      @user.create_reset_digest
      @user.send_password_reset_email
      flash[:info] = t "email_sent"
      redirect_to root_path
    else
      flash.now[:danger] = t "email_not_found"
      render :new
    end
  end

  def edit; end

  def update
    if params[:user][:password].empty?
      @user.errors.add :password, t("cant_be_empty")
      render :edit
    elsif @user.update_attributes(user_params)
      success_reset_handle
    else
      render :edit
    end
  end

  private

  def find_user
    @user = User.find_by email: params[:email].downcase
    return unless @user.nil?
    flash[:danger] = t "user_not_found"
    redirect_to root_path
  end

  def valid_user
    return if @user.activated? && @user.authenticated?(:reset, params[:id])
    redirect_to root_path
  end

  def check_expiration
    return unless @user.password_reset_expired?
    flash[:danger] = t "expired_token"
    redirect_to new_password_reset_path
  end

  def success_reset_handle
    log_in @user
    @user.update_attributes(reset_digest: nil)
    flash[:success] = t "success_reset"
    redirect_to @user
  end
end
