class MaintenanceTasksController < ApplicationController
  def show
    @task = MaintenanceTask.includes(:equipment, :supplies, :maintenance_logs).find(params[:id])

    respond_to do |format|
      format.html
      format.json { render json: @task.as_json(include: [:equipment, :supplies, :maintenance_logs]) }
    end
  end

  def complete
    @task = MaintenanceTask.find(params[:id])
    @task.complete!(notes: params[:notes])

    respond_to do |format|
      format.html { redirect_back fallback_location: maintenance_task_path(@task), notice: "#{@task.name} marked as complete!" }
      format.json { render json: @task.as_json(include: [:supplies, :maintenance_logs]) }
    end
  end
end
