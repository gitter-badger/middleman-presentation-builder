class RenameColumnAasmStateToBuildStatus < ActiveRecord::Migration
  def change
    rename_column :build_jobs, :aasm_state, :build_status
  end
end
