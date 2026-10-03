class Avo::Resources::User < Avo::BaseResource
  self.title = :email
  self.default_sort_column = :email
  self.default_sort_direction = :asc

  # LOWER(...) LIKE keeps search working on both Postgres and SQLite.
  self.search = {
    query: -> {
      term = "%#{params[:q].to_s.downcase}%"
      query.where("LOWER(email) LIKE :term OR LOWER(display_name) LIKE :term", term: term)
    }
  }

  def fields
    field :id, as: :id
    field :email, as: :text, sortable: true
    field :display_name, as: :text, sortable: true
    field :password, as: :password, only_on: :forms,
          help: "Leave blank to keep the current password."
    field :admin, as: :boolean, sortable: true
    field :active, as: :boolean, sortable: true
    field :google_sub, as: :text, readonly: true
    field :last_login_at, as: :date_time, readonly: true
    field :created_at, as: :date_time, readonly: true, only_on: :show

    field :conversations, as: :has_many
  end
end
