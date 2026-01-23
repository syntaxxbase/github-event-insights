class Event < ApplicationRecord
  self.inheritance_column = :_type_disabled

  belongs_to :actor, optional: true
  belongs_to :repository, optional: true

  validates :github_id, presence: true, uniqueness: true

  scope :push_events, -> { where(type: 'PushEvent') }
end
