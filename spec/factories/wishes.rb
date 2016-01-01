FactoryGirl.define do
  factory :wish do
    name { FFaker::Product.product_name }
    price { rand() * 100 }
    image_url { FFaker::Internet.http_url }
    page_url { FFaker::Internet.http_url }
    user
  end
end
