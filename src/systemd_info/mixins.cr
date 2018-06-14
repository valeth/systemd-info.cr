module MatchWith
  private def match_with(pattern : Regex, data)
    m = pattern.match(data )
    yield m if m
  end
end
