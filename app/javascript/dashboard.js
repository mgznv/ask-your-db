import Chart from 'chart.js/auto'

class DashboardManager {
  constructor() {
    this.charts = new Map()
    this.initializeEventListeners()
  }

  initializeEventListeners() {
    // Show/Hide new widget form
    document.addEventListener('click', (e) => {
      if (e.target.matches('[data-action="click->dashboard#showNewWidgetForm"]')) {
        this.showNewWidgetForm()
      }
      if (e.target.matches('[data-action="click->dashboard#hideNewWidgetForm"]')) {
        this.hideNewWidgetForm()
      }
    })

    // Handle chart type changes
    document.addEventListener('change', (e) => {
      if (e.target.id && e.target.id.startsWith('chart-type-')) {
        const widgetId = e.target.id.replace('chart-type-', '')
        this.updateChart(widgetId, e.target.value)
      }
    })
  }

  showNewWidgetForm() {
    const form = document.getElementById('new-widget-form')
    if (form) {
      form.classList.remove('hidden')
      // Focus on first input
      const firstInput = form.querySelector('input[type="text"]')
      if (firstInput) firstInput.focus()
    }
  }

  hideNewWidgetForm() {
    const form = document.getElementById('new-widget-form')
    if (form) {
      form.classList.add('hidden')
      // Clear form
      const inputs = form.querySelectorAll('input, textarea')
      inputs.forEach(input => input.value = '')
    }
  }

  updateChart(widgetId, chartType) {
    // Get the canvas element
    const canvas = document.getElementById(`chart-${widgetId}`)
    if (!canvas) return

    // Get data from the table
    const tableData = this.extractTableData(widgetId)
    if (!tableData) return

    // Destroy existing chart if it exists
    if (this.charts.has(widgetId)) {
      this.charts.get(widgetId).destroy()
    }

    // Hide/show table based on chart type
    const table = canvas.closest('.bg-blue-50').querySelector('table')
    if (table) {
      table.style.display = chartType === 'table' ? 'table' : 'none'
    }

    // Hide canvas for table view
    canvas.style.display = chartType === 'table' ? 'none' : 'block'

    if (chartType === 'table') return

    // Create new chart
    const chart = this.createChart(canvas, chartType, tableData)
    this.charts.set(widgetId, chart)
  }

  extractTableData(widgetId) {
    const resultsDiv = document.getElementById(`widget-results-${widgetId}`)
    if (!resultsDiv) return null

    const table = resultsDiv.querySelector('table')
    if (!table) return null

    const headers = Array.from(table.querySelectorAll('thead th')).map(th => th.textContent.trim())
    const rows = Array.from(table.querySelectorAll('tbody tr')).map(tr => 
      Array.from(tr.querySelectorAll('td')).map(td => td.textContent.trim())
    )

    return { headers, rows }
  }

  createChart(canvas, chartType, tableData) {
    const { headers, rows } = tableData

    // Prepare data for Chart.js
    const labels = rows.map(row => row[0]) // First column as labels
    const datasets = []

    // Create dataset(s) from remaining columns
    for (let i = 1; i < headers.length; i++) {
      const data = rows.map(row => {
        const value = parseFloat(row[i])
        return isNaN(value) ? 0 : value
      })

      datasets.push({
        label: headers[i],
        data: data,
        backgroundColor: this.generateColors(data.length, i),
        borderColor: this.generateColors(data.length, i, 1),
        borderWidth: 1,
        fill: chartType === 'area'
      })
    }

    const config = {
      type: chartType === 'area' ? 'line' : chartType,
      data: {
        labels: labels,
        datasets: datasets
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        plugins: {
          legend: {
            display: datasets.length > 1
          }
        },
        scales: this.getScales(chartType)
      }
    }

    return new Chart(canvas, config)
  }

  generateColors(count, datasetIndex = 0, alpha = 0.6) {
    const colors = [
      `rgba(59, 130, 246, ${alpha})`, // Blue
      `rgba(16, 185, 129, ${alpha})`, // Green
      `rgba(245, 158, 11, ${alpha})`, // Yellow
      `rgba(239, 68, 68, ${alpha})`,  // Red
      `rgba(139, 92, 246, ${alpha})`, // Purple
      `rgba(236, 72, 153, ${alpha})`  // Pink
    ]

    if (count === 1 || datasetIndex === 0) {
      return colors[datasetIndex % colors.length]
    }

    return colors.map((color, index) => 
      color.replace(`${alpha}`, alpha)
    )
  }

  getScales(chartType) {
    if (chartType === 'pie') {
      return {}
    }

    return {
      y: {
        beginAtZero: true
      }
    }
  }
}

// Initialize when DOM is loaded
document.addEventListener('DOMContentLoaded', () => {
  window.dashboardManager = new DashboardManager()
})

// Export for global access
window.updateChart = function(widgetId, chartType) {
  if (window.dashboardManager) {
    window.dashboardManager.updateChart(widgetId, chartType)
  }
}