class Account::JoinCodesController < ApplicationController
  def show
    render svg: RQRCode::QRCode.new(join_url(Account.sole.join_code)).as_svg(viewbox: true, fill: :white, color: :black)
  end

  def update
    Account.sole.reset_join_code
    redirect_to users_path
  end
end
