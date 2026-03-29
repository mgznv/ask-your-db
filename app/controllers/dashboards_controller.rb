class DashboardsController < ApplicationController
  before_action :set_dashboard, only: [:show, :edit, :update, :destroy]
  
  def index
    @dashboards = Dashboard.includes(:dashboard_widgets).all
  end
  
  def show
    @dashboard_widgets = @dashboard.dashboard_widgets.includes(:dashboard)
    @new_widget = @dashboard.dashboard_widgets.build
  end
  
  def new
    @dashboard = Dashboard.new
  end
  
  def create
    @dashboard = Dashboard.new(dashboard_params)
    
    if @dashboard.save
      redirect_to @dashboard, notice: 'Dashboard creado exitosamente.'
    else
      render :new, status: :unprocessable_entity
    end
  end
  
  def edit
  end
  
  def update
    if @dashboard.update(dashboard_params)
      redirect_to @dashboard, notice: 'Dashboard actualizado exitosamente.'
    else
      render :edit, status: :unprocessable_entity
    end
  end
  
  def destroy
    @dashboard.destroy
    redirect_to dashboards_url, notice: 'Dashboard eliminado exitosamente.'
  end
  
  private
  
  def set_dashboard
    @dashboard = Dashboard.find(params[:id])
  end
  
  def dashboard_params
    params.require(:dashboard).permit(:name, :layout)
  end
end