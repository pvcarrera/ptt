module PTT
  # Public: channel for MemoryClient. Currently it does nothing useful and
  # basically implements the null-object pattern. But it necessary to keep
  # that class because Consumer depends on its `#ask` method.
  class MemoryChannel
    def ack(delivery_tag)
    end
  end
end
