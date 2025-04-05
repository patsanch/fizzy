class User < ApplicationRecord
  include Accessor, Avatar, Role, Transferable

  belongs_to :account

  has_many :sessions, dependent: :destroy
  has_secure_password validations: false

  has_many :filters, foreign_key: :creator_id, inverse_of: :creator, dependent: :destroy

  has_many :pops, dependent: :nullify

  has_many :assignments, foreign_key: :assignee_id, dependent: :destroy
  has_many :assignings, foreign_key: :assigner_id, class_name: "Assignment"
  has_many :assigned_bubbles, through: :assignments, source: :bubble

  has_many :notifications, dependent: :destroy

  has_one_attached :avatar

  has_many :pins, dependent: :destroy
  has_many :pinned_bubbles, through: :pins, source: :bubble

  normalizes :email_address, with: ->(value) { value.strip.downcase }

  scope :alphabetically, -> { order("lower(name)") }
  scope :sorted_with_user_first, ->(user) { order(Arel.sql("users.id != ?, lower(name)", user.id)) }

  def initials
    name.to_s.scan(/\b\p{L}/).join.upcase
  end

  def deactivate
    transaction do
      sessions.destroy_all
      accesses.destroy_all
      update! active: false, email_address: deactived_email_address
    end
  end

  def current?
    Current.user == self
  end

  private
    def deactived_email_address
      email_address.sub(/@/, "-deactivated-#{SecureRandom.uuid}@")
    end

end
