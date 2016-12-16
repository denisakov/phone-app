class DeleteWorker
  include Sidekiq::Worker

  def perform(list)
    list.destroy
  end
end
