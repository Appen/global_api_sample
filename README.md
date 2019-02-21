# Appen Global API sample code
<a href="http://appen.github.io/global_api_sample/">View sample code documentation</a><br>
Found a problem with the sample code? <a href="https://github.com/Appen/global_api_sample/issues">Report them here</a>


## Appen Global API Documentation

This document describes the RESTful Appen Global API.<br>
Appen Global API is currently at version _**'v2'**_.

## Introduction

This document is intended for Appen clients who need to programmatically interact with the Appen Global. &nbsp;With Global API's, you can submit content to be analyzed and then retrieve the results after work on the message has been completed.

Global API's are based on the [RESTful][1] concept and use [JSON][2] containers both for message submission and for returning results.

### Authentication

In order to call the Global API's, Appen must issue each client an API Key and API Secret.

>API Key: &nbsp; &nbsp; (string) &nbsp;Each Client is assigned an API Key which is passed to the API in every request. The key is used to identify the client on the server side.

>API Secret: &nbsp; (string) &nbsp;Each Client is assigned an API Secret which is used by the client to create an authentication token based on a combination of the message content and API Key. The API Secret is also used by the server to validate requests. &nbsp;Used in combination with Global API, all transactions can be authenticated and validated for authorized access.

### SSL

For security, all Global REST API's use HTTPS. &nbsp;HTTP protocol is not supported.

## API Calls

### API Status

#### Global_status/

The Checkup API consists of an HTTPS GET and returns 200 "OK" when operating normally.

URL: [https://api-global.appen.com/api/v2/global_status/&lt;api_key&gt;][6]

| Resource |  Description |
|---------------------------------------------|-----------------------------------------------------|
| GET /api/v2/global_status/<api_key> |  Can be used to validate API is up and running. 200 "OK" returned. |

Ruby code example:

    api_key = '<YOUR KEY HERE>'

    uri = URI.parse("https://api-global.appen.com/api/v2/global_status/#{api_key}")

    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Get.new(uri.request_uri)
    http.use_ssl = true

    response = http.request(request)

    puts "Code: #{response.code}"
    puts "Body: #{response.body}" 
  
### Submitting Content

#### Submit/

The Submit API consists of an HTTPS POST with the API Key in the URL and an associated JSON request body describing the content for moderation.

URL:&nbsp;[https://api-global.appen.com/api/v2/submit/&lt;api_key&gt;][3]

| Resource |  Description |
|---------------------------------------------|-----------------------------------------------------|
| POST /api/v2/submit/api_key/attributes.json |  API to submit content to the Appen Global Platform |

The attributes JSON body consists of a _submission_ block with a nested _content_ block. &nbsp;The _content_ block includes a nested _document_ block. Document blocks must include a _project_code_ and _auth_token_ while content blocks may include an optional _source_id_ field.



    {
      "submission":{
        "project_code":"xxx_project_code",
        "auth_token":"calculatedauthtoken",
        ...,
        "content":{
          "source_id":"unique_string_to_id_document",
          ...,
          "document":{
            ...
          }
        }
      }
    }

##### Submit API Parameter Reference
| Block |  Parameter |  Description |  Notes |
|------------|---------------|------------------------------|---------|
| Submission |  project_code |  Appen supplied Project Code |  &nbsp; |
| Submission |  auth_token | MD5 hash of content block and API Secret.| auth_token = Digest::MD5.hexdigest(content.to_json + api_secret) |
| Submission |  content { } |  content block |  Submission content (text) and descriptors. See Content block parameters. |
| Content |  source_id |  source id |  Unique content identifier. Required for API Result() |
| Content |  collection_code |  Document collection name |  Optional customer supplied string used to filter documents in Results(). |
| Content |  content_timestamp_utc |  Content timestamp in UTC |  &nbsp; |
| Content |  document { } |  document block |  See Document block parameters. |
| Document |  project specific params... |  Include all params required for Content Relevance (CR) projects. Multi-Content Relevance (MCR) and Side By Side (SxS) projects require items to be blocked in an array of content named 'multiple', each with an included 'sequence' number.  See examples in submit below for CR and MCR content.| &nbsp; |
| Document |  imageblob |  Imageblob is a special case document parameter to pass base64 encoded image files into Appen Global.  | ImageBlob side-search must be enabled.<br> File size limit of 100kb.<br> Supported file types include JPG, PNG and GIF.<br> Note: 502 Bad Gateway errors indicate oversize images |
| Document |  available_to_user_email |  Available_to_user_email specifies a user in Appen Global that will have access to work on the document identified by their email in the system | If specified, only this user will be able to work on the document.<br> If the email doesn't exist in Appen Global, it will be ignored and the document will be available to any user. |

#### Submit CURL Example


> curl -X POST -H "Content-type:application/json" -d '{"submission":{"auth_token":"Insert_calculated_authtoken_here","project_code":"cool_project_code","content":{"collection_code":"cool_test_collection","document":{"query":"query tokens"},"source_id":"unique_id"}}}' https://api-global.appen.com/api/v2/submit/api_key


#### Submit Ruby/Rails Content Block Examples


    def submit
      # CR Content
      content = {
        :source_id => source_id,
        :collection_code => 'Collection Name',
        :document =>  {
          :query => query,
          :url => url
        }
      }
      
      # CR with screencap Content
      content = {
        :source_id => source_id,
        :collection_code => 'Collection Name',
        :document =>  {
          :query => query,
          :sslayer_url => url,
          :screencap_url_image => nil
        }
      }
      
      # MCR Content
      multi_content = {
        :source_id => source_id,
        :collection_code => 'Collection Name',
        :document =>  {
          :query => query,
          :multiple => [
            {:url => url1,
             :product_title => product_title1,
             :sequence => 0
            },
            {:url => url2,
             :product_title => product_title2,
             :sequence => 1
            }
          ],
          :imageblob => "iVBORw0KG ... SuQmCC",
          :available_to_user_email => user_email
        }
      }
      
      # SxS content
        multi_content = {
        :source_id => source_id,
        :collection_code => 'Collection Name',
        :document =>  {
          :query => query,
          :url_1 => url1,
          :product_title_1 => product_title1,
          :url_2 => url2,
          :product_title_2 => product_title2,
          :multiple => [
            {:url => url1,
             :product_title => product_title1,
             :sequence => 0
            },
            {:url => url2,
             :product_title => product_title2,
             :sequence => 1
            }
          ],
          :available_to_user_email => user_email
        }
      }
      
      
    # SxS with image capture content (this example with use ScreenshotLayer to do screencap for item 1 and Grabz.it to do screenshot for item 2. See Screencap Test API for other screencap options)
        multi_content = {
        :source_id => source_id,
        :collection_code => 'Collection Name',
        :document =>  {
          :query => query,
          :sslayer_url_grouped_1 => url1,
          :grabzit_url_grouped_1 => nil,
          :screencap_url_img_grouped_1 => nil,
          :sslayer_url_grouped_2 => nil,
          :grabzit_url_grouped_2 => url2,
          :screencap_url_img_grouped_2 => nil,
          :multiple => [
            {:sslayer_url_grouped => url1,
             :grabzit_url_grouped => nil,
             :screencap_url_img_grouped => nil
             :sequence => 0
            },
            {:sslayer_url_grouped => nil,
             :grabzit_url_grouped => url2,
             :screencap_url_img_grouped => nil,
             :sequence => 1
            }
          ],
          :available_to_user_email => user_email
        }
      }

      auth_token = Digest::MD5.hexdigest(content.to_json + api_secret)
      attributes = {
        :submission => {
          :auth_token => auth_token,
          :project_code => project_code,
          :content => content  # Or multi_content for MCR project type
        }
      }
      options = { body: attributes.to_json,
                  headers: { 'Content-Type' => 'application/json', 'Accept' => 'application/json'} }
      response = self.post("https://api-global.appen.com/api/v2/submit/#{api_key}", options)
    end

#### Document Format for Multiple Items

When projects require multiple elements to be judged on a single document, the document JSON should be formatted with the repeating headers occuring after all single element headers in an array of hashes named 'mulitple'.  Each hash also contains a sequencing key named 'sequence' which is used to specify item ordering in the UI.
|

    def submit
      content = {
        :source_id => source_id,
        :collection_code => 'Collection Name',
        :document =>  {
          :unique_id => '12345',
          :query => query,
          :multiple => [
            { :url => item 1 url,
              :description => 'item 1 description',
              :sequence => 1 },
            { :url => item 2 url,
              :description => 'item 2 description',
              :sequence => 2 },
            { :url => item 3 url,
              :description => 'item 3 description',
              :sequence => 3 } ]
        }
      }
      ...
    end


### Retrieving Results

#### Results/

The Results API consists of a POST request with api_key in the URL. &nbsp;Results are returned in an associated JSON response body.

URL:&nbsp;[https://api-global.appen.com/api/v2/results/&lt;api_key&gt;][4]

| Resource |  Description |
|---------------------------------------------|-----------------------------------------------------|
| POST /results/v2/<api_key> |  API to retrieve content from the Appen Global Platform |

##### Results API Parameter Reference

The JSON body consists of a results block.

| Block |  Parameter |  Description |  Notes |
|------------|---------------|------------------------------|---------|
| Results |  project_code |  Appen supplied Project Code |  &nbsp; |
| Results |  auth_token |  MD5 hash of content block and API Secret. |  auth_token = Digest::MD5.hexdigest(content.to_json + api_secret) |
| Results |  content { } |  content block |  &nbsp; |
| Content |  ids |  Array of source ids |  &nbsp; |
| Content |  date_range { } |  Starting and ending dates in UTC time |  &nbsp; |
| Date_range |  collection_code |  Optional collection name filter |  Used only with date_range |
| Date_range |  start_date |  Date range starting datetime in 'YYYY-MM-DD HH:MM:SS' format |  Time zone is always UTC |
| Date_range |  end_date |  Date range ending datetime in 'YYYY-MM-DD HH:MM:SS' format |  &nbsp; |

##### Results API Return Value Reference

The returned JSON body consists of a return code, return msg and results block.

| Block |  Parameter |  Description |  Notes |
|------------|---------------|------------------------------|---------|
| Return Code |  200 |  HTTP_OK |  &nbsp; |
| Return JSON |  status |  'OK' = HTTP_OK Message |  &nbsp; |
| Return JSON |  results {} |  Results block |  &nbsp; |
| Results |  source_id |  Client source id |  &nbsp; |
| Results |  score_id |  APG document score record id |  &nbsp; |
| Results |  info |  Client info block |  &nbsp; |
| Results |  rating_score |  Member's raw rating score |  &nbsp; |
| Results |  global_id |  Member's id |  &nbsp; |
| Results |  annotated_at |  DateTime document score record was created |  &nbsp; |
| Results |  current_score_id |  Id of document score record considered the current score of record. This may be updated until project is complete. |  &nbsp; |
| Results |  audited |  Audited flag |  &nbsp; |

#### Results Ruby/Rails Example


    def get_results(ids)
      content = {
        :ids => ids
        -OR-
        :date_range => {
          :collection_code => 'Collection Code', # Optional collection name filter
          :start_date => '2014-12-17 07:00:00',  # Timezone is always UTC
          :end_date => '2014-12-18 06:59:59'
        }
      }
      auth_token = Digest::MD5.hexdigest(content.to_json + api_secret)

      attributes = {
        :results => {
          :auth_token => auth_token,
          :project_code => project_code,
          :content => content
        }
      }
      options = { body: attributes.to_json,
                  headers: { 'Content-Type' => 'application/json', 'Accept' => 'application/json'} }
      response = self.post("https://api-global.appen.com/results/#{api_key}", options)
    end


### Retrieving Project Status

#### Project Status/

The Project Status API consists of a POST request with api_key in the URL. &nbsp;Project statistics are returned in an associated JSON response body.

URL:&nbsp;[https://api-global.appen.com/api/v2/project_status/&lt;api_key&gt;][5]

| Resource |  Description |
|---------------------------------------------|-----------------------------------------------------|
| POST /api/v2/project_status/<api_key> |  API to retrieve project statistics from the Appen Global Platform |

##### Project Status API Parameter Reference

The JSON body consists of a project_status block.

| Block |  Parameter |  Description |  Notes |
|------------|---------------|------------------------------|---------|
| Project_status |  project_code |  Appen supplied Project Code |  &nbsp; |
| Project_status |  auth_token |  MD5 hash of content block and API Secret. |  auth_token = Digest::MD5.hexdigest(content.to_json + api_secret) |
| Project_status |  content { } |  content block |  &nbsp; |
| Content |  collection_code |  Optional collection name filter |  &nbsp; |

##### Project Status API Return Value Reference

The returned JSON body consists of a return code, return msg and results block.

| Block |  Parameter |  Description |  Notes |
|------------|---------------|------------------------------|---------|
| Return Code |  200 |  HTTP_OK |  &nbsp; |
| Return JSON |  status |  'OK' = HTTP_OK Message |  &nbsp; |
| Return JSON |  results {} |  Results block |  &nbsp; |
| Results |  Count_documents |  Total documents associated with project status request parameters |  &nbsp; |
| Results |  Overlap_depth |  Current project Overlap Depth |  This value can change as it is a project setting |
| Results |  Sum_overlap_count |  Sum of overlap records expected for documents associated with this request. |  &nbsp; |
| Results |  Sum_overlap_count_completed |  Sum of overlap records completed for documents associated with this request. |  &nbsp; |
| Results |  Sum_disagreement |  Current sum of document disagreements for documents associated with this request. |  &nbsp; |
| Results |  Sum_audited |  Current sum of document audits complete for documents associated with this request. |  &nbsp; |
| Results |  Count_document_score |  Current count of document scores for documents associated with this request. |  &nbsp; |
| Results |  Collection_complete |  Flag signaling that this collection has been marked complete. |  Note: No further submissions will be accepted on this collection. |

#### Get_project_status Ruby Example


    def get_project_status(collection_code=nil)
      content = {
        :collection_code => 'Collection Name'  # Optional collection name filter
      }
      auth_token = Digest::MD5.hexdigest(content.to_json + api_secret)

      attributes = {
        :project_status => {
          :auth_token => auth_token,
          :project_code => project_code,
          :content => content
        }
      }
      options = { body: attributes.to_json,
                  headers: { 'Content-Type' => 'application/json', 'Accept' => 'application/json'} }
      response = self.post("https://api-global.appen.com/project_status/#{api_key}", options)
    end



[1]: http://en.wikipedia.org/wiki/RESTful
[2]: http://en.wikipedia.org/wiki/JSON
[3]: https://api-global.appen.com/api/v2/submit/
[4]: https://api-global.appen.com/api/v2/results/
[5]: https://api-global.appen.com/api/v2/project_status/
[6]: https://api-global.appen.com/api/v2/global_status/

