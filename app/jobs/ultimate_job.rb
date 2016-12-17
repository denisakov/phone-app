class UltimateJob
  
  include SuckerPunch::Job
  require 'csv'
  def perform(params, list)
            column = params[:column].to_i
            headerRow = params[:headerRow]
            @doubleCount = 0
            @newCount = 0
            @notNumber = 0
            data = CSV.read(params[:filePath])
            contactsNew = []
            data.each_with_index do |row,i|
                if headerRow === "Yes" && i === 0
                    puts row
                    next
                else
                    @extraStr = ''
                    row.each_with_index do |cell,index|
                        if index == column
                            if cell.nil?
                                @notNumber = @notNumber + 1
                                @phoneNo = '23'
                                next
                            else    
                                subStr = cell.gsub(/\D/, '')
                                if subStr.match(/[\d]{7}/).to_s.length != 0
                                    @phoneNo = subStr
                                else
                                    @notNumber = @notNumber + 1
                                    @phoneNo = '23'
                                    next
                                end
                            end
                        else
                            if headerRow === "Yes" && !data[0][index].nil? && !cell.nil?
                                @extraStr = @extraStr + data[0][index] + ": " + cell  + "; "
                            elsif !data[0][index].nil? && !cell.nil?
                                @extraStr = @extraStr + cell  + "; "
                            else
                                @extraStr = @extraStr + "; "
                            end
                        end
                    end # end row.each_with_index
                    #puts @extraStr
                    contact = Contact.where(phone: @phoneNo)
                    #contactInsideNewList = contactsNew.index @phoneNo
                    contactInsideNewList = contactsNew.select {|x| x["phone"] == @phoneNo }
                    if contact.count == 1 || !contactInsideNewList.empty?
                    #if !contactInsideNewList.empty?
                        @doubleCount = @doubleCount + 1
                        next
                    else
                        if @phoneNo == '23'
                            next
                        else
                            @newCount = @newCount + 1
                            contactsNew << Contact.new({phone: @phoneNo, extra: @extraStr, list_id: list.id})
                            if contactsNew.count == 1000
                                Contact.import contactsNew
                                contactsNew.clear
                            end
                            #list.contacts.create!({phone: @phoneNo, extra: @extraStr, list_id: list.id})
                        end
                    end # end if !contact.nil?
                end #if
            end # end data.foreach
            #Contact.import contactsNew
            #GC.start(full_mark: false, immediate_sweep: false)
            File.delete(params[:filePath])
            if List.where(id: list.id).first.contacts.count === 0
                List.where(id: list.id).first.delete
            end
            return @newCount,@doubleCount,@notNumber
  end
end
