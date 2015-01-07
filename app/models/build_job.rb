class BuildJob < ActiveRecord::Base
  include AASM

  belongs_to :build_status
  mount_uploader :source_file, SourceFileUploader
  mount_uploader :build_file, BuildFileUploader

  enum aasm_state: {
    created: 1,
    unzipping: 2,
    validating: 3,
    installing_requirements: 4,
    building: 5,
    zipping: 6,
    transferring: 7,
    cleaning_up: 8,
    failed: 9,
    completed: 10
  }

  aasm column: :aasm_state, enum: true do
    state :created, initial: true
    state :unzipping, after_enter: :unzip_source_file
    state :validating, after_enter: :validate_presentation
    state :installing_requirements, after_enter: :install_requirements
    state :building, after_enter: :build_presentation
    state :zipping, after_enter: :zip_presentation
    state :transferring, after_enter: :transfer_built_presentation
    state :cleaning_up, after_enter: :cleanup_build_job
    state :failed
    state :completed

    event :unzip do
      transitions from: :created, to: :unzipping
    end

    event :validate do
      transitions from: :unzipping, to: :validating
    end

    event :install do
      transitions from: :validating, to: :installing_requirements
    end

    event :build do
      transitions from: :installing_requirements, to: :building
    end

    event :zip do
      transitions from: :building, to: :zipping
    end

    event :transfer do
      transitions from: :zipping, to: :transferring
    end

    event :cleanup do
      transitions from: :transferring, to: :cleaning_up
    end

    event :finish do
      transitions from: :cleaning_up, to: :completed
    end

    event :error_occured do
      transitions to: :failed
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
