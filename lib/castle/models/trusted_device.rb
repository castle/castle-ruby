module Castle
  class TrustedDevice < Model
    collection_path "users/:user_id/trusted_devices"
  end
end
