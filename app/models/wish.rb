class Wish < ActiveRecord::Base
  validates :name, :user_id, presence: true
  validates :price, numericality: { greater_than_or_equal_to: 0 },
                    presence: true
  belongs_to :user

  scope :filter_by_name, lambda { |keyword|
    where("lower(name) LIKE ?", "%#{keyword.downcase}%" ) 
  }

  scope :above_or_equal_to_price, lambda { |price| 
    where("price >= ?", price) 
  }

  scope :below_or_equal_to_price, lambda { |price| 
    where("price <= ?", price) 
  }

  scope :recent, -> {
    order(:updated_at)
  }

  def self.search(params = {})
    wishes = params[:wish_ids].present? ? Wish.where(id: params[:wish_ids]) : Wish.all

    wishes = wishes.filter_by_name(params[:keyword]) if params[:keyword]
    wishes = wishes.above_or_equal_to_price(params[:min_price].to_f) if params[:min_price]
    wishes = wishes.below_or_equal_to_price(params[:max_price].to_f) if params[:max_price]
    wishes = wishes.recent(params[:recent]) if params[:recent].present?

    wishes
  end
end
