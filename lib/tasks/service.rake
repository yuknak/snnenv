require_relative '../dockerconf/util'

namespace :service do
  #ENV['APP_DOMAIN'] = @config['domain']

  @switch = Proc.new do |args, start, stop|
    case args.command
    when 'start'
      if (!Dockerconf::Util::check_hostname_and_status) then
        Dockerconf::Util::show_command_status
        next
      end  
      start.call
    when 'stop'
      stop.call
    when 'restart'
      stop.call
      start.call
    else
      puts "unknown command #{args.command}"
    end
  end

  desc 'Run Traefik (reverse-proxy)'
  task :proxy, [:command] do |task, args|
    args.with_defaults(:command => 'start')

    def start
      puts '----- Starting the proxy -----'
      File.new('config/acme.json', File::CREAT, 0600) unless File.exist? 'config/acme.json'
      sh 'docker-compose up -d proxy'
    end

    def stop
      puts '----- Stopping the proxy -----'
      sh 'docker-compose rm -fs proxy'
    end

    @switch.call(args, method(:start), method(:stop))
  end

  desc 'Run backend (db)'
  task :backend, [:command] do |task, args|
    args.with_defaults(:command => 'start')

    def start
      puts '----- Starting backend -----'
      if (ENV.key?('WSLENV')) then
        sh "sudo mkdir -p /mnt/C/docker_volumes/db_data"
      else
        sh "mkdir -p #{@config['database']['docker_volumes_path']}/db_data"
        #sh "sudo chmod a+w #{@config['database']['docker_volumes_path']}/db_data"
    end
      sh 'docker-compose up -d db'
    end

    def stop
      puts '----- Stopping backend -----'
      sh 'docker-compose rm -fs db'
    end


    @switch.call(args, method(:start), method(:stop))
  end

  desc 'Run snn'
  task :snn, [:command] do |task, args|
    args.with_defaults(:command => 'start')

    def start
      puts '----- Starting snn -----'
      sh 'docker-compose up -d snn'
    end

    def stop
      puts '----- Stopping snn -----'
      sh 'docker-compose rm -fs snn'
    end

    @switch.call(args, method(:start), method(:stop))
  end

  desc 'Run vnn'
  task :vnn, [:command] do |task, args|
    args.with_defaults(:command => 'start')

    def start
      puts '----- Starting vnn -----'
      sh 'docker-compose up -d vnn'
    end

    def stop
      puts '----- Stopping vnn -----'
      sh 'docker-compose rm -fs vnn'
    end

    @switch.call(args, method(:start), method(:stop))
  end

  desc 'Run tetra2'
  task :tetra2, [:command] do |task, args|
    args.with_defaults(:command => 'start')

    def start
      puts '----- Starting tetra2 -----'
      sh 'docker-compose up -d tetra2'
    end

    def stop
      puts '----- Stopping tetra2 -----'
      sh 'docker-compose rm -fs tetra2'
    end

    @switch.call(args, method(:start), method(:stop))
  end

  desc 'Run tetra'
  task :tetra, [:command] do |task, args|
    args.with_defaults(:command => 'start')

    def start
      puts '----- Starting tetra -----'
      sh 'docker-compose up -d tetra'
    end

    def stop
      puts '----- Stopping tetra -----'
      sh 'docker-compose rm -fs tetra'
    end

    @switch.call(args, method(:start), method(:stop))
  end

  desc '[Optional] Run phpmyadmin'
  task :pma, [:command] do |task, args|
    args.with_defaults(:command => 'start')

    def start
      puts '----- Starting the phpmyadmin -----'
      sh 'docker-compose up -d pma'
    end

    def stop
      puts '----- Stopping the phpmyadmin -----'
      sh 'docker-compose rm -fs pma'
    end

    @switch.call(args, method(:start), method(:stop))
  end

  desc '[Optional] Run drone'
  task :drone, [:command] do |task, args|
    args.with_defaults(:command => 'start')

    def start
      puts '----- Starting the drone -----'
      sh "mkdir -p #{@config['drone']['docker_volumes_path']}/drone_data"
      #sh "sudo chmod a+w #{@config['drone']['docker_volumes_path']}/drone_data"
      sh 'docker-compose up -d drone-server drone-agent'
    end

    def stop
      puts '----- Stopping the drone -----'
      sh 'docker-compose rm -fs drone-server drone-agent'
    end

    @switch.call(args, method(:start), method(:stop))
  end

  desc 'Run the micro app with dependencies (does not run Optional)'
  task :all, [:command] => 'render:config' do |task, args|
    args.with_defaults(:command => 'start')

    def start
      Rake::Task["service:backend"].invoke('start')
      sleep(5)
      Rake::Task["service:proxy"].invoke('start')
      #Rake::Task["service:pma"].invoke('start')
      Rake::Task["service:snn"].invoke('start')
      Rake::Task["service:vnn"].invoke('start')
      Rake::Task["service:tetra"].invoke('start')
    end

    def stop
      Rake::Task["service:tetra"].invoke('stop')
      Rake::Task["service:vnn"].invoke('stop')
      Rake::Task["service:snn"].invoke('stop')
      #Rake::Task["service:pma"].invoke('stop')
      Rake::Task["service:proxy"].invoke('stop')
      Rake::Task["service:backend"].invoke('stop')
    end

    @switch.call(args, method(:start), method(:stop))
  end
end
