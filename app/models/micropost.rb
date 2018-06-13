class Micropost < ApplicationRecord
  belongs_to :user

  validates :user_id, presence: true
  validates :content, length: {maximum: Settings.content_length}, presence: true
  validate  :picture_size

  default_scope ->{order(created_at: :desc)}
  scope :find_by_user_id, ->(id){where "user_id = ?", id}

  mount_uploader :picture, PictureUploader

  private

  def picture_size
    return unless picture.size > Settings.picture_size.megabytes
    errors.add :picture, I18n.t("picture_size_error")
  end
end
