#! /usr/local/bin/ruby

def procUrl(raw, domain)
	raw.sub!(/^https?:\/\/#{Regexp.escape(domain)}\//, '')
	raw.sub!(/^\//, '')
	if raw == ''
		raw = '/'
	end
	return raw
end

