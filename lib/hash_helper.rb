require 'digest'

module HashHelper
  def formatted_hash(plain_text, prefix="", suffix="")
    hash = gen_hash(plain_text.downcase.strip, prefix, suffix)
    hash[0, 4] + "-" + hash[4, 4] + "-" + hash[8, 4] + "-" + hash[12, 4] + "-" + 
            hash[16, 4] + "-" + hash[20, 4] + "-" + hash[24, 4] + "-" + hash[28, 4]
  end

  def match?(plain_text, code="", prefix="", suffix="")
    hash = code.strip.gsub("-", "")
    hash == gen_hash(plain_text.downcase, prefix, suffix)
  end

  def gen_hash(plain_text, prefix, suffix)
    Digest::MD5.hexdigest(prefix + plain_text + suffix)
  end
end