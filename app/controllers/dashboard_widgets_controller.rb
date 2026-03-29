class DashboardWidgetsController < ApplicationController
  before_action :set_dashboard
  before_action :set_dashboard_widget, only: [:edit, :update, :destroy, :approve, :reject, :execute, :regenerate_sql, :update_chart_type]
  
  def create
    @dashboard_widget = @dashboard.dashboard_widgets.build(dashboard_widget_params)
    
    if @dashboard_widget.save
      process_natural_query
      respond_to do |format|
        format.turbo_stream { render :create }
        format.html { redirect_to @dashboard, notice: 'Widget creado exitosamente.' }
      end
    else
      respond_to do |format|
        format.turbo_stream { render :create_error }
        format.html { redirect_to @dashboard, alert: 'Error al crear el widget.' }
      end
    end
  end
  
  def edit
  end
  
  def update
    if @dashboard_widget.update(dashboard_widget_params)
      respond_to do |format|
        format.turbo_stream { render :update }
        format.html { redirect_to @dashboard, notice: 'Widget actualizado exitosamente.' }
      end
    else
      respond_to do |format|
        format.turbo_stream { render :update_error }
        format.html { redirect_to @dashboard, alert: 'Error al actualizar el widget.' }
      end
    end
  end
  
  def destroy
    @dashboard_widget.destroy
    respond_to do |format|
      format.turbo_stream { render :destroy }
      format.html { redirect_to @dashboard, notice: 'Widget eliminado exitosamente.' }
    end
  end
  
  def approve
    @dashboard_widget.approve!
    respond_to do |format|
      format.turbo_stream { render :approve }
      format.html { redirect_to @dashboard, notice: 'Widget aprobado exitosamente.' }
    end
  end
  
  def reject
    @dashboard_widget.reject!
    respond_to do |format|
      format.turbo_stream { render :reject }
      format.html { redirect_to @dashboard, notice: 'Widget rechazado.' }
    end
  end
  
  def execute
    return redirect_to @dashboard, alert: 'Widget no aprobado' unless @dashboard_widget.can_execute?
    
    begin
      @results = execute_sql_query(@dashboard_widget.sql_query)
      respond_to do |format|
        format.turbo_stream { render :execute }
        format.json { render json: { success: true, data: @results } }
        format.html { redirect_to @dashboard }
      end
    rescue => e
      Rails.logger.error "Error ejecutando query: #{e.message}"
      respond_to do |format|
        format.turbo_stream { render :execute_error }
        format.json { render json: { success: false, error: e.message } }
        format.html { redirect_to @dashboard, alert: 'Error ejecutando la consulta.' }
      end
    end
  end
  
  def regenerate_sql
    service = NaturalQueryService.new(@dashboard_widget.natural_query)
    result = service.process
    
    if result[:success]
      @dashboard_widget.update!(
        sql_query: result[:sql],
        chart_type: result[:suggested_chart_type],
        status: 'pending'
      )
      
      respond_to do |format|
        format.turbo_stream { render :regenerate_sql }
        format.html { redirect_to @dashboard, notice: 'SQL regenerado exitosamente.' }
      end
    else
      respond_to do |format|
        format.turbo_stream { render :regenerate_sql_error }
        format.html { redirect_to @dashboard, alert: "Error: #{result[:error]}" }
      end
    end
  end

  def update_chart_type
    chart_type = params[:chart_type]
    
    if @dashboard_widget.update(chart_type: chart_type)
      respond_to do |format|
        format.json { render json: { success: true, chart_type: chart_type } }
        format.html { redirect_to @dashboard, notice: 'Tipo de gráfico actualizado.' }
      end
    else
      respond_to do |format|
        format.json { render json: { success: false, error: 'Error al actualizar tipo de gráfico' } }
        format.html { redirect_to @dashboard, alert: 'Error al actualizar tipo de gráfico.' }
      end
    end
  end
  
  private
  
  def set_dashboard
    @dashboard = Dashboard.find(params[:dashboard_id])
  end
  
  def set_dashboard_widget
    @dashboard_widget = @dashboard.dashboard_widgets.find(params[:id])
  end
  
  def dashboard_widget_params
    params.require(:dashboard_widget).permit(:title, :natural_query, :sql_query, :chart_type, :chart_config, :position)
  end
  
  def process_natural_query
    return unless @dashboard_widget.natural_query.present?
    
    service = NaturalQueryService.new(@dashboard_widget.natural_query)
    result = service.process
    
    if result[:success]
      @dashboard_widget.update!(
        sql_query: result[:sql],
        chart_type: result[:suggested_chart_type]
      )
      @query_result = result
    else
      @query_error = result[:error]
    end
  end
  
  def execute_sql_query(sql_query)
    return [] if sql_query.blank?
    
    sanitized_sql = ActiveRecord::Base.sanitize_sql(sql_query)
    ActiveRecord::Base.connection.exec_query(sanitized_sql).to_a
  end
end