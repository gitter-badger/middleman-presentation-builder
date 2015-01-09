class ZipPresentationJob < ActiveJob::Base
  queue_as :default

  def perform(build_job)
    config_file = Dir.glob(File.join(build_job.working_directory, '**', '.middleman-presentation.yaml')).first
    build_directory = File.join(File.dirname(config_file), 'build')

    config = MiddlemanPresentationBuilder::PresentationConfig.new(config_file)
    prefix = format('%s-%s', config.date, config.title.characterize)

    zip_file = File.join(Dir.tmpdir, sprintf('presentation-%s.build.zip', SecureRandom.hex))

    Rails.logger.debug "Zipping built presentation at \"#{build_directory}\" to \"#{zip_file}\"."
    MiddlemanPresentationBuilder::Utils.zip(build_directory, zip_file, prefix: prefix)

    build_job.build_file = File.open(zip_file)

    build_job.progress[:zipping] = true

    build_job.transfer! build_job
  rescue => err
    Rails.logger.fatal "Error occured while creating ZIP-file \"#{zip_file}\": #{err.message}\n#{err.backtrace.join("\n")}"
    build_job.progress[:zipping] = false
    build_job.error_occured!
  end
end
