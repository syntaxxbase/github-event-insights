class Actor < ApplicationRecord
  has_many :events
  validates :github_id, presence: true, uniqueness: true
  validates :login, presence: true
end
