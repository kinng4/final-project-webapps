Tools needed:
sqlite3, and all gems listed in the Gemfile

To start the website:
Run sinatra_main.rb

To connect to the database development.db:
Double click in the development.db file.
Then in the database connection that was created, right click and choose databse properties.
In the new window, look if there are drivers needed to be installed, and once installed 
test connection.

To clean the data stored in development.db currently:

Run IRB Console.
In the command line write:

>>require './user'
>>require './votes'
>>require './sites'
>>User.auto_migrate!
>>Voting.auto_migrate!
>>Site.auto_migrate!