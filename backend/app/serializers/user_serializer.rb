module UserSerializer
  def self.call(user)
    {
      id: user.id,
      email: user.email,
      display_name: user.display_name
    }
  end
end
