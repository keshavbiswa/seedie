class SimpleModel < ApplicationRecord
  validates :category, inclusion: { in: %w[tech news sports politics entertainment] }
end