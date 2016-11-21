require 'ptt/amqp_client'
require 'ptt/consumer'
require 'ptt/publisher'
require 'ptt/version'

module PTT
  extend self

  attr_writer :client
  attr_writer :publisher

  def configure
    yield(self) if block_given?
  end

  def connect
    client.connect

    handlers.each do |(routing_key, handler)|
      subscribe(routing_key, handler)
    end
  end

  def disconnect
    client.disconnect
  end

  def register_handler(routing_key, handler)
    handlers[routing_key] = handler

    subscribe(routing_key, handler) if client.connected?
  end

  def handler_for(routing_key)
    handlers[routing_key]
  end

  def publish(routing_key, data)
    publisher.publish(routing_key, data)
  end

  private

  def client
    @client ||= AMQPClient.new
  end

  def publisher
    @publisher ||= Publisher.new(client.exchange)
  end

  def consumers
    @consumers ||= Hash.new do |repository, routing_key|
      repository[routing_key] = Consumer.new(
        client.channel,
        client.queue_for(routing_key)
      )
    end
  end

  def subscribe(routing_key, handler)
    consumers[routing_key].subscribe(handler)
  end

  def handlers
    @handlers ||= {}
  end
end
