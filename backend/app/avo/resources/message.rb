class Avo::Resources::Message < Avo::BaseResource
  self.title = :role
  self.includes = [ :conversation ]
  self.default_sort_column = :created_at

  self.search = {
    query: -> {
      query.where("LOWER(content) LIKE :term", term: "%#{params[:q].to_s.downcase}%")
    }
  }

  def fields
    field :id, as: :id
    field :role, as: :select, options: Message.roles.keys.index_by(&:humanize)
    field :content, as: :textarea
    field :conversation, as: :belongs_to
    field :created_at, as: :date_time, readonly: true, sortable: true
  end
end
