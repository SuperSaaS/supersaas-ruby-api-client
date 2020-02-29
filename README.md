# SuperSaaS Ruby API Client

Online bookings/appointments/calendars in Ruby using the SuperSaaS scheduling platform - https://supersaas.com

The SuperSaaS API provides services that can be used to add online booking and scheduling functionality to an existing website or CRM software.

## Prerequisites

1. [Register for a (free) SuperSaaS account](https://www.supersaas.com/accounts/new), and
2. get your account name and API key on the [Account Info](https://www.supersaas.com/accounts/edit) page.

##### Dependencies

Ruby 1.9 or greater.

No external libraries. Only the native `json` and `net/http` standard libs are used.

## Installation

1: Gemfile

The SuperSaaS Ruby API Client is available from RubyGems and can be included in your project GemFile. Note, the supersaas-api-client may update major versions with breaking changes, so it's recommended to use a major version when expressing the gem dependency. e.g.

    gem 'supersaas-api-client', '~> 1'

2: System Gem

You can install the SuperSaaS Ruby API Client globally by using the gem command. Open a terminal and enter the following command:

    $ gem install supersaas-api-client

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

#### List Schedules

Get all account schedules:

    Supersaas::Client.instance.schedules.list #=> [<Supersaas::Schedule>, ...]
    
#### List Resource

Get all services/resources by `schedule_id`:

    Supersaas::Client.instance.schedules.resources(12345) #=> [<Supersaas::Resource>, ...]    

_Note: does not work for capacity type schedules._

#### Create User

Create a user with user attributes params:

    Supersaas::Client.instance.users.create({name: 'name@name.com', full_name: 'Example Name', email: 'example@example.com'}) #=> nil

#### Update User

Update a user by `user_id` with user attributes params:

    Supersaas::Client.instance.users.update(12345, {full_name: 'New Name'}) #=> nil
    
#### Delete User

Delete a single user by `user_id`:

    Supersaas::Client.instance.users.delete(12345) #=> nil
    
#### Get User

Get a single user by `user_id`:

    Supersaas::Client.instance.users.get(12345) #=> <Supersaas::User>

#### List Users

Get all users with optional `form` and `limit`/`offset` pagination params:

    Supersaas::Client.instance.users.list(false, 25, 0) #=> [<Supersaas::User>, ...]

#### Create Appointment/Booking

Create an appointment by `schedule_id` and `user_id` with appointment attributes and `form` and `webhook` params:

    Supersaas::Client.instance.appointments.create(12345, 67890, {full_name: 'Example Name', email: 'example@example.com', slot_id: 12345}, true, true) #=> nil

#### Update Appointment/Booking

Update an appointment by `schedule_id` and `appointment_id` with appointment attributes params:

    Supersaas::Client.instance.appointments.update(12345, 67890, {full_name: 'New Name'}) #=> nil

#### Delete Appointment/Booking

Delete a single appointment by `schedule_id` and `appointment_id`:

    Supersaas::Client.instance.appointments.delete(12345, 67890) #=> nil

#### Get Appointment/Booking

Get a single appointment by `schedule_id` and `appointment_id`:

    Supersaas::Client.instance.appointments.get(12345, 67890) #=> <Supersaas::Appointment>

#### List Appointments/Bookings

List appointments by `schedule_id`, with `form` and `start_time` and `limit` view params:

    Supersaas::Client.instance.appointments.list(12345, 67890, true, true) #=> [<Supersaas::Appointment>, ...]

#### Get Agenda

Get agenda (upcoming) appointments by `schedule_id` and `user_id`, with `from_time` view param:

    Supersaas::Client.instance.appointments.agenda(12345, 67890, '2018-01-31 00:00:00') #=> [<Supersaas::Appointment>, ...]

#### Get Agenda Slots

Get agenda (upcoming) slots by `schedule_id` and `user_id`, with `from_time` view param:

    Supersaas::Client.instance.appointments.agenda_slots(12345, 67890, '2018-01-31 00:00:00') #=> [<Supersaas::Slot>, ...]    

_Note: works only for capacity type schedules._

#### Get Available Appointments/Bookings

Get available appointments by `schedule_id`, with `from` time and `length_minutes` and `resource` params:

    Supersaas::Client.instance.appointments.available(12345, '2018-01-31 00:00:00', 15, 'My Class') #=> [<Supersaas::Appointment>, ...]

#### Get Recent Changes

Get recently changed appointments by `schedule_id`, with `from` time, `to` time and `slot` view param:

    Supersaas::Client.instance.appointments.changes(12345, '2018-01-31 00:00:00', '2019-01-31 00:00:00',  true) #=> [<Supersaas::Appointment>, ...]


#### Get list of appointments

Get list of appointments by `schedule_id`, with `today`,`from` time, `to` time and `slot` view param:

    Supersaas::Client.instance.appointments.range(12345, false, '2018-01-31 00:00:00', '2019-01-31 00:00:00', true) #=> [<Supersaas::Appointment>, ...]/[<Supersaas::Slot>, ...]


#### List Template Forms

Get all forms by template `superform_id`, with `from_time` param:

    Supersaas::Client.instance.forms.list(12345, '2018-01-31 00:00:00') #=> [<Supersaas::Form>, ...]

#### Get Form

Get a single form by `form_id`:

    Supersaas::Client.instance.forms.get(12345) #=> <Supersaas::Form>

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

Validation errors are assigned to the response model. e.g.

    appointment = Supersaas::Client.instance.appointments.create(12345, {bad_field_name: ''})
    appointment.errors #=> [{"status":"400","title":"Bad request: unknown attribute 'bad_field_name' for Booking."}]

## Additional Information

+ [SuperSaaS Registration](https://www.supersaas.com/accounts/new)
+ [Product Documentation](https://www.supersaas.com/info/support)
+ [Developer Documentation](https://www.supersaas.com/info/dev)
+ [Python API Client](https://github.com/SuperSaaS/supersaas-python-api-client)
+ [PHP API Client](https://github.com/SuperSaaS/supersaas-php-api-client)
+ [NodeJS API Client](https://github.com/SuperSaaS/supersaas-nodejs-api-client)
+ [C# API Client](https://github.com/SuperSaaS/supersaas-csharp-api-client)
+ [Objective-C API Client](https://github.com/SuperSaaS/supersaas-objc-api-client)
+ [Go API Client](https://github.com/SuperSaaS/supersaas-go-api-client)

Contact: [support@supersaas.com](mailto:support@supersaas.com)

## Releases

The package follows [semantic versioning](https://semver.org/), i.e. MAJOR.MINOR.PATCH 

## License

The SuperSaaS Ruby API Client is available under the MIT license. See the LICENSE file for more info.
