require 'net/http'
require 'uri'
require 'json'
require 'net/http/post/multipart'#for uploading files

require_relative "addcontact/addcontacts"
require_relative "search"

#display the menu and run different functions according to selection and typein
#when asking user to type in, input validation must be made.

def menu (host, port)

	puts ""
	puts "-----------------------------"
	puts "host: #{host}"
	puts "port: #{port}"
	puts "1 - View all contacts."
	puts "2 - Search by name."
	puts "3 - Search by ID."
	puts "4 - Add contact."
	puts "5 - Exit."
	puts "Enter your selection..."

	selection = $stdin.gets.chomp.to_i
	case selection
	when 1
		path = "/phonebook/person/search/"

		search host, port, path
		menu host, port
	when 2 #check whether the intput contains space before running search.
	    puts "Type in a first name or last name without space. Or type Enter to view all contracts."	
		name = $stdin.gets.chomp.to_s
		name = name.strip
		if !name.delete(" ").eql? name
		puts "You typed in a name with no space. Try again."
			menu host, port
		end
		path = "/phonebook/person/search/#{name}"
		
		search host, port, path 
		menu host, port
	when 3 #check whethr the input is an integer before running search.
		begin
			puts "Type in an integer ID."
			id = $stdin.gets.chomp
			id = Integer(id)
			path = "/phonebook/person/#{id}"
			
			search host, port, path
			menu host, port
		rescue
			puts "Please type in an integer ID."
			menu host, port
		end
	when 4
		json = "./json/address.json"
	    puts "Type in the path to your json file. Otherwise, hit Enter to use the default json at #{json}."
		file = $stdin.gets.chomp.to_s
		if !file.empty?
			json = file
		end

		addcontacts host, port, json
		menu host, port
	when 5
		puts "Have a good day!"
		exit(0)
	else
		puts "Please type in a valid selection"
		menu host, port
	end

end
