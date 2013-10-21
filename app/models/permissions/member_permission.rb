module Permissions
  class MemberPermission < BasePermission
    def initialize(user)
      allow_all
      #allow :users, [:new, :create]
      #allow :sessions, [:new, :create, :destroy]
      #allow :topics, [:index, :show]
    end
  end
end