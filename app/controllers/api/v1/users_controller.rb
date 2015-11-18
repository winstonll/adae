class Api::V1::UsersController < ApplicationController
  def show
    user = User.find(params[:id])

    render(json: Api::V1::UserSerializer.new(user).to_json)
  end
end
