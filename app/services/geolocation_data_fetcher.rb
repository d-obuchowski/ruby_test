class GeolocationDataFetcher
  BASE_API_URL = "https://api.ipstack.com".freeze

  def initialize(ip_address)
    @ip_address = ip_address
  end

  def fetch(fields)
    make_api_request
    return unless response

    parsed_body = parse_body
    successful_result = select_fields(fields, parsed_body)
    successful_result.presence || fetch_api_error(parsed_body)
  end

  private

  attr_reader :ip_address, :response

  def fetch_api_error(parsed_body)
    error_msg = prepare_error_msg(parsed_body)
    return unless error_msg

    { "error" => error_msg }
  end

  def prepare_error_msg(parsed_body)
    return response.body if response.status != 200
    return unless parsed_body
    return "Resource not found" if parsed_body.dig("detail").present?

    parsed_body.dig("error", "info")
  end

  def make_api_request
    @response = ApiRequest.run(full_url)
  end

  def parse_body
    begin
      JSON.parse(response.body)
    rescue JSON::ParserError
      nil
    end
  end

  def full_url
    "#{BASE_API_URL}/#{ip_address}?access_key=#{api_key}"
  end

  def api_key
    ENV["GEOLOCATION_API_KEY"]
  end

  def select_fields(fields, parsed_body)
    return unless parsed_body

    {}.tap do |results|
      fields.each { |key| results[key] = parsed_body[key] if parsed_body[key].present? }
    end
  end
end
