class Card < ApplicationRecord

  belongs_to :user    #クレカ情報はuser_idのみへの連携

  #機能テストにて必要と確認した制約を追加
  # validates :user_id,        presence: true    #「belongs_to :user」で必須入力は効いているので不要
  validates :customer_id,    presence: true
  validates :payjp_id,       presence: true

end


