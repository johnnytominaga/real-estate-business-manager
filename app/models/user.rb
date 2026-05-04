class User < ApplicationRecord

  acts_as_token_authenticatable
  # extend Devise::Models

  # Include default devise modules.
  devise :database_authenticatable,
          :recoverable, :rememberable, :trackable, :validatable
          # :registerable,:confirmable, :omniauthable

  belongs_to :roles, optional: true
  has_many :leads
  has_many :properties, foreign_key: :assigned_to
  has_one_attached :avatar
  has_one :setting
  after_create :add_setting
  has_many :notifications, dependent: :destroy
  has_many :bookmarks, dependent: :destroy

  before_create :set_default_role
  before_destroy :change_assigned_to
  after_initialize :set_default_role, :if => :new_record?

  validates :first_name, presence: true, length: {maximum: 50}
  validates :nickname, presence: true, length: 3..20, uniqueness: true,
          format: { with: /\A[a-zA-Z]+\z/,
          :message => "can only contain letters" }

  validate :avatar_type

  enum role_id: {agent: 1, editor: 2, manager: 3, admin: 4}

  def role?(role)
    !role.find_by_name( role.to_s.camelize ).nil?
  end

  def active_for_authentication?
    super && self.is_active?
  end

  def inactive_message
    is_active? ? super : 'Your account has been disabled. Please contact your manager to re-activate it.'
  end

  def show_avatar(size)

    @resize = size + "^"
    @extent = size
    if self.avatar.attached? && self.avatar.content_type.in?(%w(image/jpeg image/png))
      self.avatar.variant(
        combine_options: {
          gravity: 'center',
          'auto-orient': true,
          resize: @resize,
          extent: @extent
        }
      )
    else
      "no-profile-pic.png"
    end
  end

  def fullname
    if self.last_name?
      self.first_name + " " + self.last_name
    else
      self.first_name
    end
  end

  def add_setting
    Setting.create(user: self, enable_email: true)
  end

  # RAILS ADMIN
  attr_accessor :remove_avatar
  after_save { avatar.purge if remove_avatar == '1' }

  rails_admin do
    include_all_fields
    exclude_fields :avatar
  end

  private

  def set_default_role
    self.role_id ||= 1
  end

  def reset_authentication_token!
    update_column(:authentication_token, Devise.friendly_token)
  end

  def change_assigned_to
    Property.where(assigned_to: self.id).update_all(assigned_to: 2)
  end

  def avatar_type
    if avatar.attached? && !avatar.content_type.in?(%w(image/jpeg image/png))
      errors.add(:avatar, 'must be a JPG or PNG file')
    end
  end
end
