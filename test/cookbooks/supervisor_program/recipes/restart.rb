file '/tmp/program-restarted.log' do
  action :delete
end

program = supervisor_program 'program-restarted' do
  command 'sh -c "date +%%s; cat"'
  stdout_logfile '/tmp/program-restarted.log'
end

ruby_block 'restart' do
  block do
    sleep 5
    program.run_action(:restart)
  end
end
