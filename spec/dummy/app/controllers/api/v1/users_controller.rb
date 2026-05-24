# frozen_string_literal: true

module Api
  module V1
    class UsersController < ActionController::API
      def index
        render json: User.all
      end

      def show
        user = User.find(params[:id])
        render json: user
      end

      def create
        user = User.new(user_params)
        if user.save
          render json: user, status: :created
        else
          render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        user = User.find(params[:id])
        if user.update(user_params)
          render json: user
        else
          render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        User.find(params[:id]).destroy!
        head :no_content
      end

      private

      def user_params
        params.require(:user).permit(:name, :email, :age, address: %i[street city], tags: [])
      end
    end
  end
end
