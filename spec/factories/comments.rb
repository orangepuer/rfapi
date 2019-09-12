FactoryBot.define do
  factory :comment do
    content { "MyComment" }
    association :user
    association :article
  end
end
