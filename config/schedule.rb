# Learn more: http://github.com/javan/whenever

# every 5.minutes do
every 1.minutes do # I'm testing and I want it to be aggressive. Slower once ready.
  runner "DropDir.check"
end

every 2.weeks do
  runner "Admin.optimize_tables"
end
