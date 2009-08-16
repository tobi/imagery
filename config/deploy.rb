set :application, "imagery"
set :repository,  "git://github.com/tobi/image_server.git"
set :branch,      "origin/master"
set :user,        'deploy'                            

role :app, instance = "vm"
                                              
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
    run "cd #{current_path}; git fetch origin; git reset --hard #{branch}"
  end
 
  namespace :rollback do 
    desc "Rollback a single commit."
    task :default, :except => { :no_release => true } do
      set :branch, "HEAD^"
      default
    end
  end
  
  desc "Signal Passenger to restart the application"
  task :restart, :roles => :app do
    run "mkdir -p #{current_path}/tmp && touch #{current_path}/tmp/restart.txt"
  end
end