require 'net/http'
require 'json'

def addrecord (host, port, record)

addrecordpath = "/phonebook/person/"

begin
		http = Net::HTTP.new(host, port) 
		request = Net::HTTP::Post.new(addrecordpath, 'Content-Type' => 'application/json')
		request.body = record.to_json
		response = http.request(request)
		puts response.body

rescue Exception => e
	puts e.message
	puts e.backtrace.inspect
end

end
