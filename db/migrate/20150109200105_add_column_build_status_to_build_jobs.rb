class AddColumnBuildStatusToBuildJobs < ActiveRecord::Migration
  def change
    add_column :build_jobs, :build_status, :string
  end
end
