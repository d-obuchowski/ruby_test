class ApiRequest
  def self.run(url)
    begin
      Faraday.get(url)
    rescue *[ URI::InvalidURIError, Faraday::Error ] => e
      nil
    end
  end
end
