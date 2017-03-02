module PTT
  # Public: A "publish everything" exchange.
  # See `NullClient` for more details.
  class NullExchange
    def publish(data, options = {})
    end
  end
end
