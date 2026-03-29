class CreateDashboardWidgets < ActiveRecord::Migration[7.1]
  def change
    create_table :dashboard_widgets do |t|
      t.references :dashboard, null: false, foreign_key: true
      t.string :title, null: false
      t.text :natural_query, null: false
      t.text :sql_query
      t.string :chart_type
      t.jsonb :chart_config
      t.jsonb :position
      t.string :status, null: false, default: 'pending'

      t.timestamps
    end

    add_index :dashboard_widgets, :status
  end
end
