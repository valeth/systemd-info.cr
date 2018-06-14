require "socket"
require "./systemd_service"

class UnixSocketServer
  property server : UNIXServer

  def initialize
    @server = UNIXServer.new("/tmp/sysmon.sock")
    at_exit { @server.close }
  end

  def wait
    while client = @server.accept?
      spawn handle_request(client)
    end
  end

  private def handle_request(client : UNIXSocket)
    puts "awaiting messages"
    loop do
      message = client.gets
      client.puts SystemdService.new(message).to_json unless message.nil?
    end
  rescue Errno
    puts "connection closed"
  end
end
