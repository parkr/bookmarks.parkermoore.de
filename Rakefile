task :preview do
  puts "Starting to watch source with Jekyll and Compass. Starting Rack on port 4000"
  jekyllPid = Process.spawn("jekyll serve -w")
  compassPid = Process.spawn("compass watch")

  trap("INT") {
    [jekyllPid, compassPid].each { |pid| Process.kill(9, pid) rescue Errno::ESRCH }
    exit 0
  }

  [jekyllPid, compassPid].each { |pid| Process.wait(pid) }  
end
