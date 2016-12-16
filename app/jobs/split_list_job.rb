class SplitListJob
    require 'csv'
    include SuckerPunch::Job
    #workers 5

    def perform(params,list)
        ActiveRecord::Base.connection_pool.with_connection do
            column = params[:column].to_i
            headerRow = params[:headerRow]
            @doubleCount = 0
            @newCount = 0
            @notNumber = 0
            rawData = CSV.read(params[:filePath])
            arrayChunks = rawData.in_groups_of(1000,false)
            puts arrayChunks.count
            arrayChunks.each_with_index do |chunk,y|
                if y === 0
                    ImportWorker.perform_async(chunk,list.id,headerRow,column)
                    #SaveListJob.perform_async(chunk,list,headerRow,column)
                else
                    headerRow = "No"
                    ImportWorker.perform_async(chunk,list.id,headerRow,column)
                    #SaveListJob.perform_async(chunk,list,headerRow,column)
                end
            end #chunking
            File.delete(params[:filePath])
            #if List.where(id: list.id).first.contacts.count === 0
                #List.where(id: list.id).first.delete
            #end
            #return @newCount,@doubleCount,@notNumber
        end
    end
end