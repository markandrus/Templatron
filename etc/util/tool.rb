#! /usr/local/bin/ruby

def unicode_to_html(str)
    str.unpack("U*").collect {|s| (s > 127 ? "&##{s};" : s.chr) }.join("")
end

print unicode_to_html(File.read(ARGV[0]))
