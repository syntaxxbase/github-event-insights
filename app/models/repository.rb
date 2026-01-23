class Repository < ApplicationRecord
  has_many :events
  validates :github_id, presence: true, uniqueness: true
  validates :name, presence: true
end
