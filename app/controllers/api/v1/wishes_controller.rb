class Api::V1::WishesController < ApplicationController
  before_action :authenticate_with_token!, only: [:create, :update, :destroy]
  respond_to :json

  def show
    respond_with Wish.find(params[:id])
  end

  def index
    wish = Wish.search(params).page(params[:page]).per(params[:per_page])
    render json: wish, meta: { pagination:
                                   { per_page: params[:per_page],
                                     total_pages: wish.total_pages,
                                     total_objects: wish.total_count } }
  end

  def create
    wish = current_user.wishes.build(wish_params)
    if wish.save
      # wish.reload
      # WishMailer.delay.send_confirmation(order)
      render json: wish, status: 201, location: [:api, wish]
    else
      render json: { errors: wish.errors }, status: 422
    end
  end

  def update
    wish = current_user.wishes.find(params[:id])
    if wish.update(wish_params)
      render json: wish, status: 200, location: [:api, wish]
    else
      render json: { errors: wish.errors }, status: 422
    end
  end

  def destroy
    wish = current_user.wishes.find(params[:id])
    wish.destroy
    head 204
  end

  private

    def wish_params
      params.require(:wish).permit(:name, :price, :image_url, :page_url)
    end
end
