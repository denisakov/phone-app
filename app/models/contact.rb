class Contact < ApplicationRecord
    require 'csv'
    
    belongs_to :list
    accepts_nested_attributes_for :list
    
    def self.to_csv
        attr = %w{phone}
        CSV.generate(headers: true) do |csv|
            csv << attr
            all.each do |contact|
                csv << contact.attributes.values_at(*attr)
            end
        end
    end # end self.to_csv
    
    def self.saveAll(params, list)
        SaveListJob.perform_async(params, list)
    end # end saveAll(params, list)
    
    def self.search(search)
      if search
        sanitizedSearch = search.gsub(/\D/, '')  
        where('phone LIKE ?', "%#{sanitizedSearch}%")
      else
        
      end
    end
    
end # end class