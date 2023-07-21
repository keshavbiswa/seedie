class Post < ApplicationRecord
  has_many :comments
  has_one :post_metadatum

  has_many :reviews, as: :reviewable
  
  belongs_to :user, optional: true
end
