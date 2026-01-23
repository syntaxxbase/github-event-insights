require 'net/http'
require 'json'
# Non-Rails apps might need explicit requires, though Rails should autoload. 
# Adding them to be safe in this docker runner context if autoloading is flaky.


class GithubEventIngestionService
  GITHUB_API_URL = 'https://api.github.com/events'
  
  def call
    Rails.logger.info("Starting GitHub Event Ingestion...")
    
    response = fetch_events
    
    if response.is_a?(Net::HTTPSuccess)
      events = JSON.parse(response.body)
      process_events(events)
      log_rate_limit(response)
    else
      Rails.logger.error("Failed to fetch events: #{response.code} - #{response.message}")
      if response.code.to_i == 403 && response['X-RateLimit-Remaining'].to_i == 0
        Rails.logger.warn("Rate limit exceeded. Waiting for reset.")
      end
    end
  end

  private

  def fetch_events
    uri = URI(GITHUB_API_URL)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    
    request = Net::HTTP::Get.new(uri)
    request['User-Agent'] = 'StrongMind-Assessment-Candidate'
    request['Accept'] = 'application/vnd.github+json'
    
    http.request(request)
  end

  def process_events(events_data)
    push_events = events_data.select { |e| e['type'] == 'PushEvent' }
    Rails.logger.info("Found #{push_events.count} PushEvents out of #{events_data.count} total events.")

    push_events.each do |event_data|
      create_event(event_data)
    end
  end

  def create_event(data)
    # Check deduplication
    return if ::Event.exists?(github_id: data['id'])

    ActiveRecord::Base.transaction do
      # Find or Create Actor
      actor_data = data['actor']
      actor = ::Actor.find_or_create_by!(github_id: actor_data['id'].to_s) do |a|
        a.login = actor_data['login']
      end
      EnrichmentJob.perform_later(:actor, actor.id)

      # Find or Create Repository
      repo_data = data['repo']
      repo = ::Repository.find_or_create_by!(github_id: repo_data['id'].to_s) do |r|
        r.name = repo_data['name']
      end
      EnrichmentJob.perform_later(:repository, repo.id)

      # Create Event
      ::Event.create!(
        github_id: data['id'],
        type: data['type'],
        payload: data['payload'],
        actor: actor,
        repository: repo,
        created_at: data['created_at'] # Respect original event time
      )
    end
  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.error("Failed to save event #{data['id']}: #{e.message}")
  end

  def log_rate_limit(response)
    remaining = response['X-RateLimit-Remaining']
    reset = response['X-RateLimit-Reset']
    Rails.logger.info("Rate Limit: #{remaining} remaining. Resets at #{Time.at(reset.to_i)}")
  end
end
