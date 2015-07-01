module Whitelist
  WHITELIST_FILE = 'whitelist'

  def self.exists?(email)
    emails = []
    File.open(WHITELIST_FILE) do |f|
      while e = f.gets
        emails << e.strip
      end
    end
    emails.include? email
  end
end
