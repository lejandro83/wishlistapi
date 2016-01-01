class WishSerializer < ActiveModel::Serializer
  cached

  attributes :id, :name, :price, :image_url, :page_url
  has_one :user

  def cache_key
    [object, scope]
  end
end
