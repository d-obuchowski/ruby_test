require 'rails_helper'

describe Api::V1::GeolocationsController, type: :request do
  describe 'GET /api/v1/geolocations' do
    let!(:geolocation_1) { create(:geolocation) }
    let!(:geolocation_2) { create(:geolocation) }

    before { get api_v1_geolocations_path }

    it 'responds with ok status' do
      expect(response).to have_http_status :ok
    end

    it 'responds with geolocations' do
      parsed_response = JSON.parse(response.body)

      expect(parsed_response.length).to eq(2)
      expect(parsed_response.first['id']).to eq (geolocation_1.id)
      expect(parsed_response.second['id']).to eq (geolocation_2.id)
    end

    context 'when endpoint url is invalid' do
      it 'responds with ok status' do
        get api_v1_geolocations_path + "invalid_path"
        expect(response).to have_http_status :not_found
      end

      it 'responds with error' do
        get api_v1_geolocations_path + "invalid_path"
        parsed_response = JSON.parse(response.body)

        expect(parsed_response['error']).to eq('Api endpoint does not exist')
      end
    end
  end

  describe 'GET /api/v1/geolocations/:id' do
    let!(:geolocation) { create(:geolocation) }

    it 'responds with ok status' do
      get api_v1_geolocation_path(geolocation.id)
      expect(response).to have_http_status :ok
    end

    it 'responds with geolocation' do
      get api_v1_geolocation_path(geolocation.id)
      parsed_response = JSON.parse(response.body)

      expect(parsed_response['id']).to eq(geolocation.id)
      expect(parsed_response['city']).to eq(geolocation.city)
      expect(parsed_response['ip_address']).to eq(geolocation.ip_address)
      expect(parsed_response['country_name']).to eq(geolocation.country_name)
    end


    context 'when id is invalid' do
      it 'responds with not_found status' do
        get api_v1_geolocation_path('invalid_id')
        expect(response).to have_http_status :not_found
      end

      it 'responds with errors' do
        get api_v1_geolocation_path('invalid_id')
        parsed_response = JSON.parse(response.body)

        expect(parsed_response['error']).to eq('Object not found')
      end
    end
  end

  describe 'DELETE /api/v1/geolocations/:id' do
    let!(:geolocation) { create(:geolocation) }

    before do
      delete api_v1_geolocation_path(geolocation.id)
    end

    it 'responds with no_content status' do
      expect(response).to have_http_status :no_content
    end

    it 'returns an empty response body' do
      expect(response.body).to be_empty
    end
  end


  describe 'POST /api/v1/geolocations' do
    let(:params) do
      {
        geolocation: {
          address: address
        }
      }
    end
    let(:geolocation) { double(:geolocation) }

    let(:creation_form) do
      instance_double(GeolocationCreationForm, save: nil, errors: [])
    end

    before do
      allow(GeolocationCreationForm).to receive(:new).with(strong_params address: address).and_return(creation_form)
    end

    context 'when form is valid' do
      before do
        allow(creation_form).to receive(:save).and_return(geolocation)
      end
      let(:address) { '77.46.83.45' }

      it 'responds with created status' do
        post api_v1_geolocations_path, params: params

        expect(response).to have_http_status :created
      end
    end

    context 'when form is invalid' do
      let(:address) { '' }
      let(:errors) do
        {
          'address' => [
            "has already been taken"
          ]
        }
      end

      before do
        allow(creation_form).to receive(:save).and_return(nil)
        allow(creation_form).to receive(:errors).and_return(errors)
      end

      it 'responds with unprocessable_entity status' do
        post api_v1_geolocations_path, params: params

        expect(response).to have_http_status :unprocessable_entity
      end

      it 'responds with errors' do
        post api_v1_geolocations_path, params: params
        parsed_response = JSON.parse(response.body)

        expect(parsed_response['errors']).to eq(errors)
      end

      context 'when input params does not include all required parameters' do
        let(:params) { }

        it 'responds with bad_request status' do
          post api_v1_geolocations_path, params: params

          expect(response).to have_http_status :bad_request
        end

        it 'responds with errors' do
          post api_v1_geolocations_path, params: params
          parsed_response = JSON.parse(response.body)

          expect(parsed_response['error']).to eq('Input parameters does not include all required data')
        end
      end

      context 'when input params does not include proper json string'  do
        let(:headers) do
          {
            'Content-Type' => 'application/json'
          }
        end

        let(:params) { 'asfasfasfas' }

        it 'responds with bad_request status' do
          post api_v1_geolocations_path, params: params, headers: headers

          expect(response).to have_http_status :bad_request
        end

        it 'responds with errors' do
          post api_v1_geolocations_path, params: params, headers: headers
          parsed_response = JSON.parse(response.body)

          expect(parsed_response['error']).to eq('Parse error of input parameters')
        end
      end
    end
  end
end
