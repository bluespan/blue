module Admin::ContentHelper
  
  def email_verbiage(key, options = {}, &default_block)
    options = {}.merge(options)

    key = key.to_s
    default_content = block_given? ? capture(&default_block) : nil
    
    verbiage = EmailVerbiage[key]
    verbiage.update_attributes(:content => default_content) if (verbiage.new_record?)
    
    content = verbiage.content
    
    if options[:edit]
      content = "<textarea name='content[#{verbiage.id}][content]'>#{content}</textarea>"
    end
    
    concat content
  end
  
end
