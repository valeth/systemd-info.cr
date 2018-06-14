require "./systemd_info/*"

Signal::INT.trap { exit(0) }
Signal::TERM.trap { exit(0) }
UnixSocketServer.new.wait
