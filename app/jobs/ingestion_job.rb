class IngestionJob < ApplicationJob
  queue_as :default

  def perform
    GithubEventIngestionService.new.call
  end
end
