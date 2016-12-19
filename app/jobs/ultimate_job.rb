class UltimateJob
  
  include SuckerPunch::Job
  require 'csv'
  def perform(column, headerRow,filePath, listId)
           @doubleCount = 0
            @newCount = 0
            @notNumber = 0
            contactsNew = []
            contactsNewCheck = {}
            @len = count(filePath)
            options = {:encoding => 'UTF-8', :skip_blanks => true}
            CSV.foreach(filePath, options).with_index do |row, i|
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
                            if headerRow === "Yes" && !row[index].nil? && !cell.nil?
                                @extraStr = @extraStr + row[index] + ": " + cell  + "; "
                            elsif !row[index].nil? && !cell.nil?
                                @extraStr = @extraStr + cell  + "; "
                            else
                                @extraStr = @extraStr + "; "
                            end
                        end
                    end # end row.each_with_index
                    #puts @extraStr
                    #contactInsideNewList = contactsNew.index @phoneNo
                    #contactInsideNewList = contactsNew.select {|x| x["phone"] == @phoneNo }
                    if @phoneNo == '23'
                        next
                    else
                        if Contact.exists?(phone: @phoneNo) || contactsNewCheck.has_key?(@phoneNo) #!contactInsideNewList.empty?
                            @doubleCount = @doubleCount + 1
                            next
                        else
                            @newCount = @newCount + 1
                            newContact = Contact.new({phone: @phoneNo, extra: @extraStr, list_id: listId})
                            contactsNewCheck[newContact.phone] = ""
                            contactsNew << newContact
                            if contactsNewCheck.count == 1000 || i == @len - 1
                                #puts contactsNew
                                Contact.import contactsNew
                                contactsNew.clear
                                contactsNewCheck.clear
                            end
                            #list.contacts.create!({phone: @phoneNo, extra: @extraStr, list_id: list.id})
                        end
                    end # end if !contact.nil?
                end #if
            end # end data.foreach
            File.delete(params[:filePath])
            list = ::List.where(id: listId).first
            if list.contacts.count === 0
                list.delete
            end
            #return @newCount,@doubleCount,@notNumber
            GC.start(full_mark: false, immediate_sweep: false)
  end
  def count(filePath)
    len = 0
    CSV.foreach(filePath).with_index do |row,z|
        len = z.to_i+1
    end
    return len
  end
end
