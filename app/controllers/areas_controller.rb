class AreasController < ApplicationController
  def index
    @areas = Area.all

    respond_to do |format|
      format.html
      format.json { render json: @areas }
    end
  end

  def show
    @area = Area.find(params[:id])
    @equipment = @area.equipment.includes(:maintenance_tasks)

    respond_to do |format|
      format.html
      format.json { render json: @area.as_json(include: { equipment: { include: :maintenance_tasks } }) }
    end
  end
end
