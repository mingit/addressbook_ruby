#addressbook V1.0

What: Assignment (Digital Foodie interview): Ruby implemented address book application for storing and fetching person information.
When: August 2016
Who: Dr. Ming Li (Author)
		- Email: ming.li@aalto.fi
	    - Phone: +358 (0)50 5122 839

Programming environment:
	- Ubuntu 16.04 (it runs on Parallels hosted by OS X 10.11.6)
	- Ruby

Basic requirements:
1. Server
---------
The server must respond to methods
a) HTTP GET http://<host>/phonebook/person/search/<term>
  - If search term is given, returns a list of matching records, or not found. Matching criteria is up to you.
  - Empty search term returns all records.
b) HTTP GET http://<host>/phonebook/person/<id>
  - Returns the matching record, or not found.
c) HTTP POST http://<host>/phonebook/person/
  - Creates a new record from JSON data given in POST body. Returns reference the newly created record.
*Data must be stored in PostgreSQL database.
Hint: http://www.sinatrarb.com/ is easy to use lightweight web server framework.
The server setup script must initialize and start the server with one command. You can assume working Postgres instance.
2. Client
---------
a) Demonstrate a working server with a simple command line client application. 
b) Post data should be read from a file. 
c) Query results can be outputted to stdout.

Extra credit:
----------
a) Run the server in Docker
b) Run server in AWS
c) Instead of a CLI client, implemented a web servive, which can be accessed with a modern browser.
d) Allow storing an image for a person.

Satisfaction:
1. Basic requirements: are all satisfied
2. The following Extra credit functions are satisfied.  
	- Storing an image for a person.
	- Run the server in Docker (the client has to be run in Docker also to connect to the server successfully. Otherwise, the connection fails due to unknown network problem. The host Ubuntu is actually a virtual machine running on Parallels, which is hosted on OS X. The network issue may root from it.) 

Program logic in general:
a) HTTP GET
	1. Client sends http.get to server.
	2. Route on server matches request.
	3. Invoked route runs database query and sends back result to client.
b) HTTP POST 
	1. Client reads "address.json" file on local device. 
	2. Client sends server http requests each carrying one record from json file.
	3. If there is photo of the person, make a separate http request to send the photo.
	4. Route on server matches request.
	5. Invoked route first runs database insert operaiton if the record is new, and then sends back result to client.
	6. Invoked route first runs database update operation if it receives a add photo request, and then sends back result to client.

Database design:  Table addressbook
	  Column    |                Type                |                Note             
 -------------------------------------------------------------------------------------------------
  id            | integer   SERIAL       Primary key |  
  firstname     | character varying(15)  not null    |
  lastname      | character varying(15)  not null    |
  streetaddress | character varying(30)  not null    |
  postcode      | character varying(10)              |
  city          | character varying(20)  not null    |
  country       | character varying(20)              |
  email         | character varying(30)              |
  phone         | character varying(20)              |
  photo         | character varying(300)             | path to an external photo on local device.   
 -------------------------------------------------------------------------------------------------
  Unique (firstname, lastname)
  firstname and lastname cannot be blank at the same time.

How to run:
a) Preparation:
	- Install required gems:
		- sudo gem install pg
		- sudo gem install json
		- sudo gem install sinatra
		- sudo gem install multipart-post
	- Working Postgres instance
	- Create postgresql database role with previliege to create database and table. The default database name and role are liming and liming respectively. If you want to use other names, please REPLACE the corresponding variables in server.rb.
b) Run server 
	- ruby server.rb
	- After running the script above, please type in the database information according prompt before running the client later.
	- Note: the script will create a new addressbook table if it cannot find addressbook in the current database. 
c) Run client (CLI client)
	- ruby client.rb
d) Json records are stored in address.json. Exception raises if no there is no address.json file.
e) Photo folder contains photos.

First time use:
Please note that there will be no data on server database if you run this program for the first time. You need to upload data from client side by following the menu provided by the client.

Test: Various tests were covered to make addressbook robust. Some (but not limited to) are listed as follows:
	- Invalid user input.
	- Invalid photo location.
	- Invalid json file location.
	- Empty first name and last name.
	- Add repeat json (same firt name and last name).
	- ...

Known limitations for further development:
	- Only support CLI client.
	- Only support .jpg photo upload.
	- HTTP GET only retrieves text information excluding photo.
	- Only support storing photo on local device instead of on cloud.

Instruction on how to run postgresql on Ubuntu in Docker
Host: Ubuntu 16.04
Guest: Ubuntu over Docker
In the following text, Ubuntu is used to refer the Ubuntu in Docker.
1) Install postgresql (the version might be different)
	- apt install postgresql-client postgresql-client-common postgresql-client-9.5
	- apt install postgresql-contrib
	- apt install postgresql-server-dev-9.5
2) postgres role and database are created as default after installation.
3) Add the following environment variables in /etc/profile
	export PATH=/usr/lib/postgresql/9.5/bin:$PATH
	export PGDATA=/etc/postgresql/9.5/main
4) Swtich to user postgres by running su - postgres
5) Problem solving
	Problem: the postgresql is not running stablly on Ubuntu in Docker due to unknown reasons. E.g., the database may shutdown itself.
	Solution: Restart if problem appears by running /etc/init.d/postgresql restart
