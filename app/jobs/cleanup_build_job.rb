class CleanupBuildJob < ActiveJob::Base
  queue_as :default

  def perform(build_job)
    Rails.logger.debug "Deleting working directory \"#{build_job.working_directory}\" for build ##{build_job.id}."

    FileUtils.rm_rf build_job.working_directory
    build_job.save!

    build_job.progress[:cleaning_up] = true
    build_job.stop_time = Time.now
    build_job.finish! build_job
  rescue => err
    Rails.logger.fatal "Build Job failed with #{err.message}\n\n#{err.backtrace.join("\n")}"
    build_job.progress[:cleaning_up] = false
    build_job.stop_time = Time.now
    build_job.error_occured!
  end
end
