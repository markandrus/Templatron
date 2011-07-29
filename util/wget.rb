#! /usr/local/bin/ruby

def wgetSite(url, dir)
	puts "Downloading `" + url + "'..."

	wgetCmd = "wget --quiet --recursive --no-clobber --domains #{url} #{url} -P #{dir} -l 2"
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

