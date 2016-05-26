Before('@no-travis') do
  skip_this_scenario if ENV['CI']
end
