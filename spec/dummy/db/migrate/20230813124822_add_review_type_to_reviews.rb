# frozen_string_literal: true

class AddReviewTypeToReviews < ActiveRecord::Migration[7.0]
  def change
    add_column :reviews, :review_type, :integer, default: 0
  end
end
