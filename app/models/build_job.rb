class BuildJob < ActiveRecord::Base
  include AASM

  belongs_to :build_status
  mount_uploader :source_file, SourceFileUploader
  mount_uploader :build_file, BuildFileUploader

  aasm column: 'build_status' do
    state :created, initial: true
    state :unzipped, after_enter: :unzip_source_file
    state :validated, after_enter: :validate_presentation
    state :requirements_installed, after_enter: :install_requirements
    state :built, after_enter: :build_presentation
    state :zipped, after_enter: :zip_presentation
    state :transferred, after_enter: :transfer_built_presentation
    state :clean, after_enter: :cleanup_build_job
    state :failure#, after_enter: :cleanup_build_job
    state :completed

    event :unzip do
      transitions from: :created, to: :unzipped
    end

    event :validate do
      transitions from: :unzipped, to: :validated
    end

    event :install do
      transitions from: :validated, to: :requirements_installed
    end

    event :build do
      transitions from: :requirements_installed, to: :built
    end

    event :zip do
      transitions from: :built, to: :zipped
    end

    event :transfer do
      transitions from: :zipped, to: :transferred
    end

    event :cleanup do
      transitions from: :transferred, to: :clean
    end

    event :finish do
      transitions from: :clean, to: :completed
    end

    event :error_occured do
      transitions to: :failure
    end

    event :restart do
      transitions to: :created
    end
  end

  def to_json
    template = 'build_jobs/show'
    object = self
    Rabl.render(object, template, :view_path => 'app/views', :format => :json)
  end

  private

  def unzip_source_file
    UnzipSourceFileJob.perform_later(self)
  end

  def validate_presentation
    ValidatePresentationJob.perform_later(self)
  end

  def build_presentation
    BuildPresentationJob.perform_later(self)
  end

  def zip_presentation
    ZipPresentationJob.perform_later(self)
  end

  def transfer_built_presentation
    TransferBuiltPresentationJob.perform_later(self)
  end

  def install_requirements
    InstallRequirementsJob.perform_later(self)
  end

  def cleanup_build_job
    CleanupBuildJob.perform_later(self)
  end
end
