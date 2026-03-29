// Funciones globales para manejar widgets y gráficos

// Función para actualizar gráficos
function updateChart(widgetId, chartType) {
  console.log(`Updating chart ${widgetId} to type ${chartType}`);
  
  const canvas = document.getElementById(`chart-${widgetId}`);
  const tableDiv = document.getElementById(`table-${widgetId}`);
  
  if (!canvas || !tableDiv) return;
  
  // Actualizar botones visualmente
  updateChartButtons(widgetId, chartType);
  
  // Guardar selección en base de datos
  saveChartType(widgetId, chartType);
  
  // Mostrar/ocultar según el tipo
  if (chartType === 'table') {
    canvas.style.display = 'none';
    tableDiv.style.display = 'block';
  } else {
    canvas.style.display = 'block';
    tableDiv.style.display = 'none';
    
    // Crear un gráfico simple
    createSimpleChart(canvas, chartType, widgetId);
  }
}

function updateChartButtons(widgetId, activeType) {
  const types = ['table', 'bar', 'line', 'pie', 'area'];
  
  types.forEach(type => {
    const button = document.getElementById(`btn-${type}-${widgetId}`);
    if (button) {
      if (type === activeType) {
        // Botón activo
        button.className = button.className.replace(/bg-gray-50 border-gray-200 text-gray-600/, 'bg-blue-100 border-blue-300 text-blue-800');
      } else {
        // Botón inactivo
        button.className = button.className.replace(/bg-blue-100 border-blue-300 text-blue-800/, 'bg-gray-50 border-gray-200 text-gray-600');
      }
    }
  });
}

function saveChartType(widgetId, chartType) {
  // Obtener dashboard ID del DOM
  const widgetElement = document.getElementById(`widget_${widgetId}`);
  const dashboardId = widgetElement ? widgetElement.closest('[data-dashboard-id]')?.dataset.dashboardId : null;
  
  if (!dashboardId) {
    console.error('Dashboard ID not found');
    return;
  }
  
  fetch(`/dashboards/${dashboardId}/dashboard_widgets/${widgetId}/update_chart_type`, {
    method: 'PATCH',
    headers: {
      'Content-Type': 'application/json',
      'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').getAttribute('content')
    },
    body: JSON.stringify({ chart_type: chartType })
  })
  .then(response => response.json())
  .then(data => {
    if (data.success) {
      console.log(`Chart type saved: ${data.chart_type}`);
    } else {
      console.error('Error saving chart type:', data.error);
    }
  })
  .catch(error => {
    console.error('Error:', error);
  });
}

function createSimpleChart(canvas, chartType, widgetId) {
  // Extraer datos de la tabla
  const table = document.querySelector(`#table-${widgetId} table`);
  if (!table) return;
  
  const headers = Array.from(table.querySelectorAll('thead th')).map(th => th.textContent.trim());
  const rows = Array.from(table.querySelectorAll('tbody tr')).map(tr => 
    Array.from(tr.querySelectorAll('td')).map(td => td.textContent.trim())
  );
  
  // Preparar datos para gráfico
  const labels = rows.map(row => row[0]);
  const data = rows.map(row => {
    const value = parseFloat(row[1]);
    return isNaN(value) ? 0 : value;
  });
  
  // Crear el gráfico
  const ctx = canvas.getContext('2d');
  
  // Limpiar canvas
  ctx.clearRect(0, 0, canvas.width, canvas.height);
  
  // Dibujar según el tipo
  if (chartType === 'bar') {
    drawBarChart(ctx, labels, data, canvas.width, canvas.height);
  } else if (chartType === 'line') {
    drawLineChart(ctx, labels, data, canvas.width, canvas.height);
  } else if (chartType === 'pie') {
    drawPieChart(ctx, labels, data, canvas.width, canvas.height);
  } else {
    // Para otros tipos, mostrar mensaje
    ctx.fillStyle = '#374151';
    ctx.font = '16px sans-serif';
    ctx.textAlign = 'center';
    ctx.fillText(`Gráfico ${chartType}`, canvas.width/2, canvas.height/2);
  }
}

function drawBarChart(ctx, labels, data, width, height) {
  const padding = 40;
  const barWidth = Math.max((width - padding * 2) / labels.length, 20);
  const maxValue = Math.max(...data, 1);
  const scale = (height - padding * 2) / maxValue;
  
  // Limpiar
  ctx.clearRect(0, 0, width, height);
  
  // Dibujar barras
  ctx.fillStyle = '#3B82F6';
  data.forEach((value, index) => {
    const barHeight = value * scale;
    const x = padding + index * barWidth;
    const y = height - padding - barHeight;
    
    ctx.fillRect(x, y, barWidth - 5, barHeight);
  });
  
  // Dibujar etiquetas
  ctx.fillStyle = '#374151';
  ctx.font = '10px sans-serif';
  ctx.textAlign = 'center';
  labels.forEach((label, index) => {
    const x = padding + index * barWidth + barWidth / 2;
    ctx.fillText(label.substring(0, 8), x, height - 10);
  });
}

function drawLineChart(ctx, labels, data, width, height) {
  const padding = 40;
  const stepX = (width - padding * 2) / (labels.length - 1);
  const maxValue = Math.max(...data, 1);
  const scale = (height - padding * 2) / maxValue;
  
  // Limpiar
  ctx.clearRect(0, 0, width, height);
  
  // Dibujar línea
  ctx.strokeStyle = '#3B82F6';
  ctx.lineWidth = 2;
  ctx.beginPath();
  
  data.forEach((value, index) => {
    const x = padding + index * stepX;
    const y = height - padding - (value * scale);
    
    if (index === 0) {
      ctx.moveTo(x, y);
    } else {
      ctx.lineTo(x, y);
    }
  });
  
  ctx.stroke();
  
  // Dibujar puntos
  ctx.fillStyle = '#3B82F6';
  data.forEach((value, index) => {
    const x = padding + index * stepX;
    const y = height - padding - (value * scale);
    
    ctx.beginPath();
    ctx.arc(x, y, 3, 0, 2 * Math.PI);
    ctx.fill();
  });
}

function drawPieChart(ctx, labels, data, width, height) {
  const centerX = width / 2;
  const centerY = height / 2;
  const radius = Math.min(width, height) / 2 - 20;
  const total = data.reduce((sum, value) => sum + value, 0);
  
  // Limpiar
  ctx.clearRect(0, 0, width, height);
  
  let currentAngle = 0;
  const colors = ['#3B82F6', '#10B981', '#F59E0B', '#EF4444', '#8B5CF6'];
  
  data.forEach((value, index) => {
    const angle = (value / total) * 2 * Math.PI;
    
    ctx.fillStyle = colors[index % colors.length];
    ctx.beginPath();
    ctx.moveTo(centerX, centerY);
    ctx.arc(centerX, centerY, radius, currentAngle, currentAngle + angle);
    ctx.closePath();
    ctx.fill();
    
    currentAngle += angle;
  });
}

// Hacer funciones disponibles globalmente
window.updateChart = updateChart;
window.saveChartType = saveChartType;
window.createSimpleChart = createSimpleChart;