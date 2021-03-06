#! /usr/local/bin/ruby

# Print usage
def usage()
	puts "DC 1.0, a University of Chicago Web Express to TemplaTron site converter."
	puts "Usage: #{$0} [WE_URL]"
	puts "Example: #{$0} crimelab.uchicago.edu\n\n"
	puts "Mail bug reports and suggestions to <andrus@uchicago.edu>."
end

# `wget' an entires site
def wgetSite(url, dir)
	puts "Downloading `" + url + "'..."
	wgetCmd = "wget --quiet --recursive --no-clobber --page-requisites --domains #{url} #{url} -P #{dir} -l 2"
	puts "\t" + wgetCmd + "\n\n"
	`#{wgetCmd}`
	puts "Creating output directory..."
	rmCmd = "rm -rf #{'out/' + url + '/'}"
	puts "\t" + rmCmd
	`#{rmCmd}`
	mkdirCmd = "mkdir #{'out/' + url + '/'}"
	puts "\t" + mkdirCmd + "\n\n"
	`#{mkdirCmd}`
end

# `sftp' into `webspace.uchicago.edu' and upload the necessary files
def sftp(user, siteUrl, ftpServ)
	puts "\nThis script will now execute the following SFTP commands on `#{ftpServ}'...\n\n"
	sftpCmd = ("\tsftp #{user}@#{ftpServ}: << EOF
	cd /hosted/vhosts/sites/sites/#{siteUrl}/files
	put etc/favicon.ico
	mkdir template
	cd template
	put etc/background.css
	put #{'out/' + siteUrl + '/masthead.png'}
	cd ../styles
	mkdir columnwidth
	cd columnwidth
	mkdir public
	cd public
	put out/#{siteUrl}/img/resize/*
	cd ../../
	mkdir galleryimage
	cd galleryimage
	mkdir public
	cd public
	put out/#{siteUrl}/img/*
	bye
	EOF")
	puts sftpCmd + "\n\n"
	puts "\n"
	`#{sftpCmd}`
end

# URL Processing Routines
def fixUrl(url, domain, tmpDir)
	url = url.strip
	url = url.sub(/^https?:\/\/#{Regexp.escape(domain)}/, '')
	url += File.directory?(tmpDir + url) ? '/index.html' : ''
	if url.match(/^https?:\/\//).nil?
		url = url.gsub(/\/\//, '/').sub(/^\//, '')
	end
	return url.sub(/\/$/, '')
end

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

def buildSql(tableName, values)
	sql = "INSERT INTO `#{tableName}` "
	if values.class == Hash
		sql += '(' + values.keys.join(", ") + ') VALUES '
		values = values.values
	else
		sql += 'VALUES '
	end
	sql += '(' + (values.map { |value| "'" + value.to_s + "'" }).join(", ") + ');'
	return sql
end

