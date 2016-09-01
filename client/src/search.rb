require 'net/http'


def search(host, port, path) 

begin
	http = Net::HTTP.new(host, port)
	response = http.get(path)

	puts response.body
rescue Exception => e
	puts e.message
	puts e.backtrace.inspect
end
end
