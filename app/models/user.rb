class User < ApplicationRecord
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i

  attr_accessor :remember_token

  validates :email, format: {with: VALID_EMAIL_REGEX},
  length: {maximum: Settings.max_length},
  presence: true, uniqueness: {case_sensitive: false}
  validates :name, length: {maximum: Settings.max_length}, presence: true
  validates :password, length: {minimum: Settings.min_length}

  before_save ->{self.email = email.downcase}

  has_secure_password

  class << self
    def digest string
      cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST : BCrypt::Engine.cost
      BCrypt::Password.create string, cost: cost
    end

    def new_token
      SecureRandom.urlsafe_base64
    end
  end

  def remember
    self.remember_token = User.new_token
    update_attributes :remember_digest, User.digest(remember_token)
  end

  def authenticated? remember_token
    return false if remember_digest.nil?
    BCrypt::Password.new(remember_digest).is_password? remember_token
  end

  def forget
    update_attributes :remember_digest, nil
  end
end
