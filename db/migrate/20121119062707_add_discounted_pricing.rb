class AddDiscountedPricing < ActiveRecord::Migration
  def self.up
    add_column :courses, :discounted_pricing, :string, :default => nil
  end

  def self.down
    add_column :courses, :discounted_pricing
  end
end

