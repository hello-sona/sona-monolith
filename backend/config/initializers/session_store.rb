# SameSite=Lax is enough because the UI and API share the localhost site in
# development and are expected to share a site in production.
Rails.application.config.session_store :cookie_store,
                                       key: "_sona_session",
                                       same_site: :lax,
                                       secure: Rails.env.production?
