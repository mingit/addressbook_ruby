require 'net/http'
require 'json'
require 'net/http/post/multipart'#for uploading files

require_relative 'addrecord'
require_relative 'uploadfile'

=begin
Function: POST add records from json file and upload photo if it is available

The json file may contain multiple records, each carried by a separate request.
The failure of one request cannot affect the requests of the other records.
=end

def addcontacts (host, port, jsonfile)

addrecordpath = "/phonebook/person/"

begin

	file = File.open(jsonfile, "r")
	records = JSON.parse(file.read)
	records.each do |record|
		puts JSON.pretty_generate(record)
		
		addrecord host, port, record

		#If photo field is not empty, try to upload a photo.
		if !record['photo'].to_s.empty?
			imagelocation = record['photo'].to_s
			imagename = "#{record['firstname']}\&!\&""#{record['lastname']}.jpg"
			uploadfile host, port, imagelocation, imagename
		end
		puts ""
	end

rescue Exception => e
	puts e.message
	puts e.backtrace.inspect
ensure
	file.close if file
end

end
