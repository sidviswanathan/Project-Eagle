class AddDiscountedPricing < ActiveRecord::Migration
  def self.up
    add_column :courses, :discounted_pricing, :text
  end

  def self.down
    remove_column :courses, :discounted_pricing
  end
end

