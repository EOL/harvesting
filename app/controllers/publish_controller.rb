class PublishController < ApplicationController
  def new_traits 
    respond_to do |fmt|
      fmt.tsv do 
        send_data 'text', content_type: 'text/tab-separated-values'
      end
    end
  end

  def removed_traits
  end

  def new_metadata
  end
end
