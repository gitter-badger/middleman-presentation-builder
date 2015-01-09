class UnzipSourceFileJob < ActiveJob::Base
  queue_as :default

  def perform(build_job)
    build_job.start_time = Time.now

    fail 'No source file was uploaded' if build_job.source_file.blank? || build_job.source_file.file.blank?

    zip_file = build_job.source_file.file.file

    Rails.logger.debug "Unzipping presentation \"#{zip_file}\" to \"#{build_job.working_directory}\"."

    MiddlemanPresentationBuilder::Utils.unzip(zip_file, build_job.working_directory)

    build_job.progress[:unzipping] = true

    build_job.validate! build_job
  rescue => err
    Rails.logger.fatal "Error occured while unzipping \"#{zip_file}\": #{err.message}\n#{err.backtrace.join("\n")}"
    build_job.progress[:unzipping] = false
    build_job.error_occured!
  end
end
