supervisor_program 'program-started' do
  autostart false
  command 'cat'
  action [:enable, :start]
end
