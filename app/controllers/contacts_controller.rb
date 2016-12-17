class ContactsController < ApplicationController
  
  require 'csv'
  def index
    #@contacts = Contact.limit(3)
    fileList = Dir.glob("#{Rails.root}/public/uploads/*.csv")
    @files = processFileList(fileList)
  end
  
  def search
    @contacts = Contact.search(params[:search])
  end
  
  def processFileList(fileList)
    files = []
    fileList.each do |fileName|
      files << fileName.split("/").last
    end
    return files
  end
  
  def process_file
    begin
      #@myfile = Dir.glob("#{Rails.root}/public/uploads/*.csv" + params[:file])
      #@rowarray = CSV.read("#{Rails.root}/public/uploads/" + params[:file])[0,2]
      @rowarray = []
      File.open("#{Rails.root}/public/uploads/" + params[:file], "r") do |file|
        csv = CSV.new(file, headers: false)
        @rowarray << csv.first
        @rowarray << csv.first
        #puts @rowarray.to_a
      end
      #@len = %x{sed -n '=' "#{Rails.root}/public/uploads/#{params[:file]}" | wc -l}.to_i
      #puts @len
      @filePath = "#{Rails.root}/public/uploads/" + params[:file]
      #puts @rowarray[1]
    rescue
      redirect_to root_url, notice: "Invalid CSV file format."
    end
  end
  
  def save_list
    begin
      list = List.where(title: params[:title]).first || List.create!(title: params[:title])
      column = params[:column].to_i
      headerRow = params[:headerRow]
      filePath = params[:filePath]
      #len = params[:len]
      UltimateWorker.perform_async(column, headerRow, filePath, list.id)
      #UltimateJob.perform_async(column, headerRow, filePath, list.id)
      redirect_to root_url, notice: "File is being filtered of duplicates and will be available shortly."
      #counts = Contact.saveAll(params,list)
      #puts counts
      #redirect_to root_url, notice: counts[0].to_s + ' records were added. There were ' + counts[1].to_s + ' double records found. Also there were '+ counts[2].to_s + ' records, where phone numbers were not recognized.'
    rescue
      redirect_to root_url, notice: "Something went wrong."
    end
  end
  
  def load_to_drive
    # uploaded_io = params[:file]
    # File.open(Rails.root.join('public', 'uploads', uploaded_io.original_filename), 'wb') do |file|
    #   file.write(uploaded_io.read)
    # end
    redirect_to root_url, notice: "File has been uploaded."
    UploadJob.perform_async(params)
    
  end
  

  def create_list
    @contacts = Contact.where(list_id: params[:listId]).limit(params[:sampleSize])
    @list = List.where(id: params[:listId]).first.title
    @listId = params[:listId]
    @sampleSize = params[:sampleSize]
    @filename = "phone list_#{@list}_#{params[:sampleSize]} items.csv"
    #render create_list_contacts_path
  end
  
  def download
    begin
      @contacts = Contact.where(list_id: params[:listId]).limit(params[:sampleSize])
      #puts @contacts
      respond_to do |format|
        format.html 
        format.csv {send_data @contacts.to_csv, filename: params[:file], disposition: 'attachment'}
      end
      #puts @contacts.to_csv
    rescue
      redirect_to root_url, notice: "Something went wrong."
    end
  end # end dowload
  
  def destroy
    @contact.destroy
    #DeleteWorker.perform_async(@list.id)
    #DeleteListJob.perform_async(@list.id)
    respond_to do |format|
      format.html { redirect_to contacts_url, notice: 'Contact was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

end