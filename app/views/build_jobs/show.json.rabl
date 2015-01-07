object @build_job
attributes :id, :start_time, :stop_time, :build_status, :duration

node(:start_file) do |job| 
  if job.source_file_content.blank?
    ""
  else
    Base64.encode64(job.source_file_content)
  end
end

node(:build_file) do |job| 
  if job.build_file_content.blank?
    ""
  else
    Base64.encode64(job.build_file_content)
  end
end
