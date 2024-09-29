class IpAddressResolver
  def self.resolve(address)
    begin
      return address if address_is_ip_address?(address)

      uri = URI.parse(address)
      IPSocket.getaddress(uri.host)
    rescue URI::InvalidURIError
      nil
    end
  end

  private

  def self.address_is_ip_address?(address)
    !!(address =~ Resolv::AddressRegex)
  end
end
