
class RandomStrings
  def self.generate_alphanumeric(len)
    len.times.map { [*'0'..'9', *'a'..'z'].sample }.join
    end

  def self.generate_alpha(len)
    len.times.map { [*'a'..'z'].sample }.join
  end
end