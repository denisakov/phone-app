class UploadJob
    include SuckerPunch::Job
    #workers 10

    def perform(params)
        ActiveRecord::Base.connection_pool.with_connection do
            uploaded_io = params[:file]
            File.open(Rails.root.join('public', 'uploads', uploaded_io.original_filename), 'wb') do |file|
                file.write(uploaded_io.read)
            end
        end
    end
end