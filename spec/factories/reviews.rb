FactoryBot.define do
  factory :review do
    association :booking, :completed
    rating { 5 }
    comment { "Excelente estadía, todo tal cual se describía." }
  end
end