class Account::EntropyConfigurationsController < ApplicationController
  def update
    Entropy::Configuration.default.update!(entropy_configuration_params)

    redirect_to account_settings_path, notice: "Account updated"
  end

  private
    def entropy_configuration_params
      params.expect(entropy_configuration: [ :auto_close_period, :auto_reconsider_period ])
    end
end
