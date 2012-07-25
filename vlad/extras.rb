# -*- coding: utf-8 -*-
#
namespace :vlad do
  def skip_scm; false; end

  desc "Put revision into public/revision"
  remote_task :put_revision_large do
    # puts "vlad-git revision: #{source.revision(revision)}"
    airbrake_revision = revision.gsub(/origin.HEAD./,'')
    puts "Put revision.."
    run "cd #{scm_path}/repo;
    export RAILS_ENV=#{rails_env} REVISION=#{airbrake_revision} REPO=#{repository} TO=#{rails_env} USER=`whoami`;
    (nohup ./script/vlad/set_revision #{current_release} 2>&1 >> /tmp/set_revision.log &)"

    has_newrelic = `grep newrelic ./Gemfile`.length>0
    has_newrelic and run "cd #{current_path}; RAILS_ENV=#{rails_env} bundle exec newrelic deployments -r #{airbrake_revision}"
    # ./script/set_revision #{current_release}"
  end

  # before :"deploy:symlink", :"deploy:assets";
  # rake assets:clean:all RAILS_ENV=production RAILS_GROUPS=assets
  # rm -rf /home/wwwdata/blogs.investcafe.ru/releases/20111127125954/public/assets
  # rake assets:precompile:all RAILS_ENV=production RAILS_GROUPS=assets
  # rake assets:precompile:nondigest RAILS_ENV=production RAILS_GROUPS=assets
  desc 'Precompile assets'
  remote_task :precompile do
    puts "Precompile.."
    symlink_assets = "rm -f #{shared_path}/public; ln -s #{current_release}/public/ #{shared_path}/"
    cmd = "cd #{current_path}; RAILS_ENV=#{rails_env} bundle exec rake assets:clean assets:precompile:primary assets:precompile:nondigest RAILS_ENV=#{rails_env} RAILS_GROUPS=assets"
    run "#{cmd}; #{symlink_assets}"
  end

  remote_task :git_fetch do
    puts "Git fetch.."
    # Когда выполняется первый раз после setup-а, то каталога repo еще не существует
    run "test -d #{scm_path}/repo && (cd #{scm_path}/repo; git fetch) || echo 'no repo'"
  end

  desc 'Umonitor monit'
  remote_task :unmonitor do
    puts 'Unmonitor'
    sudo "monit unmonitor all 2>&1 >> /tmp/monit_restart.log"
  end

  desc 'Monitor monit'
  remote_task :monitor do
    puts 'Monitor'
    sudo "monit monitor all 2>&1 >> /tmp/monit_restart.log"
  end

  desc 'Reindex solr'
  remote_task :solr_reindex do
    puts "Solr reindes"
    run "cd #{current_path}; RAILS_ENV=#{rails_env} nohup time bundle exec rake sunspot:reindex > /tmp/sunspot_reindex.log 2>&1 &"
  end


  namespace :unicorn do

    remote_task :upgrade do
      puts "Upgrade unicorn.."
      puts cmd="#{unicorn_rc} upgrade"
      sudo cmd
      puts "Unicorn upgraded"
    end

    remote_task :restart do 
      puts "Restart unicorn.."
      puts cmd="#{unicorn_rc} restart"
      sudo cmd
      puts "Unicorn restart"
    end
  end

  namespace :mybundle do
    set :bundle_without, "development test"

    desc "Execute bundle --deployment" #
    remote_task :install=>['vlad:rvm:trust:release', 'vlad:rvm:trust:current'] do
      # run bundle install with explicit path and without test dependencies
      # С release_path не работает текущая git версия
      run "cd #{current_path}; bundle install --deployment --without #{bundle_without}"
    end
  end

  desc "Put revision into public/revision"
  remote_task :put_revision do
    airbrake =  "cd #{current_release}; nohup bundle exec rake airbrake:deploy RAILS_ENV=#{rails_env} TO=#{rails_env} REVISION=#{revision} USER=`whoami` REPO=#{repository} >> ./tmp/airbrake_notify.log &"
    run "cd #{scm_path}/repo; git rev-parse HEAD > #{release_path}/public/revision.txt; #{airbrake}"
  end

  desc 'Precompile assets'
  remote_task :precompile do
    puts "Precompile.."
    run "cd #{current_path}; RAILS_ENV=#{rails_env} bundle exec rake assets:clean tmp:clear assets:precompile"
  end

  desc 'Restart foreverb'
  remote_task :foreverb do
    puts "Foreverb.."
    run "cd #{current_path}; RAILS_ENV=#{rails_env} nohup bundle exec ./script/foreverb-cron >> ./tmp/forever-restart.log"
  end

  desc 'Влад рассказывает что куда деплоит'
  task :describe do
    vers = `git describe #{current_commit}`.chomp
    puts "Деплоим (#{rails_env}): #{current_branch} / #{current_commit} (#{vers})"
    puts
  end

end
