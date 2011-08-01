#! /usr/local/bin/ruby

require 'highline/import'

$aliasPool = []
$imgPool = []

def getParent(file, selector, domain)
	doc = Nokogiri::HTML.parse(File.read(file))
	parent = ''
	doc.css('ul.sectionhead li a').each do |a|
		parent += procUrl(a['href'].strip, domain)
	end
	return parent
end

def buildLinkPool(file, tmpDir, selector, domain)
	linkPool = []
	doc = Nokogiri::HTML.parse(File.read(file))
	doc.css(selector).each do |a|
		href = procUrl(a['href'].strip, domain)
		title = escape_apos(a.content.strip)
		filePath = tmpDir + fixUrl(href, domain, tmpDir)
		# if !File.file?(filePath) then filePath = '/dev/null' end
		linkPool.push Link.new(title, href, filePath, [])
	end
	return linkPool.uniq
end

# Build "New" UrlAlias with input from user
def newUrlAlias(linkText, linkPath, hasParent)
	tab = ''
	if hasParent then tab = "\t" end
	puts tab + "Title:    " + linkText
	puts tab + "URL:      " + linkPath
	if linkPath != '/' && (linkPath.length < 6 || (linkPath[0, 6] != 'http:/' && linkPath[0, 6] != 'https:')) then
		newLink = String.new(linkPath).split('/')
		if !newLink.nil? && !newLink.last.nil? then newLink = newLink.last.gsub(/\.s?html/, '') else newLink = '' end
		url = nil
		while !$aliasPool.index(url).nil? || url.nil?
			if !url.nil?
				puts "\n" + tab + "ERROR: That URL alias is already in use. Please provide another"
			end
			url = ask(tab + '> ') { |q| q.default = newLink != '' ? 'page/' + newLink : '' }
		end
		if url != '!!' then $aliasPool.push(url) end
	else
		url = linkPath
	end
	puts "\n"
	UrlAlias.new(getLastUrlAliasId(), 0, url.strip)
end

def popFields(filePath, content, rightImage)
	scraped = scrape(filePath)
	content = scraped['content']
	rightImage = scraped['rightImage']
	if !rightImage.nil?
		imgHash = {'filePath' => rightImage['filePath'], 'fileName' => rightImage['filePath'].split('/').last}
		$imgPool.push imgHash
	end
	return scraped
end

# Transform the pool of links into our SQL-generating `Page' objects
def transformLinkPool(linkPool, hasParent, parentPath)
	return (linkPool.map do |link|
		# Prompt for "New" UrlAlias
		newUrlAlias = newUrlAlias(link.linkText, link.relativePath, hasParent)
		# Process children first
		children = transformLinkPool(link.children, true, link.relativePath.sub(/\/?.*\.s?html?$/, '/'))
		# Process parent
		content = ''
		rightImage = nil
		base = link.filePath.split('/').take(3).join('/')
		while !link.relativePath.match(/^https?:\/\//) && !File.file?(link.filePath) && !File.file?(link.filePath = base + '/' + parentPath + link.relativePath)
			str = (hasParent ? "\t" : '')
			puts str + "Could not find the file. Please provide the correct path."
			link.filePath = ask(str + '> ') { |q| q.default = base + '/' + parentPath + link.relativePath }
		end
		if !link.relativePath.match(/^https?:\/\//)
			scraped = popFields(link.filePath, content, rightImage)
			content = scraped['content']
			rightImage = scraped['rightImage']
		end
		page = Page.new(link.linkText, content, link.relativePath, children, rightImage)
		newUrlAlias.node = page.id
		page.newUrlAlias = newUrlAlias
		if newUrlAlias.linkPath == '!!' then nil else page end
	end).reject { |n| n.nil? }
end

def weightParentPages(pages)
	pages.inject(0) { |i, page| page.menuLink.weight = -50 + i; i += 1 }
	return pages
end

def correctPseudoPages(pages)
	pages.each do |page|
		page.isPseudo = page.initPath[0, 6] == 'http:/' || page.initPath[0, 6] == 'https:'
	end
end

def to_sql(linkPool)
	correctPseudoPages(weightParentPages(transformLinkPool(linkPool, false, ''))).inject(
		File.read('etc/base.sql')
	) { |sql, page| sql += page.to_s }
end

