FactoryGirl.define do
  factory :build_job do
    output 'hello world'
    start_time Time.parse('2014-01-01 14:00:00')
    stop_time Time.parse('2014-01-01 14:00:30')
    source_file nil
    build_file nil
    add_static_servers true
    callback_url nil
    build_status :created
    working_directory Dir.mktmpdir
  end
end
