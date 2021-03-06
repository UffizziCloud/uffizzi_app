# frozen_string_literal: true

class UffizziCore::GoogleRegistryClient
  attr_accessor :connection, :token, :registry_url

  def initialize(registry_url:, username:, password:)
    @registry_url = registry_url
    @connection = build_connection(registry_url, username, password)
    @token = access_token&.result&.token
  end

  def manifests(image:, tag:)
    url = "/v2/#{image}/manifests/#{tag}"
    response = connection.get(url)

    RequestResult.quiet.new(result: response.body, headers: response.headers)
  end

  def access_token
    service = URI.parse(registry_url).hostname
    url = "/v2/token?service=#{service}"

    response = connection.get(url, {})

    RequestResult.new(result: response.body)
  end

  def authentificated?
    token.present?
  end

  private

  def build_connection(registry_url, username, password)
    Faraday.new(registry_url) do |conn|
      conn.request(:basic_auth, username, password)
      conn.request(:json)
      conn.response(:json)
      conn.adapter(Faraday.default_adapter)
    end
  end
end
