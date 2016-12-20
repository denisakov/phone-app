class ContactsController < ApplicationController
  
  require 'csv'
  def index
    fileList = Dir.glob("#{Rails.root}/public/uploads/*.csv")
    @files = processFileList(fileList)
    @busy = checkProcessing()
  end
  
  def checkProcessing()
    processingFileList = Dir.glob("#{Rails.root}/public/uploads/processing/*.csv")
    if processingFileList.empty?
      return true
    else
      return false
    end
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
    #begin
      @rowarray = []
      File.open("#{Rails.root}/public/uploads/" + params[:file], "r") do |file|
        csv = CSV.new(file, headers: false)
        @rowarray << csv.first
        @rowarray << csv.first
        #puts @rowarray.to_a
        File.open(Rails.root.join('public', 'uploads', 'processing', params[:file]), 'wb') do |newFile|
          newFile.write(file.read)
        end
      end
      File.delete("#{Rails.root}/public/uploads/" + params[:file])
      @filePath = "#{Rails.root}/public/uploads/processing/" + params[:file]
    #rescue
      #redirect_to root_url, notice: "Invalid CSV file format."
    #end
  end
  
  def save_list
    begin
      list = List.where(title: params[:title]).first || List.create!(title: params[:title])
      column = params[:column].to_i
      headerRow = params[:headerRow]
      filePath = params[:filePath]
      UltimateJob.perform_async(column, headerRow, filePath, list.id)
      redirect_to root_url, notice: "File is being filtered of duplicates and will be available shortly."
    rescue
      redirect_to root_url, notice: "Something went wrong."
    end
  end
  
  def load_to_drive
    redirect_to root_url, notice: "File has been uploaded."
    UploadJob.new.perform(params)
    
  end

  def create_list
    @contacts = Contact.where(list_id: params[:listId]).limit(params[:sampleSize])
    @list = List.where(id: params[:listId]).first.title
    @listId = params[:listId]
    @sampleSize = params[:sampleSize]
    @filename = "phone list_#{@list}_#{params[:sampleSize]} items.csv"
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
    respond_to do |format|
      format.html { redirect_to contacts_url, notice: 'Contact was successfully destroyed.' }
      format.json { head :no_content }
    end
  end
end