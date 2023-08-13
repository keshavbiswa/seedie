class SimpleModel < ApplicationRecord
  validates :category, inclusion: { in: %w[tech news sports politics entertainment] }, presence: true
  
  enum status: { active: 0, suspended: 1 }

  validates :status, presence: true
end