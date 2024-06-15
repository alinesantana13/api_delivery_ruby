Rails.application.config.middleware.insert_before 0, Rack::Cors do
    allow do
      origins 'http://localhost:5173', 'http://localhost:5174'
      resource '*', headers: :any, methods: [:get, :post, :patch, :put, :delete]
    end
end
