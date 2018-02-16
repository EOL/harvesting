# set path to the application
app_dir = "/u/apps/harvester"
shared_dir = "#{app_dir}/shared"
working_directory app_dir

pid "#{app_dir}/tmp/unicorn.pid"

stderr_path "#{app_dir}/log/unicorn.stderr.log"
stdout_path "#{app_dir}/log/unicorn.stdout.log"

worker_processes 4
listen "#{app_dir}/tmp/unicorn.sock", :backlog => 64
# Yes, this is ridiculous, but people mostly use the API on this codebase, and can use the time:
timeout 600
preload_app true
