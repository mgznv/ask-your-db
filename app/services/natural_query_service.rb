require 'net/http'
require 'json'

class NaturalQueryService
  include ActiveModel::Model
  
  attr_accessor :natural_query
  
  def initialize(natural_query)
    @natural_query = natural_query
  end
  
  def process
    return error_result("API key de Anthropic no configurada") unless ENV['ANTHROPIC_API_KEY']
    return error_result("Consulta requerida") if natural_query.blank?
    
    begin
      schema_info = get_database_schema
      sql_query = generate_sql_from_natural_language(schema_info)
      chart_type = suggest_chart_type
      
      {
        success: true,
        sql: sql_query,
        explanation: generate_explanation,
        suggested_chart_type: chart_type,
        error: nil
      }
    rescue => e
      Rails.logger.error "Error en NaturalQueryService: #{e.message}"
      if e.message.include?("credit balance is too low")
        error_result("La cuenta de Anthropic no tiene créditos suficientes. Por favor agrega créditos en https://console.anthropic.com/")
      elsif e.message.include?("API Error")
        error_result("Error en la API de Anthropic: #{e.message}")
      else
        error_result("Servicio de conversión NL→SQL no disponible: #{e.message}")
      end
    end
  end
  
  private
  
  def get_database_schema
    schema = {}
    
    ActiveRecord::Base.connection.tables.each do |table_name|
      next if table_name.in?(['schema_migrations', 'ar_internal_metadata'])
      
      columns = ActiveRecord::Base.connection.columns(table_name)
      schema[table_name] = columns.map do |column|
        {
          name: column.name,
          type: column.type.to_s,
          null: column.null
        }
      end
    end
    
    schema
  end
  
  def generate_sql_from_natural_language(schema_info)
    return call_anthropic_api(schema_info)
  end
  
  def call_anthropic_api(schema_info)
    prompt = build_prompt(schema_info)
    
    uri = URI('https://api.anthropic.com/v1/messages')
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    
    request = Net::HTTP::Post.new(uri)
    request['Content-Type'] = 'application/json'
    request['x-api-key'] = ENV['ANTHROPIC_API_KEY']
    request['anthropic-version'] = '2023-06-01'
    
    request.body = {
      model: "claude-3-haiku-20240307",
      max_tokens: 1000,
      messages: [
        {
          role: "user",
          content: prompt
        }
      ]
    }.to_json
    
    response = http.request(request)
    
    if response.code == '200'
      data = JSON.parse(response.body)
      extract_sql_from_response(data.dig('content', 0, 'text') || '')
    else
      raise "API Error: #{response.code} - #{response.body}"
    end
  end
  
  
  def build_prompt(schema_info)
    schema_text = schema_info.map do |table, columns|
      column_text = columns.map { |col| "- #{col[:name]} (#{col[:type]})" }.join("\n")
      "Tabla: #{table}\n#{column_text}"
    end.join("\n\n")
    
    <<~PROMPT
      Eres un experto en SQL y PostgreSQL. Dado el siguiente esquema de base de datos y una consulta en lenguaje natural, genera una consulta SQL válida.
      
      ESQUEMA DE BASE DE DATOS:
      #{schema_text}
      
      CONSULTA EN LENGUAJE NATURAL:
      #{natural_query}
      
      INSTRUCCIONES:
      1. Genera SOLO la consulta SQL, sin explicaciones adicionales
      2. Usa PostgreSQL como dialecto
      3. Asegúrate de que la consulta sea válida y eficiente
      4. No incluyas comentarios en el SQL
      5. Retorna solo el SQL entre las etiquetas <sql> y </sql>
      
      Ejemplo de formato de respuesta:
      <sql>
      SELECT column1, column2 FROM table_name WHERE condition;
      </sql>
    PROMPT
  end
  
  def extract_sql_from_response(response)
    return "" if response.blank?
    
    sql_match = response.match(/<sql>(.*?)<\/sql>/m)
    return sql_match[1].strip if sql_match
    
    response.strip
  end
  
  def generate_explanation
    case natural_query.downcase
    when /ventas.*mes/, /sales.*month/
      "Esta consulta agrupa los datos de ventas por mes para mostrar tendencias temporales."
    when /productos.*vendidos/, /products.*sold/
      "Esta consulta muestra los productos más vendidos en orden descendente."
    when /clientes.*activos/, /active.*customers/
      "Esta consulta identifica los clientes activos basado en actividad reciente."
    else
      "Esta consulta procesa los datos según los criterios especificados en lenguaje natural."
    end
  end
  
  def suggest_chart_type
    case natural_query.downcase
    when /por.*mes/, /por.*año/, /tendencia/, /tiempo/
      'line'
    when /comparar/, /vs/, /versus/
      'bar'
    when /porcentaje/, /distribución/, /proporción/
      'pie'
    when /área/, /acumulado/
      'area'
    else
      'table'
    end
  end
  
  def error_result(message)
    {
      success: false,
      sql: nil,
      explanation: nil,
      suggested_chart_type: 'table',
      error: message
    }
  end
end