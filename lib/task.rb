class Task < ActiveRecord::Base

  belongs_to :user

  validates_presence_of :user_id, :task, :due_date

end