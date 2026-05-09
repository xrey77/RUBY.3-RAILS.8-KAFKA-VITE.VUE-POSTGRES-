class Product < ApplicationRecord
  belongs_to :category

  scope :filter_by_name, ->(keyword) {
    where("products.descriptions ILIKE ?", "%#{keyword}%")
  }  
end
