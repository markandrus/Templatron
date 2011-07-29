#! /usr/local/bin/ruby

class FieldDataBody
    attr_accessor :id, :bundle, :bodyValue
    def initialize(id, bundle, bodyValue)
        @id = id; @bundle = bundle; @bodyValue = bodyValue
    end
    # Returns SQL
    def to_s
		return (
			'INSERT INTO `field_data_body` VALUES (' + ([
					'node',
					@bundle,
					'0',
					@id.to_s,
					@id.to_s,
					'und',
					'0',
					@bodyValue,
					'',
					'filtered_html'
				].map {|x| "'" + x + "'"}).join(', ') + ');' +
			'INSERT INTO `field_revision_body` VALUES (' + ([
					'node',
					@bundle,
					'0',
					@id.to_s,
					@id.to_s,
					'und',
					'0',
					@bodyValue,
					'',
					'filtered_html'
				].map {|x| "'" + x + "'"}).join(', ') + ');'
		);
    end
end

