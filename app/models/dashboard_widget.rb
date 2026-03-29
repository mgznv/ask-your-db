class DashboardWidget < ApplicationRecord
  belongs_to :dashboard
  
  validates :title, presence: true
  validates :natural_query, presence: true
  validates :status, inclusion: { in: %w[pending approved rejected] }
  
  scope :approved, -> { where(status: 'approved') }
  scope :pending, -> { where(status: 'pending') }
  scope :rejected, -> { where(status: 'rejected') }
  
  def pending?
    status == 'pending'
  end
  
  def approved?
    status == 'approved'
  end
  
  def rejected?
    status == 'rejected'
  end
  
  def approve!
    update!(status: 'approved')
  end
  
  def reject!
    update!(status: 'rejected')
  end
  
  def chart_types
    %w[line bar pie area table]
  end
  
  def can_execute?
    approved? && sql_query.present?
  end
end