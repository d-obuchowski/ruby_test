FactoryBot.define do
  factory :geolocation do
    ip_address { IPAddr.new(rand(2**32), Socket::AF_INET) }
    city { Faker::Address.city }
    country_name { Faker::Address.country }
    zip { Faker::Address.zip_code }
  end
end
