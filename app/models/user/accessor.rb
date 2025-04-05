module User::Accessor
  extend ActiveSupport::Concern

  included do
    has_many :accesses, dependent: :destroy
    has_many :buckets, through: :accesses
    has_many :accessible_bubbles, through: :buckets, source: :bubbles

    after_create_commit :grant_access_to_buckets
  end

  private
    def grant_access_to_buckets
      Access.insert_all account.buckets.all_access.pluck(:id).collect { |bucket_id| { bucket_id: bucket_id, user_id: id } }
    end
end
