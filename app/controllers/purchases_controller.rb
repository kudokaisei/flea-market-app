class PurchasesController < ApplicationController
  require 'payjp'
  before_action :set_card, :set_item
  before_action :move_to_index, only: [:new]
  before_action :move_to_show, only: [:new]

  def new
    @purchase = Purchase.new
    @deliverycharge = Deliverycharge.find(@item.delivery_charge)
   
    @address = Address.find_by(user_id: current_user.id)
    @prefecture = Prefecture.find(@address.prefectures_area)
    
    Payjp.api_key = Rails.application.credentials.payjp[:PAYJP_SECRET_KEY]
    @card = Card.find_by(user_id: current_user.id)
    if @card.blank?
      redirect_to new_card_url 
    else
    customer = Payjp::Customer.retrieve(@card.customer_id)
    @default_card_information = customer.cards.retrieve(@card.payjp_id)
    end
  end

  def create
    @purchase = Purchase.new(user_id:   current_user.id,
                            item_id:  @item.id
                           )
    if @purchase.save
      Payjp.api_key = Rails.application.credentials.payjp[:PAYJP_SECRET_KEY]
      Payjp::Charge.create(
      amount: @item.price,
      customer: @card.customer_id, #顧客ID
      currency: 'jpy', #日本円
    )
      redirect_to root_path, notice: "購入が完了しました"
    else
      render :new
    end
  end


  private

  def set_card
    @card = Card.find_by(user_id: current_user.id)
  end

  def set_item
    @item = Item.find(params[:item_id])
  end

  def move_to_index
    if user_signed_in? && current_user.id == @item.user_id
      redirect_to item_path(@item.id)
    end
  end

  def move_to_show
    if @item.purchase.present?
      redirect_to item_path(@item.id)
    end
  end

end
