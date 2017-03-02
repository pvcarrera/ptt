module PTT
  # Public: A "subscribe to everything" queue.
  # See `NullClient` for more details.
  class NullQueue
    def subscribe(options, &handler)
    end
  end
end
