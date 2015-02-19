# this sample shows how to submit content to the Appen Global API.
# the code is not intendeed to show Ruby best practive.
require './config.rb'

# call the API 
response = HTTParty.get(API_URI_STATUS)
	
# print out return values and HTTP status code
puts response.body, response.code
