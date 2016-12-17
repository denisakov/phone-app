class List < ApplicationRecord
    
    has_many :contacts, dependent: :delete_all
    
end
