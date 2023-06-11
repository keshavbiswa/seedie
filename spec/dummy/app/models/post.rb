class Post < ApplicationRecord
  has_many :comments
  has_one :post_metadatum
end
