# PatternHash externds Hash, perhaps dangerously. Traditionally, hash1[key1] is meant to
# return the value associated with a key such that key == key1. PatternHash is extended
# so that pattern_hash1[key1] will return the value associated with a key such that
# key == key1 or key1 =~ key. In the second case, an association (2-element array) is
# returned, the key, and the value.
class PatternHash < Hash

  def initialize(hash = {})
    super()
    hash.each do |k, v|
      self[k] = v
    end
  end
  
  def [](el)
    return super(el) unless el.class == String
    r_keys   =   keys.select {|pattern| pattern.class == Regexp}
    patterns = r_keys.select {|pattern| el =~ pattern}
    return super(el) unless patterns.size == 1
    pattern = patterns[0]
    match = el.scan(pattern)[0]  # Just first match
    case
    when self[pattern].class == Proc   then return self[pattern].call(match)
    when self[pattern].class == String then return self[pattern] % match
    else                                    return [pattern, self[pattern]]
    end
  end
end