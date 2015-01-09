class AddColumnBuildToBuildProgress < ActiveRecord::Migration
  def change
    add_column :build_progresses, :build_job_id, :integer
  end
end
