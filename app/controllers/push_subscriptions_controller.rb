class PushSubscriptionsController < ApplicationController
  skip_forgery_protection only: [ :create, :destroy ]

  def create
    subscription = PushSubscription.find_or_initialize_by(endpoint: params[:endpoint])
    subscription.p256dh = params[:keys][:p256dh]
    subscription.auth = params[:keys][:auth]

    if subscription.save
      head :created
    else
      head :unprocessable_entity
    end
  end

  def destroy
    subscription = PushSubscription.find_by(endpoint: params[:endpoint])
    subscription&.destroy
    head :ok
  end
end
