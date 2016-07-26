module PTT
  # Public: A "publish everything" exchange.
  # See `NullClient` for more details.
  class NullExchange
    def publish(routing_key, data)
    end
  end
end
