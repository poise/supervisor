supervisor_program 'program-stopped' do
  autostart true
  command 'cat'
  action [:enable, :stop]
end
