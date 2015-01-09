require 'timeout'

class InstallRequirementsJob < ActiveJob::Base
  queue_as :default

  def perform(build_job)
    directory_with_config = File.dirname(Dir.glob(File.join(build_job.working_directory, '**', '.middleman-presentation.yaml')).first)

    Rails.logger.debug "Using directory \"#{directory_with_config}\" for job execution"
    fail "Directory \"#{directory_with_config}\" does not exist" unless File.directory? directory_with_config

    cmd = nil
    Timeout::timeout(Rails.configuration.x.build_timeout) do
      cmd = MiddlemanPresentationBuilder::Command.new('bundle install', working_directory: directory_with_config)
      cmd.execute
    end

    build_job.output << format("$ %s\n", cmd.to_s)
    build_job.output << cmd.output
    build_job.output << ''

    fail "Command \"#{command.to_s}\" failed. See output for more details" unless cmd.success?

    build_job.progress[:installing_requirements] = true
    build_job.build! build_job
  rescue => err
    Rails.logger.fatal "Build Job failed with #{err.message}\n\n#{err.backtrace.join("\n")}"
    build_job.progress[:installing_requirements] = false
    build_job.stop_time = Time.now
    build_job.error_occured!
  end
end
