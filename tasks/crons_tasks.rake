namespace :crons do
  desc "Install the crons we need to run this site"
  task :install do
    text = ''

    if File.exist?("#{RAILS_ROOT}/script/crons/other.txt")
      File.open("#{RAILS_ROOT}/script/crons/other.txt").each do |f|
        text << f
      end
    end

    rb_template = "@%s (cd #{RAILS_ROOT} ; /usr/local/bin/ruby script/runner -e production script/crons/%s/%s)\n"
    sh_template = "@%s (/bin/sh %s)\n"

    # Process the ruby files
    Dir["#{RAILS_ROOT}/script/crons/*/*.rb"].each do |file|
      if file =~ /crons\/daily/
        text << rb_template % ['daily', 'daily', File.basename(file)]
      elsif file =~ /crons\/hourly/
        text << rb_template % ['hourly', 'hourly', File.basename(file)]
      elsif file =~ /crons\/monthly/
        text << rb_template % ['monthly', 'monthly', File.basename(file)]
      elsif file =~ /crons\/weekly/
        text << rb_template % ['weekly', 'weekly', File.basename(file)]
      elsif file =~ /crons\/other/
        # Ignore the scripts in here
      else
        puts "Unknown file #{file}"
      end
    end

    # Process the shell scripts
    Dir["#{RAILS_ROOT}/script/crons/*/*.sh"].each do |file|
      if file =~ /crons\/daily/
        text << sh_template % ['daily', file]
      elsif file =~ /crons\/hourly/
        text << sh_template % ['hourly', file]
      elsif file =~ /crons\/monthly/
        text << sh_template % ['monthly', file]
      elsif file =~ /crons\/weekly/
        text << sh_template % ['weekly', file]
      elsif file =~ /crons\/other/
        # Ignore the scripts in here
      else
        puts "Unknown file #{file}"
      end
    end

    cron_file = "#{RAILS_ROOT}/script/crons/crontab.txt"

    File.delete(cron_file) if File.exist?(cron_file)

    unless text == ''
      f = File.new(cron_file, "w")
      f.puts text
      f.close
    end
  end

  desc "Remove any previously installed crons"
  task :remove do
    cron_file = "#{RAILS_ROOT}/script/crons/crontab.txt"

    File.delete(cron_file) if File.exist?(cron_file)
  end
end
