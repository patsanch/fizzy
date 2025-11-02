class Account::SettingsController < ApplicationController
  before_action :ensure_admin, only: :update

  def show
    @account = Account.sole
    @users = User.active.alphabetically
  end

  def update
    Account.sole.update!(account_params)
    redirect_to account_settings_path
  end

  private
    def account_params
      params.expect account: %i[ name ]
    end
end
