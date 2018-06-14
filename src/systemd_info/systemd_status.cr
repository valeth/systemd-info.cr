require "json"
require "./mixins"

class SystemdStatus
  include MatchWith

  JSON.mapping(
    enabled: Bool,
    vendor_preset_enabled: Bool,
    load: String,
    active: String,
    sub: String,
    active_since: Time?,
    text: String?
  )

  def initialize
    @enabled = false
    @vendor_preset_enabled = false
    @load = "unknown"
    @active = "unknown"
    @sub = "unknown"
  end

  def update(key : String, value : String)
    case key
    when "Active"
      match_with(/^(.*) \((.*)\) since (.*);/, value) do |m|
        @active = m[1] if m[1]?
        @sub = m[2] if m[2]?
        @active_since = Time.parse(m[3], "%a %F %T") if m[3]?
      end
    when "Loaded"
      match_with(/^(.*) \(.*; (.*); vendor preset: (.*)\)$/, value) do |m|
        @load = m[1] if m[1]?
        @enabled = m[2] == "enabled" if m[2]?
        @vendor_preset_enabled = m[3] == "enabled" if m[3]?
      end
    when "Status"
      @text = value
    end
  end
end
