class Comment < ApplicationRecord
  include Searchable

  belongs_to :bubble, touch: true
  belongs_to :creator, class_name: "User", default: -> { Current.user }

  searchable_by :body, using: :comments_search_index
end
