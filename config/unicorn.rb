rails_root = `pwd`.chomp

worker_processes 3
timeout 15
preload_app true

# TCPソケットで使う場合
#listen 3000
# Unixドメインソケットを使う場合（WEBサーバーと連携する場合）
listen "/tmp/unicorn.sock", :backlog => 64

pid "#{ rails_root }/tmp/pids/unicorn.pid"

# ログの設定方法.
stderr_path "#{ rails_root }/log/unicorn.log"
stdout_path "#{ rails_root }/log/unicorn.log"

before_fork do |server, worker|
  ActiveRecord::Base.connection.disconnect!
  old_pid = "#{ server.config[:pid] }.oldbin"
  if File.exists?(old_pid) && server.pid != old_pid
    begin
        Process.kill("QUIT", File.read(old_pid).to_i)
    rescue Errno::ENOENT, Errno::ESRCH
        # someone else did our job for us
    end
  end
end

after_fork do |server, worker|
    ActiveRecord::Base.establish_connection

    Signal.trap 'TERM' do
        puts 'Unicorn worker intercepting TERM and doing nothing. Wait for master to send QUIT'
    end
end