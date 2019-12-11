# Reunion Scheduler

### Background

The reunion will be created via API. The reunion will have a duration measured in whole days e.g.. 30 or 60. There should be attributes to set and update the start, end and duration of the reunion and calculate the missing value if 2 are given. Other attributes of the reunion are name, description (with format) and location. The reunion should have the status of draft or published. You can only publish if all of the fields are filled, but can be saved as draft with any subset of attributes. When the reunion is deleted/remove it should be kept in the database and marked as such.

### Dependencies

* Ruby 2.6.3
* Rails 5.2.4
* Postgresql 9.1+ (tested on 10.10, but should work just fine with at least 9.1)

### Setup

- Under Ubuntu 18.04, you may need to install `libpq-dev` package to be able to install the `pg` gem
- The Postgres user needs to have the `superuser` role to be able to run the test suite properly
- create the database with `rails db:create`
- run database migrations with `rails db:migrate`
- run the server with `rails s`


### Endpoints and JSON structure

The latest `JSON:API` format specification was used to guide the API design. All POST and PATCH requests, whenever needing to send JSON information regarding attributes data, should use the following format:
```
{
  "data": {
    "type": "reunion"
    "attributes": {
      "name": "Test name",
      "description": "<br/> testing <br/> ",
      "location": "Testing location",
      "start_date": "2019/01/01",
      "end_date": "2019/01/02",
      "duration": "3"
    }
  }
}
```

The endpoints are the following:
- GET /reunions - gets reunions that have not been discarted
- GET /reunions/with_soft_delete - gets all reunions, including the discarded ones
- GET /reunions/:id: - gets information regarding a specific reunion that have not been discarted
- POST /reunions - creates a new reunion (use the JSON format above)
- PATCH /reunions/:id: - updates a current reunion (use the JSON format above)
- DELETE /reunions/:id: - discards a current reunion (doesn't delete from the database, just hides from other endpoints)
- POST /reunions/:id:/publish - publishes a current reunion