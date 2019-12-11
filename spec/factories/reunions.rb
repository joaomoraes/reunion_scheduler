# frozen_string_literal: true
FactoryBot.define do
  factory :reunion do

    trait :publishable do
      name { "Reunion Test" }
      description { "<br> Just a test description" }
      start_date { "2019/11/28" }
      end_date { "2019/11/30" }
      location { "Test Location" }
    end

    trait :published do
      publishable
      state { "published" }
    end

    trait :discarded do
      discarded_at { Time.now }
    end
  end
end
