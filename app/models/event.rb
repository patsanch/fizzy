class Event < ApplicationRecord
  THREADABLE_ACTIONS = %w[ assigned boosted created ]

  include Assignments

  belongs_to :creator, class_name: "User"
  belongs_to :bubble, touch: true

  has_one :account, through: :creator

  scope :threadable, -> { where action: THREADABLE_ACTIONS }
end
