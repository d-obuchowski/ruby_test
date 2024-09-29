class GeolocationCreationForm
  include ActiveModel::Model

  attr_accessor :address, :ip_address, :external_api_data
  validates :address, presence: true

  validate :address_is_valid
  validate :ip_address_is_unique
  validate :external_api_not_return_error
  validate :external_api_data_contain_required_fields

  SELECTED_API_FIELDS = %w[city zip country_name].freeze

  def initialize(params = {})
    super(params)
    set_ip_address
    set_external_api_data
  end

  def save
    return false unless valid?

    create_geolocation
  end

  private

  def address_is_valid
    return if errors.key?("address")

    errors.add("address", "is invalid") if ip_address.blank?
  end

  def ip_address_is_unique
    return if errors.key?("address")
    return unless exist_geolocation_with_the_same_ip?

    errors.add("address", "has already been taken")
  end

  def external_api_not_return_error
    return if errors.key?("address")

    errors.add(:base, "Internal problem with external Geolocation API") if external_api_data.blank?
    errors.add(:base, "Geolocation api returns error: #{external_api_error}") if external_api_error.present?
  end

  def external_api_data_contain_required_fields
    return if errors.key?("address") || errors.key?("base")

    error_msg = "Geolocation Api did not return value of this field"
    SELECTED_API_FIELDS.each do |field|
      errors.add(field.to_sym,  error_msg) if external_api_data[field].blank?
    end
  end

  def set_ip_address
    return if address.blank?

    @ip_address = IpAddressResolver.resolve(address)
  end

  def set_external_api_data
    return unless ip_address.present?

    @external_api_data = geolocation_fetcher.fetch(SELECTED_API_FIELDS)
  end

  def exist_geolocation_with_the_same_ip?
    Geolocation.exists?(ip_address: ip_address)
  end

  def create_geolocation
    params = set_creation_params
    Geolocation.create(params)
  end

  def geolocation_fetcher
    @geolocation_fetcher ||= GeolocationDataFetcher.new(ip_address)
  end

  def external_api_error
    return unless external_api_data

    @external_api_error ||= external_api_data["error"]
  end

  def set_creation_params
    external_api_data.merge(ip_address: ip_address)
  end
end
