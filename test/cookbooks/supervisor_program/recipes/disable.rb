supervisor_program 'program-disabled' do
  command 'cat'
  action [:enable, :disable]
end
