require 'net/http'

class EnrichmentService
  def initialize(resource_type, resource_id)
    @resource_type = resource_type # :actor or :repository
    @resource_id = resource_id
  end

  def call
    resource = find_resource
    return unless resource
    return if resource.details.present? # Avoid re-fetching if already enriched

    url = build_url(resource)
    return unless url

    Rails.logger.info("Enriching #{@resource_type} #{resource.github_id}...")
    response = fetch_data(url)

    if response.is_a?(Net::HTTPSuccess)
      data = JSON.parse(response.body)
      resource.update!(details: data)
    else
      Rails.logger.error("Failed to enrich #{@resource_type} #{resource.id}: #{response.code}")
    end
  end

  private

  def find_resource
    case @resource_type
    when :actor then Actor.find_by(id: @resource_id)
    when :repository then Repository.find_by(id: @resource_id)
    end
  end

  def build_url(resource)
    case @resource_type
    when :actor
      "https://api.github.com/users/#{resource.login}"
    when :repository
      "https://api.github.com/repos/#{resource.name}"
    end
  end

  def fetch_data(url_string)
    uri = URI(url_string)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    
    request = Net::HTTP::Get.new(uri)
    request['User-Agent'] = 'StrongMind-Assessment-Candidate'
    request['Accept'] = 'application/vnd.github+json'
    
    http.request(request)
  end
end
