FactoryBot.define do
  factory :article do
    sequence(:title) { |n| "My article #{ n }" }
    sequence(:content) { |n| "Content of my article #{ n }" }
    sequence(:slug) { |n| "my-article-#{ n }" }
  end
end
