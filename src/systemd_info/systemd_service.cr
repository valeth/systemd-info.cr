require "json"
require "./mixins"

class SystemdService
  include MatchWith

  JSON.mapping(
    name: String,
    description: String,
    docs: String?,
    pid: { type: UInt32?, emit_null: true },
    executable: { type: String?, emit_null: true },
    tasks: UInt32,
    mem: String,
    cpu_time: String?,
    status: SystemdStatus
  )

  def initialize(@name : String)
    @description = ""
    @mem = "0B"
    @tasks = 0_u32
    @status = SystemdStatus.new
    parse
  end

  private def parse
    lines = status.lines
    return if lines.empty?

    first_line = lines.first.split(/[ \.]/)
    @description = first_line[4..-1].join(" ") if first_line.size >= 5

    lines.each do |line|
      key, _, value = line.partition(": ")
      case key.strip
      when "Docs"
        @docs = value
      when "Main PID"
        match_with(/(\d+) \((.*)\)/, value) do |m|
          @pid = m[1].to_u32(strict: false) if m[1]?
          @executable = m[2] if m[2]?
        end
      when "Tasks"
        @tasks = value.to_u32(strict: false)
      when "Memory"
        @mem = value
      when "CPU"
        @cpu_time = value
      else
        @status.update(key.strip, value)
      end
    end
  end

  private def status
    Process.run("systemctl status --full --no-pager #{@name}", shell: true) do |p|
      p.output.gets_to_end.split(/\n\n/).first
    end
  end
end
