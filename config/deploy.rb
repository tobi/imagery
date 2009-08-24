set :application, "imagery"
set :repository,  "git://github.com/tobi/image_server.git"
set :branch,      "origin/master"
set :user,        'deploy'                            
set :deploy_type, 'deploy'

role :app, instance = ENV['INSTANCE'] || "vm"
                                              
namespace :deploy do
  desc "Deploy it"
  task :default do
    update_code
    restart
    cleanup
  end
 
  desc "Setup a GitHub-style deployment."
  task :setup, :except => { :no_release => true } do
    run "git clone #{repository} #{current_path}"
  end
 
  desc "Update the deployed code."
  task :update_code, :except => { :no_release => true } do
    run "cd #{current_path}; git fetch origin; git reset --hard #{branch}; git tag '#{deploy_type}-#{Time.now.to_i}'"
  end

  desc "List deployment tags for use with deploy:rollback TAG="
  task :list_tags, :except => { :no_release => true } do
    run "cd #{current_path}; git tag -l 'deploy*' -n 3"
  end
 
  namespace :rollback do 
    desc "Rollback a single commit."
    task :default, :except => { :no_release => true } do
      branch = ENV['TAG'] || capture("cd #{current_path}; git tag -l 'deploy*' | tail -n2 | head -n1")
      set :deploy_type, 'rollback'
      set :branch, branch
      deploy.default
    end
  end
  
  desc "Signal Passenger to restart the application"
  task :restart, :roles => :app do
    run "mkdir -p #{current_path}/tmp && touch #{current_path}/tmp/restart.txt"
  end
end
