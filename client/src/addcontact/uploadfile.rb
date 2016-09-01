require 'net/http'
require 'json'
require 'net/http/post/multipart'#for uploading files

##POST add records from json file and upload photo if it is available



def uploadfile (host, port, filelocation, filename) 

addphotopath = "/phonebook/person/photo/"

begin
    file = File.open(filelocation, "r")
	http = Net::HTTP.new(host, port)
	request = Net::HTTP::Post::Multipart.new addphotopath,
    "photo" => UploadIO.new(file, "image/jpg", filename)
	
	response = http.request(request)
	puts response.body

rescue Exception => e
	puts e.message
	puts e.backtrace.inspect
	file.close if file
end

end
