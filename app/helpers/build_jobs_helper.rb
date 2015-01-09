module BuildJobsHelper
  def progress_bar
    template_string = <<-EOS.strip_heredoc
    <ul class="fe-progress">
      <% build_job.progress.each do |key, value| -%>
      <li class="fe-progress-item">
        <i class="fe-icon fe-icon-start fe-icon-color-grey fe-icon-build_job-<%= key %>"></i>
        <% if value == true -%>
        <i class="fe-icon fe-icon-start fe-icon-color-grey fe-icon-build_job-passed"></i>
        <% elsif value == false -%>
        <i class="fe-icon fe-icon-start fe-icon-color-grey fe-icon-build_job-failure"></i>
        <% else -%>
        <i class="fe-icon fe-icon-start fe-icon-color-grey fe-icon-build_job-not-run"></i>
        <% end -%>
      </li>
      <% end -%>
    </ul>
    EOS

    Tilt::ErubisTemplate.new { template_string }.render(build_job: @build_job)
  end
end
