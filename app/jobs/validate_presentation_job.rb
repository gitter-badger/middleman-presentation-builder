class ValidatePresentationJob < ActiveJob::Base
  queue_as :default

  def perform(build_job)
    test zip_file_exist?(build_job.source_file.file.file), 'Zip file does not exist'
    test is_zip_file?(build_job.source_file.file.file), 'No zip file'
    test has_gemfile?(build_job.working_directory), 'No gemfile found'
    test has_middleman_gem_in_gemfile?(build_job.working_directory), 'No middleman gem in Gemfile'
    test has_middleman_config_file?(build_job.working_directory), 'No middleman config file'

    build_job.progress[:validating] = true

    build_job.install! build_job
  rescue => err
    Rails.logger.fatal "Error occured while validating \"#{build_job.source_file.file.file}\": #{err.message}\n\n#{err.backtrace.join("\n")}"
    build_job.progress[:validating] = false
    build_job.stop_time = Time.now
    build_job.error_occured!
  end

  private

  def test(check, message)
    fail message unless check
  end

  def zip_file_exist?(file)
    File.file? file
  end

  def is_zip_file?(file)
    /Zip archive/ === FileMagic.new.file(file)
  end

  def has_middleman_gem_in_gemfile?(directory)
    return false unless has_gemfile?(directory)

    gem_file = Dir.glob(File.join(directory, '**', 'Gemfile')).first

    !File.read(gem_file)[/gem ["']middleman-presentation["']/].blank?
  end

  def has_middleman_config_file?(directory)
    !Dir.glob(File.join(directory, '**', '.middleman-presentation.yaml')).first.blank?
  end

  def has_gemfile?(directory)
    !Dir.glob(File.join(directory, '**', 'Gemfile')).first.blank?
  end
end
