class TransferBuiltPresentationJob < ActiveJob::Base
  queue_as :default

  def perform(build_job)
    unless build_job.callback_url
      build_job.cleanup!(:clean, build_job)
      return
    end

    Rails.logger.debug "Transferring presentation to \"#{build_job.callback_url}\"."

    transferrer = MiddlemanPresentationBuilder::Uploader.new
    transferrer.upload build_job.callback_url, build_job.to_json

    build_job.progress[:transferring] = true

    build_job.cleanup! build_job
  rescue => err
    Rails.logger.fatal "Error occured while transferring presentation: #{err.message}\n#{err.backtrace.join("\n")}"
    build_job.progress[:transferring] = false
    build_job.stop_time = Time.now
    build_job.error_occured!
  end
end
