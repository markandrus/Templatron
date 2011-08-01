#! /usr/local/bin/ruby

$lastFid = 60
def getLastFid()
	$lastFid += 1
	return $lastFid - 1
end

class FileManaged
	attr_accessor :fid, :filename, :uri, :filemime
	def initialize(fid, filename, uri)
		@fid = fid; @filename = filename; @uri = uri
		@filemime = 'image/' + @filename.match(/[a-z]*$/).to_s.sub(/jpg$/, 'jpeg')
	end

	# Returns SQL
	def to_s
		return ('INSERT INTO `file_managed` (fid, filename, uri, filemime, status) VALUES (' + ([
				@fid.to_s,
				@filename.gsub(/^\//, ''),
				@uri,
				@filemime,
				'1'
			]).map {|x| "'" + x + "'"}.join(', ') + ');'
		);
	end
end

class FieldDataRightImage
    attr_accessor :id, :bundle, :fid, :alt, :title, :filePath, :fileManaged
    def initialize(id, bundle, filePath, alt, title)
        @id = id; @bundle = bundle; @filePath = filePath; @alt = alt; @title = title
		@fid = getLastFid()
		fileName = @filePath.split('/')
		if !fileName.nil? && !fileName.empty? then fileName = fileName.last else fileName = @filePath end
		@fileManaged = FileManaged.new(@fid, fileName, @filePath)
    end

    # Returns SQL
    def to_s
		return (@fileManaged.to_s + "\n" +
			'INSERT INTO `field_data_field_rightimage` VALUES (' + ([
					'node',
					@bundle,
					'0',
					@id.to_s,
					@id.to_s,
					'und',
					'0',
					@fid.to_s,
					@alt,
					@title
				].map {|x| "'" + x + "'"}).join(', ') + ');' +
			"\nINSERT INTO `field_revision_field_rightimage` VALUES (" + ([
					'node',
					@bundle,
					'0',
					@id.to_s,
					@id.to_s,
					'und',
					'0',
					@fid.to_s,
					@alt,
					@title
				].map {|x| "'" + x + "'"}).join(', ') + ');'
		);
    end
end

