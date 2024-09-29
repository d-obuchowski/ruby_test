class ApplicationController < ActionController::API
  rescue_from ActionController::ParameterMissing do
    render json: { error: "Input parameters does not include all required data" }, status: :bad_request
  end

  rescue_from ActionDispatch::Http::Parameters::ParseError do
    render json: { error: "Parse error of input parameters" }, status: :bad_request
  end

  rescue_from ActiveRecord::RecordNotFound do
    render json: { error: "Object not found" }, status: :not_found
  end

  def not_found_method
    render json: { error: "Api endpoint does not exist" }, status: :not_found
  end
end
