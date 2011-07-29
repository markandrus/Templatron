#! /usr/local/bin/ruby

def sftp(user, siteUrl, ftpServ)
	puts "\nThis script will now execute the following SFTP commands on `#{ftpServ}'...\n\n"

	sftpCmd = "\tsftp #{user}@#{ftpServ}: << EOF
	cd /hosted/vhosts/sites/sites/#{siteUrl}/files
	put etc/favicon.ico
	mkdir template
	cd template
	put etc/background.css
	put #{'out/' + siteUrl + '/masthead.png'}
	bye
	EOF"

	puts sftpCmd + "\n\n"
	puts "\n"
	`#{sftpCmd}`
end

