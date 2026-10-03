class Avo::Resources::Conversation < Avo::BaseResource
  self.title = :title
  self.includes = [ :user ]
  self.default_sort_column = :updated_at

  self.search = {
    query: -> {
      term = "%#{params[:q].to_s.downcase}%"
      query.joins(:user)
           .where("LOWER(conversations.title) LIKE :term OR LOWER(users.email) LIKE :term",
                  term: term)
    }
  }

  def fields
    field :id, as: :id
    field :title, as: :text, sortable: true
    field :user, as: :belongs_to
    field :created_at, as: :date_time, readonly: true, only_on: :show
    field :updated_at, as: :date_time, readonly: true, sortable: true

    field :messages, as: :has_many
  end
end
