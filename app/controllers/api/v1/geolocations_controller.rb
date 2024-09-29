module Api
  module V1
    class GeolocationsController < ApplicationController
      before_action :set_geolocation, only: [ :show, :destroy ]

      def index
        geolocations = Geolocation.all

        render json: geolocations, status: :ok
      end

      def show
        render json: @geolocation, status: :ok
      end

      def create
        form = GeolocationCreationForm.new(geolocation_params)
        geolocation = form.save

        if geolocation
          render json: geolocation, status: :created
        else
          render json: { errors: form.errors }, status: :unprocessable_entity
        end
      end

      def destroy
        if @geolocation.destroy
          head :no_content
        else
          render json: { errors: @geolocation.errors }, status: :unprocessable_entity
        end
      end

      private

      def set_geolocation
        @geolocation = Geolocation.find(id)
      end

      def geolocation_params
        params.require(:geolocation).permit(:address)
      end

      def id
        params["id"]
      end
    end
  end
end
