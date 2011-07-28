#! /usr/local/bin/ruby

def procUrl(raw, domain)
	raw = String.new(raw)
	raw.sub!(/^https?:\/\/#{Regexp.escape(domain)}\//, '')
	raw.sub!(/^\//, '')
	raw.sub!(/index\.s?html$/, '')
	if raw == ''
		raw = '/'
	end
	return raw
end

