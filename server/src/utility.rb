require 'pg'


=begin createTableIfnotFound                                                                                                                       
 - Check the connectivity of local database using default values. If fail, raise exception and exit.
 - Check the existence of the address book table. If not exist, create one. 
=end

def createTableIfnotFound(dbname, dbuser, dbpasswd, tablename)
begin
	conn = PG.connect(:dbname=>"#{dbname}", :user=>"#{dbuser}", :password=>"#{dbpasswd}")
	puts "Connect to the database #{dbname} using the role of #{dbuser}."
	puts "The table used in this program is #{tablename}. The table will be created if it has not existed yet."
	sql = "create table if not exists #{tablename} (id serial PRIMARY KEY, firstname varchar(15) NOT NULL, lastname varchar(15) NOT NULL, streetaddress varchar(30) NOT NULL, postcode varchar(10), city varchar(20) NOT NULL, country varchar(20), phone varchar(20), email varchar(30), photo varchar(300), unique(firstname, lastname))"	
	#puts sql
	conn.exec(sql);

rescue Exception => e
	puts "Postgresql Exception!"	
	puts e.message
	puts "Please provide valid database and user names."
	puts e.backtrace.inspect
	exit
ensure
	conn.close if conn
end
end
