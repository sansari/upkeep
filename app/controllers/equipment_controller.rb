class EquipmentController < ApplicationController
  def show
    @equipment = Equipment.includes(:area, maintenance_tasks: :supplies).find(params[:id])

    respond_to do |format|
      format.html
      format.json { render json: @equipment.as_json(include: [:area, { maintenance_tasks: { include: :supplies } }]) }
    end
  end
end
