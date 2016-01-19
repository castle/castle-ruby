module Castle
  class Label < Model
    def self.destroy_all(*args)
      self.delete('/v1/labels', *args)
    end
  end
end
