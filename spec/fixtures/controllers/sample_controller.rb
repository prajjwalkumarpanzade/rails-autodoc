# frozen_string_literal: true

class SampleController < ActionController::API
  def create
    render json: Model.new(sample_params)
  end

  private

  def sample_params
    params.require(:sample).permit(:name, :email, address: %i[street city], tags: [])
  end
end
