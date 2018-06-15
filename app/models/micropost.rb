class Micropost < ApplicationRecord
  belongs_to :user

  validates :user_id, presence: true
  validates :content, length: {maximum: Settings.content_length}, presence: true
  validate  :picture_size

  default_scope ->{order(created_at: :desc)}
  scope :load_posts, ->(following_ids, id){where "user_id IN (?) OR user_id = ?", following_ids, id}

  mount_uploader :picture, PictureUploader

  private

  def picture_size
    return unless picture.size > Settings.picture_size.megabytes
    errors.add :picture, I18n.t("picture_size_error")
  end
end
