# frozen_string_literal: true

class Member < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :confirmable, :lockable, :timeoutable, :trackable
  validates :first_name, :last_name, :sex, presence: true
  validates :first_name, :last_name, length: { maximum: 10 }
  validates :introduction, length: { maximum: 70 }
  validates :sex, numericality: {
    only_integer: true,
    greater_than: 0,
    less_than: 3,
    allow_blank: true
  }
  validate :pass_value
  validate :email_value
  validate :bounce_email
  has_many :tweets, dependent: :destroy
  has_many :favorites
  has_many :favorite_tweets, through: :favorites, source: :tweet
  # pictureアップロード
  has_one_attached :profile_picture
  attribute :new_profile_picture
  attribute :remove_profile_picture, :boolean
  has_many :active_relationships,
           class_name: 'Relationship',
           foreign_key: 'follower_id',
           dependent: :destroy
  has_many :passive_relationships,
           class_name: 'Relationship',
           foreign_key: 'followed_id',
           dependent: :destroy
  has_many :following, through: :active_relationships, source: :followed
  has_many :followers, through: :passive_relationships, source: :follower
  has_many :likes, dependent: :destroy
  has_many :like_tweets, through: :likes, source: :tweet
  soft_deletable
  attr_accessor :current_password

  before_save do
    if new_profile_picture
      self.profile_picture = new_profile_picture
    elsif remove_profile_picture
      profile_picture.purge
    end
  end
  validate if: :new_profile_picture do
    if new_profile_picture.respond_to?(:content_type)
      unless new_profile_picture.content_type.in?(ALLOWED_CONTENT_TYPES)
        errors.add(:new_profile_picture, :invalid_image_type)
      end
    else
      errors.add(:new_profile_picture, :invalid)
    end
  end
  VALID_PASSWORD_REGEX = /\A[a-z0-9]+\z/i.freeze
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i.freeze
  def pass_value
    return unless password.present?

    return if password.match(VALID_PASSWORD_REGEX)

    errors.add(:password, :invalid_password)
  end

  def email_value
    return unless email.present?

    return if email.match(VALID_EMAIL_REGEX)

    errors.add(:email, :invalid_email)
  end

  def bounce_email
    bounced_email_addresses = Bounce.pluck(:email)
    return unless bounced_email_addresses.include?(email)

    errors.add(:email, :bounce_email)
  end

  def favorite?(tweet)
    tweet && tweet.author != self && !favorites.exists?(tweet_id: tweet.id)
  end

  def delete_favorite?(tweet)
    tweet && tweet.author != self && favorites.exists?(tweet_id: tweet.id)
  end

  # フォロー機能の追加
  def follow(other_member)
    active_relationships.create(followed_id: other_member.id)
  end

  def unfollow(other_member)
    active_relationships.find_by(followed_id: other_member.id).destroy
  end

  def following?(other_member)
    following.include?(other_member)
  end

  def active_for_authentication?
    super && !soft_destroyed_at
  end

  def inactive_message
    !soft_destroyed_at ? super : :deleted_account
  end
end
