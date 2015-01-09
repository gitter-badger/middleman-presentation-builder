class DeleteProgressTable < ActiveRecord::Migration
  def change
    drop_table :build_progresses
  end
end
