class Dashboard < ApplicationRecord
  has_many :dashboard_widgets, dependent: :destroy
  
  validates :name, presence: true, uniqueness: true
  
  def widget_count
    dashboard_widgets.count
  end
end