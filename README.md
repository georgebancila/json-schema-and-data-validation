# json-schema-and-data-validation

## Description

Using this small functionality you can validate a json response with a json file containing an example of that response.
You can validate based on structure (if they have the same keys) or you can check for data also. 

The small inconvenient is that for this version you have to specify the values in a Hash using sintax similar to this.

````
  verify_last_response('responses/get_message.json',
                                  id: "id:#{@message_id}",
                                  message: "message:#{@message}")
````
