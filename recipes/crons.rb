after "deploy",         "deploy:crons:install"
before "deploy:revert", "deploy:crons:remove"

namespace :deploy do
  namespace :crons do
    desc "Installing the crons"
    task :install, :roles => :db do
      run "(cd #{deploy_to}/current ; rake crons:install)"
      run "cat #{deploy_to}/current/script/crons/crontab.txt | crontab -"
    end

    desc "Remove the crons"
    task :remove, :roles => :db do
      run "crontab -r"
      run "(cd #{deploy_to}/current ; rake crons:remove)"
    end
  end
end
