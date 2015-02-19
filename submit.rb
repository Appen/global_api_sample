# this sample shows how to submit content to the Appen Global API.
# the code is not intendeed to show Ruby best practive.
require './config.rb'

# put your actual content to be submitted here.
# the collection_code is optional.
# the actual attributes within document depneds on your specific project.
content = {
  source_id: '123546',
  collection_name: '2015-02-18 Submissions',
  document:  {
    query: 'managed crowd',
    url: 'http://www.appen.com'
  }
}

# generate an MD5 hash using the API secret.
# used in validating the request when received by the API.
generated_auth_token = Digest::MD5.hexdigest(content.to_json + API_SECRET)

# call the API 
response = HTTParty.post(API_URI_SUBMIT,
  body: {
    submission: {
      project_code: PROJECT_CODE,
      auth_token: generated_auth_token,
      content: content
    }
  }.to_json,
  headers: { 'Content-Type' => 'application/json' } )

# print out return values and HTTP status code
puts response.body, response.code
