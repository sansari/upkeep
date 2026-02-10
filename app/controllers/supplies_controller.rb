class SuppliesController < ApplicationController
  def index
    @supplies = Supply.includes(maintenance_task: { equipment: :area }).order(:name)

    respond_to do |format|
      format.html
      format.json { render json: @supplies.as_json(include: { maintenance_task: { include: { equipment: { include: :area } } } }) }
    end
  end
end
