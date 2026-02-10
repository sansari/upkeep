class MaintenanceLogsController < ApplicationController
  def index
    @logs = MaintenanceLog.includes(maintenance_task: { equipment: :area }).order(completed_at: :desc)

    respond_to do |format|
      format.html
      format.json { render json: @logs.as_json(include: { maintenance_task: { include: { equipment: { include: :area } } } }) }
    end
  end
end
