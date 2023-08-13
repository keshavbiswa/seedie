class Review < ApplicationRecord
  belongs_to :user
  belongs_to :reviewable, polymorphic: true

  enum review_type: { positive: 0, negative: 1 }
end
