require 'pg'
require 'json'
require 'sinatra'
require_relative 'src/utility'

#Replace dbname and dbuser as follows with the username and password for your database.
dbname = 'postgres'
dbuser = 'postgres'
dbpasswd = ''
#replace tablename if it conflicts with a table in your database
tablename = 'addressbook_liming'#make a complex table name to avoid conflicting with existing tables. Feel free to replace it.

puts ""    
puts "-----------------------------"
puts "Type in the database name or type Enter to use the default database #{dbname} (Ctrl+c to exit)."
databasename = $stdin.gets.chomp.to_s
if !databasename.delete(" ").empty?
	dbname = databasename
end

puts "Type in the database user name or type Enter to use the default name #{dbuser} (Ctrl+c to exit)."
databaseuser = $stdin.gets.chomp.to_s
if !databaseuser.delete(" ").empty?
	dbuser = databaseuser
end

puts "Type in the database password or type Enter to leave it empty (Ctrl+c to exit)."
databasepasswd= $stdin.gets.chomp.to_s
if !databasepasswd.delete(" ").empty?
	dbpasswd = databasepasswd
end

=begin createTableIfnotFound
- Check the connectivity of local database using default values. If fail, raise exception and exit.
- Check the existence of the address book table. If not exist, create one. 
=end
createTableIfnotFound(dbname, dbuser, dbpasswd, tablename)

##
get '/phonebook/person/search/:id' do
begin
	conn = PG.connect(:dbname=>"#{dbname}", :user=>"#{dbuser}", :password=>"#{dbpasswd}")
	content=""
	if !params['id'].nil?
		sql = "select id, firstname, lastname, streetaddress, postcode, city, country, email, phone from #{tablename} where firstname ilike '%#{params['id']}%' or lastname ilike '%#{params['id']}%'"
	
		results = conn.exec(sql) 
		if results.num_tuples.zero?
			content = "No record found!"
		else
			results.each_row do |row|
			content << row.to_s
			content += "\n"
			#puts row.to_s
			end
		end
	end
	"#{content}"
rescue Exception => e
	puts e.message
	puts e.backtrace.inspect
	response = e.message
ensure
	conn.close if conn
	end
	"#{content}"
end


##
get '/phonebook/person/search/' do
begin
	#conn = PG.connect(:dbname=>"#{dbname}", :user=>"#{dbuser}")
	conn = PG.connect(:dbname=>"#{dbname}", :user=>"#{dbuser}", :password=>"#{dbpasswd}")
	content=""
	sql = "select id, firstname, lastname, streetaddress, postcode, city, country, email, phone from #{tablename}"
	results = conn.exec(sql) 
	if results.num_tuples.zero?
		content = "No record found!"
	else
		results.each_row do |row|
		content << row.to_s
		content += "\n"
		#puts row.to_s
		end
	end
rescue Exception => e
	puts e.message
	puts e.backtrace.inspect
	response = e.message
ensure
	conn.close if conn
	end	
	"#{content}"
end


##
get '/phonebook/person/:id' do
begin
	conn = PG.connect(:dbname=>"#{dbname}", :user=>"#{dbuser}", :password=>"#{dbpasswd}")
	content=""
	if !params['id'].nil?
		results = conn.exec("select id, firstname, lastname, streetaddress, postcode, city, country, email, phone from #{tablename} where id=#{params['id']}") 
		if results.num_tuples.zero?
			content = "No record found!"	
		else
			results.each_row do |row|
			content << row.to_s
			content += "\n"
			#puts row.to_s
			end
		end
	end
rescue Exception => e
	puts e.message
	puts e.backtrace.inspect
	response = e.message
ensure
	conn.close if conn
	end	
	"#{content}"
end


##
post '/phonebook/person/' do
	response = ""

begin
	payload = JSON.parse(request.body.read.to_json)
	record = JSON.parse(payload)
	name = "#{record['firstname']}""#{record['lastname']}" 
	if name.empty?
		raise "Fail to add this record. ERROR:  firstname and lastname are empty at the same time!"
	else
		name = "#{record['firstname']}"" #{record['lastname']}" 
	end
	
	conn = PG.connect(:dbname=>"#{dbname}", :user=>"#{dbuser}", :password=>"#{dbpasswd}")
	sql = "insert into #{tablename} (firstname, lastname, streetaddress, postcode, city, country, email, phone) select '#{record['firstname']}', '#{record['lastname']}', '#{record['streetaddress']}','#{record['postcode']}', '#{record['city']}', '#{record['country']}', '#{record['email']}', '#{record['phone']}' where not exists (select * from #{tablename} where firstname='#{record['firstname']}' and lastname='#{record['lastname']}') returning firstname, lastname"
	results = conn.exec(sql)
	if results.num_tuples.zero?
		response = "Fail to add this record. WARN:  the address book has had a record of ""#{name}"" already."
	else
		response = "Add new record of ""#{name}"" in the address book. "
	end

rescue StandardError => e
	response = e.message
rescue Exception => e
	puts e.message
	puts e.backtrace.inspect
	response = "Fail to add this record. ""#{e.message}"
ensure
	conn.close if conn
	end
	"#{response}"
end


##
post '/phonebook/person/photo/' do
begin
	filename = params[:photo][:filename]
	file = params[:photo][:tempfile]
	if filename.empty?
		raise "ERROR:  file name is empty"
	end
	if filename.nil?
		raise "ERROR:  file name is empty"
	end

	name = filename.split(".jpg")
	namenoext = name.join()

	firstname = namenoext.split("\&!\&")[0]
	lastname = namenoext.split("\&!\&")[1]
	
	name = filename.split("\&!\&")
	filename = name.join(" ")
	
	if firstname.nil?
		if lastname.nil?
			raise "Fail to add photo. ERROR:  firstname and lastname are empty at the same time!"
		end
	end
	
	filelocation = "./upload/photo/#{filename}" 	
	File.open(filelocation, 'wb') do |f|
		f.write(file.read)
	end	

	conn = PG.connect(:dbname=>"#{dbname}", :user=>"#{dbuser}", :password=>"#{dbpasswd}")
	sql = "update #{tablename} set photo='#{filelocation}' where firstname='#{firstname}' and lastname='#{lastname}' returning firstname, lastname"
	results = conn.exec(sql)
	if results.num_tuples.zero?
		response = "Fail to add a photo for #{firstname} #{lastname}. WARN:  The address book has no record of #{firstname} #{lastname}."
	else
		response = "Add/update the photo of #{firstname} #{lastname} in the address book successfully. "
	end

rescue StandardError => e
	response = e.message
rescue Exception => e
	puts e.message
	puts e.backtrace.inspect
	response = e.message
ensure
	"#{response}"
end
end
