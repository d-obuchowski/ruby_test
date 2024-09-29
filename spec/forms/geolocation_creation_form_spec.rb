require 'rails_helper'

describe GeolocationCreationForm do
  let(:params) do
    {
      'address' => address
    }
  end
  subject(:described_object) { described_class.new(params) }

  describe '#save' do
    subject { described_object.save }

    let(:geolocation_data_fetcher) do
      instance_double(GeolocationDataFetcher)
    end
    let(:selected_api_fields) { %w[city zip country_name] }
    let(:city) { "Białystok" }
    let(:zip) { "15-668" }
    let(:country_name) { "Poland" }
    let(:external_api_response) do
      {
        "city" => city,
        "zip" => zip,
        "country_name" => country_name
      }
    end

    before do
      allow(GeolocationDataFetcher).to receive(:new).with(ip_address).and_return(geolocation_data_fetcher)
      allow(geolocation_data_fetcher).to receive(:fetch).with(selected_api_fields).and_return(external_api_response)
    end

    context 'when form is valid' do
      context 'when address is ip address' do
        let(:address) { '77.46.83.45' }
        let(:ip_address) { address }

        it 'creates geolocation with ip address and with data from external api' do
          geolocation = subject

          expect(geolocation).not_to be_nil
          expect(geolocation.ip_address).to eq(ip_address)
          expect(geolocation.city).to eq(city)
          expect(geolocation.zip).to eq(zip)
          expect(geolocation.country_name).to eq(country_name)
        end
      end

      context 'when address is url address' do
        let(:address) { 'https://www.google.com' }
        let(:ip_address) { '216.58.215.100' }

        it 'creates geolocation with converted url address on ip and with data from external api' do
          geolocation = subject

          expect(geolocation).not_to be_nil
          expect(geolocation.ip_address).to eq(ip_address)
          expect(geolocation.city).to eq(city)
          expect(geolocation.zip).to eq(zip)
          expect(geolocation.country_name).to eq(country_name)
        end
      end
    end

    context 'when form is invalid' do
      let(:address) { '' }
      let(:ip_address) { nil }

      context 'when address is blank' do
        it 'returns proper validation error' do
          subject

          expect(described_object.valid?).to eq(false)
          expect(described_object.errors.size).to eq 1
          expect(described_object.errors['address']).to eq [ "can't be blank" ]
        end
      end

      context 'when address is invalid' do
        let(:ip_address) { nil }
        let(:expected_message) { "is invalid. Please insert value: e.g https://www.google.com or 216.58.215.100" }

        context 'when address contains numbers, letters and spaces' do
          let(:address) { '2jf8923hfh bc82fb8fghf892yur07y' }

          it 'returns proper validation error' do
            subject

            expect(described_object.valid?).to eq(false)
            expect(described_object.errors.size).to eq 1
            expect(described_object.errors['address']).to eq [ expected_message ]
          end
        end

        context 'when address contains only numbers' do
          let(:address) { '333333' }

          it 'returns proper validation error' do
            subject

            expect(described_object.valid?).to eq(false)
            expect(described_object.errors.size).to eq 1
            expect(described_object.errors['address']).to eq [ expected_message ]
          end
        end
      end

      context 'when address already exists in database' do
        let!(:geolocation) { create(:geolocation) }

        let(:address) { geolocation.ip_address }
        let(:ip_address) { geolocation.ip_address }

        it 'returns proper validation error' do
          subject

          expect(described_object.valid?).to eq(false)
          expect(described_object.errors.size).to eq 1
          expect(described_object.errors['address']).to eq [ "has already been taken" ]
        end
      end

      context 'when external api does not return any data' do
        let(:address) { '77.46.83.45' }
        let(:ip_address) { address }

        before do
          allow(geolocation_data_fetcher).to receive(:fetch).with(selected_api_fields).and_return(nil)
        end

        it 'returns proper validation error' do
          subject

          expect(described_object.valid?).to eq(false)
          expect(described_object.errors.size).to eq 1
          expect(described_object.errors['base']).to eq [ "Internal problem with external Geolocation API" ]
        end
      end

      context 'when external api returns error' do
        let(:address) { '77.46.83.45' }
        let(:ip_address) { address }
        let(:external_api_error) { 'some api error' }

        before do
          allow(geolocation_data_fetcher).to receive(:fetch).with(selected_api_fields).and_return({ 'error' => external_api_error })
        end

        it 'returns proper validation error' do
          subject

          expect(described_object.valid?).to eq(false)
          expect(described_object.errors.size).to eq 1
          expect(described_object.errors['base']).to eq [ "Geolocation api returns error: #{external_api_error}" ]
        end
      end

      context 'when external api data does not contain required fields' do
        let(:address) { '77.46.83.45' }
        let(:ip_address) { address }
        let(:external_api_response) do
          {
            "country_name" => country_name
          }
        end

        before do
          allow(geolocation_data_fetcher).to receive(:fetch).with(selected_api_fields).and_return(external_api_response)
        end

        it 'returns proper validation error' do
          subject

          expect(described_object.valid?).to eq(false)
          expect(described_object.errors.size).to eq 2
          expect(described_object.errors['city']).to eq [ 'Geolocation Api did not return value of this field' ]
          expect(described_object.errors['zip']).to eq [ 'Geolocation Api did not return value of this field' ]
        end
      end
    end
  end
end
