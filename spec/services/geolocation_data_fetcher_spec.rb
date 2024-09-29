require 'rails_helper'

describe GeolocationDataFetcher do
  let(:ip_address) { '77.46.83.45' }
  subject(:described_object) { described_class.new(ip_address) }
  let(:fields) { %w[city zip country_name] }

  describe '#fetch' do
    let(:expected_data) do
      {
        "city"=>"Białystok",
        "zip"=>"15-668",
        "country_name"=>"Poland"
      }
    end
    subject { described_object.fetch(fields) }

    context 'when external api returns successful response' do
      it 'returns parsed data' do
        VCR.use_cassette("external_api_success_response") do
          expect(subject).to eq(expected_data)
        end
      end
    end

    context "when ip address is invalid" do
      let(:ip_address) { 'fiowhjgo jh92ur02u83 0eru2r902u' }

      it 'returns nil' do
        expect(subject).to eq(nil)
      end
    end

    context "when the connection to external api failed" do
      before do
        allow(Faraday).to receive(:get).and_raise(Faraday::Error)
      end

      it 'returns nil' do
        expect(subject).to eq(nil)
      end
    end

    context "when external api returns not found error" do
      let(:ip_address) { 'asdadas/asdas/' }

      it 'returns error' do
        VCR.use_cassette("external_api_not_found_error") do
          expect(subject).to eq({ 'error' => 'Resource not found' })
        end
      end
    end

    context 'when external api returns 302 error' do
      let(:ip_address) { '' }
      let(:error_response_body) do
        "<html>\r\n<head><title>302 Found</title></head>\r\n<body>\r\n<center><h1>302 Found</h1></center>\r\n<hr>" \
          "<center>nginx</center>\r\n</body>\r\n</html>\r\n"
      end

      it 'returns error' do
        VCR.use_cassette("external_api_302_error") do
          expect(subject).to eq({ 'error' => error_response_body })
        end
      end
    end

    context 'when external api returns not success error' do
      let(:ip_address) { '77.46.83.45ffffffff' }

      it 'returns error' do
        VCR.use_cassette('external_api_not_success_error') do
          expect(subject).to eq({ 'error' => 'The IP Address supplied is invalid.' })
        end
      end
    end
  end
end
