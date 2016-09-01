require_relative "src/menu"

host = "localhost"
port = 4567

puts ""                                                                                                                                            
puts "-----------------------------"
puts "Type in the server address or type Enter to use the default address #{host} (Ctrl+c to exit)."
hostaddr = $stdin.gets.chomp.to_s
if !hostaddr.delete(" ").empty?
host = hostaddr
end 

puts "Type in the server listening port or type Enter to use the default port #{port} (Ctrl+c to exit)."
begin
	hostport = $stdin.gets.chomp
	if !hostport.to_s.delete(" ").empty?
		port = Integer(hostport)
	end
rescue 
	puts "Please type in an integer port."
	retry
end

menu host, port
