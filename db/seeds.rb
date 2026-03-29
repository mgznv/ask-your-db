# Seeds para el dashboard

# Crear dashboard de ejemplo
dashboard = Dashboard.find_or_create_by!(name: "Dashboard de Ejemplo") do |d|
  d.layout = {}
end

puts "Dashboard creado/encontrado: #{dashboard.name}"

# Crear algunos widgets de ejemplo
widgets = [
  {
    title: "Ventas por Mes",
    natural_query: "Muestra las ventas agrupadas por mes del último año",
    chart_type: "line"
  },
  {
    title: "Top 10 Productos",
    natural_query: "Los 10 productos más vendidos en orden descendente",
    chart_type: "bar"
  },
  {
    title: "Distribución por Categorías",
    natural_query: "Porcentaje de ventas por categoría de producto",
    chart_type: "pie"
  }
]

widgets.each do |widget_data|
  widget = dashboard.dashboard_widgets.find_or_create_by!(
    title: widget_data[:title]
  ) do |w|
    w.natural_query = widget_data[:natural_query]
    w.chart_type = widget_data[:chart_type]
    w.status = 'pending'
  end
  puts "Widget creado/encontrado: #{widget.title}"
end

puts "\n🎉 Seeds ejecutados exitosamente!"
puts "Visita http://localhost:3000 para ver tu dashboard"
