class AddColumnProgressToBuilJob < ActiveRecord::Migration
  def change
    add_column :build_jobs, :progress, :string
  end
end
