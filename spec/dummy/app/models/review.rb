class Review < ApplicationRecord
  belongs_to :user
  belongs_to :reviewable, polymorphic: true
end
