# SuperSaaS Ruby API Client

Manage appointments, users, and other object on the [SuperSaaS appointment scheduling](https://www.supersaas.com/) platform in Ruby.

The SuperSaaS API provides endpoints that can be used to read or update information from your SuperSaaS account. 
This can be useful to build an integration with back-end system or to extract information to generate reports.

## Prerequisites

1. [Register for a (free) SuperSaaS account](https://www.supersaas.com/accounts/new), and
2. Get your account name and API key on the [Account Info](https://www.supersaas.com/accounts/edit) page.

### Dependencies

No external dependencies. Only the `json` and `net/http` gems from the ruby standard library are used.

## Installation

Install with:

    $ gem install supersaas-api-client

Alternatively, you can use `bundler` to install it by adding this line to you Gemfile. 
The supersaas-api-client may update major versions with breaking changes, so it's recommended to use a major version when expressing the gem dependency. e.g.

    gem 'supersaas-api-client', '~> 2'

## Configuration

The `Client` can be used either (1) through the singleton helper method `instance`, e.g.
    
    Supersaas::Client.instance #=> <Supersaas::Client>
    
Or else by (2) simply creating a new client instance manually, e.g.
    
    Supersaas::Client.new #=> <Supersaas::Client>

Initialize the SuperSaaS `Client` with authorization credentials:

    Supersaas::Client.configure do |config|
      config.account_name = 'accnt'
      config.api_key = 'xxxxxxxxxxxxxxxxxxxxxx'
    end
    
> Note, ensure that `configure` is called before `instance` or `new`, otherwise the client will be initialized with configuration defaults.

If the client isn't configured explicitly, it will use default `ENV` variables for the account name and api key.

    ENV['SSS_API_ACCOUNT_NAME'] = 'your-env-supersaas-account-name'
    ENV['SSS_API_KEY'] = 'your-env-supersaas-account-name' 
    Supersaas::Client.instance.account_name #=> 'your-env-supersaas-account-name'
    Supersaas::Client.instance.api_key #=> 'your-env-supersaas-account-name'
    
All configuration options can be individually set on the client.

    Supersaas::Client.instance.api_key = 'xxxxxxxxxxxxxxxxxxxxxx' 
    Supersaas::Client.instance.verbose = true
    ...

## API Methods

Details of the data structures, parameters, and values can be found on the developer documentation site:

https://www.supersaas.com/info/dev

#### Create User

Create a user with user attributes params `create(attributes, user_id = nil, webhook = nil, duplicate = nil)`.
If webhook=true is present it will trigger any webhooks connected to the account.
To avoid a ‘create’ action from being automatically interpreted as an ‘update’, you can add the parameter duplicate=raise, then error `422 Unprocessable Entity` will be raised.
If in your database your user has id 1234 then you can supply a foreign key in format 1234fk in `user_id` (optional) which you can use to identify user:
If validation fails for any field then error `422 Unprocessable Entity` will be raised and any additional information will be printed to your log.
Data fields that you can supply can be found [here.](https://www.supersaas.com/info/dev/user_api)

    Supersaas::Client.instance.users.create({name: 'name@name.com', full_name: 'Example Name', email: 'example@example.com'}, '1234fk', true, 'raise') #=> http://www.supersaas.com/api/users/1234.json

#### Update User

Update a user by `user_id` with user attributes params `update(user_id, attributes, webhook = nil, notfound = nil)`.
If webhook=true is present it will trigger any webhooks connected to the account.
To avoid automatically creating a new record, you can add the parameter notfound=error or notfound=ignore to return a 404 Not Found or 200 OK respectively.
If the `user_id` does not exist 404 error will be raised.
You only need to specify the attributes you wish to update:

    Supersaas::Client.instance.users.update(12345, {full_name: 'New Name'}, true, "ignore") #=> nil
    
#### Delete User

Delete a single user by `user_id`, and if the user does not exist 404 error will be raised.

    Supersaas::Client.instance.users.delete(12345) #=> nil
    
#### Get User

Get a single user by `user_id`, and if the user does not exist 404 error will be raised:

    Supersaas::Client.instance.users.get(12345) #=> <Supersaas::User>

#### List Users

Get all users with optional `form` and `limit`/`offset` pagination params, `list(form = nil, limit = nil, offset = nil)`.
User can have a form attached, and setting `form=true` shows the data:

    Supersaas::Client.instance.users.list(false, 25, 0) #=> [<Supersaas::User>, ...]

#### List Fields of User object

Get all the fields available to user object:

    Supersaas::Client.instance.users.field_list #=> [<Supersaas::FieldList>, ...]

#### Create Appointment/Booking

Create an appointment with `schedule_id`, and `user_id(optional)` (see API documentation on [create new](https://www.supersaas.com/info/dev/appointment_api#bookings_api)) appointment attributes and optional `form` and `webhook` params,
`create(schedule_id, user_id, attributes, form = nil, webhook = nil)`:

    Supersaas::Client.instance.appointments.create(12345, 67890, {full_name: 'Example Name', email: 'example@example.com', slot_id: 12345}, true, true) #=> http://www.supersaas.com/api/bookings/12345.json

#### Update Appointment/Booking

Update an appointment by `schedule_id` and `appointment_id` with appointment attributes, see the above link,
`update(schedule_id, appointment_id, attributes, form = nil, webhook = nil)`:

    Supersaas::Client.instance.appointments.update(12345, 67890, {full_name: 'New Name'}) #=> nil

#### Delete Appointment/Booking

Delete a single appointment by `schedule_id` and `appointment_id`:

    Supersaas::Client.instance.appointments.delete(12345, 67890) #=> nil

#### Get Appointment/Booking

Get a single appointment by `schedule_id` and `appointment_id`:

    Supersaas::Client.instance.appointments.get(12345, 67890) #=> <Supersaas::Appointment>

#### List Appointments/Bookings

List appointments by `schedule_id`, with `form` and `start_time` and `limit` view params,
`list(schedule_id, form = nil, start_time = nil, limit = nil)`:

    Supersaas::Client.instance.appointments.list(12345, 67890, true, true) #=> [<Supersaas::Appointment>, ...]

#### Get Agenda

Get agenda (upcoming) appointments by `schedule_id` and `user_id`, with `from_time` view param ([see](https://www.supersaas.com/info/dev/appointment_api#agenda),
`agenda(schedule_id, user_id, from_time = nil, slot = false)`:

    Supersaas::Client.instance.appointments.agenda(12345, 67890, '2018-01-31 00:00:00') #=> [<Supersaas::Appointment>, ...]

#### Get Agenda Slots

Get agenda (upcoming) slots by `schedule_id` and `user_id`, with `from_time` view param,
`agenda_slots(schedule_id, user_id, from_time = nil)`:

    Supersaas::Client.instance.appointments.agenda_slots(12345, 67890, '2018-01-31 00:00:00') #=> [<Supersaas::Slot>, ...]    

_Note: only works for capacity type schedules._

#### Get Available Appointments/Bookings

Get available appointments by `schedule_id`, with `from` time and `length_minutes` and `resource` params ([see](https://www.supersaas.com/info/dev/appointment_api#availability_api),
`available(schedule_id, from_time, length_minutes = nil, resource = nil, full = nil, limit = nil)`:

    Supersaas::Client.instance.appointments.available(12345, '2018-01-31 00:00:00', 15, 'My Class') #=> [<Supersaas::Appointment>, ...]

#### Get Recent Changes

Get recently changed appointments by `schedule_id`, with `from` time, `to` time, `user` user, `slot` view params (see [docs](https://www.supersaas.com/info/dev/appointment_api#recent_changes)),
`changes(schedule_id, from_time = nil, to = nil, slot = false, user = nil, limit = nil, offset = nil)`:

    Supersaas::Client.instance.appointments.changes(12345, '2018-01-31 00:00:00', '2019-01-31 00:00:00',  true) #=> [<Supersaas::Appointment>, ...]

#### Get range of appointments

Get range of appointments by `schedule_id`, with `today`, `from` time, `to` time and `slot` view params (see [docs](https://www.supersaas.com/info/dev/appointment_api#range)),
`range(schedule_id, today = false, from_time = nil, to = nil, slot = false, user = nil, resource_id = nil, service_id = nil, limit = nil, offset = nil)`:

    Supersaas::Client.instance.appointments.range(12345, false, '2018-01-31 00:00:00', '2019-01-31 00:00:00', true) #=> [<Supersaas::Appointment>, ...]/[<Supersaas::Slot>, ...]

#### List Template Forms

Get all forms by template `superform_id`, with `from_time`, and `user` params ([see](https://www.supersaas.com/info/dev/form_api)):

    Supersaas::Client.instance.forms.list(12345, '2018-01-31 00:00:00') #=> [<Supersaas::Form>, ...]

#### Get Form

Get a single form by `form_id`, will raise 404 error if not found:

    Supersaas::Client.instance.forms.get(12345) #=> <Supersaas::Form>

#### Get a list of SuperForms

Get a list of Form templates (SuperForms):

    Supersaas::Client.instance.forms.forms #=> [<Supersaas::SuperForm>, ...]

#### List Promotions

Get a list of promotional coupon codes with pagination parameters `limit` and `offset` (see [docs](https://www.supersaas.com/info/dev/promotion_api)),
`list(from_time = nil, user = nil)`:

    Supersaas::Client.instance.promotions.list #=> [<Supersaas::Promotion>, ...]

#### Get a single coupon code

Retrieve information about a single coupon code use with `promotion_code`:

    Supersaas::Client.instance.promotions.promotion(12345) #=> <Supersaas::Promotion>

#### Duplicate promotion code

Duplicate a template promotion by giving (new) `promotion_code` and `template_code` in that order,
duplicate_promotion_code(promotion_code, template_code):


    Supersaas::Client.instance.promotions.duplicate_promotion_code(12345, 94832838) #=> nil

#### List Groups in an account

List Groups in an account ([see](https://www.supersaas.com/info/dev/information_api)):

    Supersaas::Client.instance.groups.list #=> [<Supersaas::Group>, ...]

#### List Schedules

Get all account schedules:

    Supersaas::Client.instance.schedules.list #=> [<Supersaas::Schedule>, ...]

#### List Services / Resources

Get all services/resources by `schedule_id`:

    Supersaas::Client.instance.schedules.resources(12345) #=> [<Supersaas::Resource>, ...]    

_Note: does not work for capacity type schedules._

#### List Fields of a Schedule

Get all the available fields of a schedule by `schedule_id`:

    Supersaas::Client.instance.schedules.field_list(12345) #=> [<Supersaas::FieldList>, ...]


## Examples

The ./examples folder contains several executable Ruby scripts demonstrating how to use the API Client for common requests.

The examples will require your account name, api key, and some of the examples a schedule id and/or user id and/or form id. These can be set as environment variables. e.g.

    $ gem install supersaas-api-client
    $ SSS_API_UID=myuserid SSS_API_SCHEDULE=myscheduleid SSS_API_ACCOUNT_NAME=myaccountname SSS_API_KEY=xxxxxxxxxxxxxxxxxxxxxx ./examples/appointments.rb
    $ SSS_API_FORM=myuserid SSS_API_ACCOUNT_NAME=myaccountname SSS_API_KEY=xxxxxxxxxxxxxxxxxxxxxx ./examples/forms.rb 
    $ SSS_API_ACCOUNT_NAME=myaccountname SSS_API_KEY=xxxxxxxxxxxxxxxxxxxxxx ./examples/users.rb

## Testing

The HTTP requests can be stubbed by configuring the client with the `dry_run` option, e.g.

    Supersaas::Client.instance.dry_run = true

Note, stubbed requests always return an empty Hash.

The `Client` also provides a `last_request` attribute containing the `Net::HTTP` object from the last performed request, e.g. 

    Supersaas::Client.instance.last_request #=> <Net::HTTP::Get>

The headers, body, path, etc. of the last request can be inspected for assertion in tests, or for troubleshooting failed API requests.

For additional troubleshooting, the client can be configured with the `verbose` option, which will `puts` any JSON contents in the request and response, e.g.

    Supersaas::Client.instance.verbose = true 

## Error Handling

The API Client raises a custom exception for HTTP errors and invalid input. Rescue from `Supersaas::Exception` when making API requests. e.g.

    begin
      Supersaas::Client.instance.users.get
    rescue Supersaas::Exception => e
      # Handle error
    end

Some errors have more information and are printed to the log before raising the error e.g.

    appointment = Supersaas::Client.instance.appointments.create(12345, {bad_field_name: ''})
    "Error 400, Bad request: unknown attribute 'bad_field_name' for Booking."

## Additional Information

+ [SuperSaaS Registration](https://www.supersaas.com/accounts/new)
+ [Product Documentation](https://www.supersaas.com/info/support)
+ [Developer Documentation](https://www.supersaas.com/info/dev)

Contact: [support@supersaas.com](mailto:support@supersaas.com)

## Releases

The package follows [semantic versioning](https://semver.org/), i.e. MAJOR.MINOR.PATCH 

## License

The SuperSaaS Ruby API Client is available under the MIT license. See the LICENSE file for more info.
