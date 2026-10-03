# The Vite dev server runs on another port, so the API has to opt into
# credentialed cross-origin requests for the session cookie to be sent.
Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins(*Rails.application.config.x.cors_origins)

    resource "*",
             headers: :any,
             methods: [ :get, :post, :patch, :put, :delete, :options, :head ],
             expose: [ "X-CSRF-Token" ],
             credentials: true
  end
end
