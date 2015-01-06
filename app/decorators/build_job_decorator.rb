require 'fedux_org_stdlib/icon'

class BuildJobDecorator < Draper::Decorator
  delegate_all

  def icon
    FeduxOrgStdlib::Icon.new(id.to_s).to_data_uri
  end

  def source_file_size
    return if source_file.blank?

    format '(%s)', h.number_to_human_size(source_file.file.size, precision: 2)
  end

  def build_file_size
    return if build_file.blank?

    format '(%s)', h.number_to_human_size(build_file.file.size, precision: 2)
  end

  def title
    format('%s #%d', BuildJob.model_name.human, id)
  end

  def short_title
    format('#%d', id)
  end

  def duration
    return 0 if stop_time.blank? || start_time.blank?

    Time.at(stop_time - start_time).utc.strftime("%H:%M:%S")
  end

  # Define presentation-specific methods here. Helpers are accessed through
  # `helpers` (aka `h`). You can override attributes, for example:
  #
  #   def created_at
  #     helpers.content_tag :span, class: 'time' do
  #       object.created_at.strftime("%a %m/%d/%y")
  #     end
  #   end

end
