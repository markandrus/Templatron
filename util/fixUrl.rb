#! /usr/local/bin/ruby

def fixUrl(url, domain, tmpDir)
	url = url.strip
	url = url.sub(/^https?:\/\/#{domain}/, '')
	url += File.directory?(tmpDir + url) ? '/index.html' : ''
	if url.match(/^https?:\/\//).nil?
		url = url.gsub(/\/\//, '/').sub(/^\//, '')
	end
	return url.sub(/\/$/, '')
end

