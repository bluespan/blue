class Admin::CommentsController < Admin::BlueAdminController
  
  before_filter :find_models
  
  def index
    @comment = Comment.new
    
    case @commentable.class.to_s
    when "Verbiage"
      render :template => "admin/comments/index.content.html.erb", :layout => false
    when "Page"
      render :template => "admin/comments/index.page.html.erb", :layout => false
    else

    end
  end
  
  def new
    @comment = Comment.new
  end
  
  def create
    respond_to do |wants|
      if @comment = Comment.create(params[:comment].merge({:admin_user_id => current_admin_user.id}))
        @commentable.add_comment(@comment)
        
        # Notifications
        unless params[:notify_users].nil?
          AdminUser.find(params[:notify_users]).each do |user|
            @comment.notify_user(user)
          end
        end
        
        flash.now[:notice] = "Your comment <em>#{@comment.title}</em> on <em>#{@comment.commentable_type.to_s.underscore.titleize} #{@commentable.title}</em> was successfully <em>added.</em>"
        wants.html { redirect_to :action => "index "}
        wants.js
      else
        wants.html { render :action => "new" }
        wants.js { render :template => "admin/error", :locals => {:object => @comment} }
      end
    end
  end
  
  private
  
  def find_models
    @commentable = Page.find(params[:page_id]) if params[:page_id]
    @commentable = Content.find(params[:verbiage_id]) if params[:verbiage_id]
  end
  
  
end
