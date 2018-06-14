require "socket"
require "./logger"
require "./systemd_service"

class UnixSocketServer
  property server : UNIXServer

  def initialize
    LOG.info("Setting up socket...")
    @server = UNIXServer.new("/tmp/sysmon.sock")
    LOG.info("Socket ready.")
    at_exit do
      LOG.info("Shutting down...")
      @server.close
      LOG.info("bye")
    end
  end

  def wait
    while client = @server.accept?
      LOG.info("Client connected")
      spawn handle_request(client)
    end
  end

  private def handle_request(client : UNIXSocket)
    loop do
      LOG.debug("Awaiting message...")
      message = client.gets
      return if message.nil? || message.empty?
      LOG.debug("Got request for #{message}")
      LOG.debug("Fetching info...")
      client.puts SystemdService.new(message).to_json unless message.nil?
      LOG.debug("Done.")
    end
  rescue Errno
  ensure
    client.close
    LOG.error("Connection closed!")
  end
end
