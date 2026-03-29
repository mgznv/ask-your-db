module DashboardWidgetsHelper
  def execute_widget_query(widget)
    return [] unless widget.can_execute?
    
    begin
      sanitized_sql = ActiveRecord::Base.sanitize_sql(widget.sql_query)
      ActiveRecord::Base.connection.exec_query(sanitized_sql).to_a
    rescue => e
      Rails.logger.error "Error executing widget query: #{e.message}"
      []
    end
  end
end