class User < ApplicationRecord
  has_secure_password

  enum :role, { customer: 0, admin: 1 }

  has_one :cart, dependent: :destroy
  has_many :orders, dependent: :destroy

  has_many :wishlists, dependent: :destroy
  has_many :wishlist_products, through: :wishlists, source: :product

  after_create :create_cart

  validates :name, presence: true
  validates :email, presence: true, uniqueness: true

  private

  def create_cart
    Cart.create(user: self)
  end
end
