# PTT - Pneumatic Tube Transport

PTT - messaging based on RabbitMQ and some conventions. It's built on top of [Bunny gem](http://rubygems.org/gems/bunny).

## Conventions

- Messages are JSON-encoded strings
- Consumers decode JSON payload and call message handlers
- Publisher uses **just** direct AMQP exchange (however it might change later)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'ptt'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install ptt

## Usage

First of all you should register message handlers. A handler object should
respond to `#call` method. When consumer receives a message from RabbitMQ, it
decodes JSON payload and passes decoded data to the designated handler using
`#call` method.

```ruby
# Message handler
class Handler
  def call(data)
    # process received data
    # ...
  end
end

# In this case `Handler#call` will be called each time when a new message comes
# from RabbitMQ with routing key `foo`
PTT.configure do |pneumatic_tube|
  pneumatic_tube.register_handler('foo', Handler.new)
end
```

When you need to send a message, just call `PTT.publish`. You have to provide
data and routing key. PTT publisher will encode data to JSON format and will
publish it to the exchange with given routing key.

```ruby
data = { foo: 'bar' }

# JSON encoded data will be send to exchange with `bar` routing key
PTT.publish('bar', data)
```

## Testing

    $ bundle exec rake

## Contributing

1. Fork it ( https://github.com/[my-github-username]/ptt/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

(c) 2017 [Alexander Sulim](http://sul.im)
