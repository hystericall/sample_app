class User < ApplicationRecord
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i

  validates :email, format: {with: VALID_EMAIL_REGEX},
  length: {maximum: Settings.max_length},
  presence: true, uniqueness: {case_sensitive: false}
  validates :name, length: {maximum: Settings.max_length}, presence: true
  validates :password, length: {minimum: Settings.min_length}

  before_save ->{self.email = email.downcase}

  has_secure_password

  def self.digest string
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST : BCrypt::Engine.cost
    BCrypt::Password.create string, cost: cost
  end
end
