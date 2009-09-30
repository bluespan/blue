# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20091001160904) do

  create_table "activity_log_entries", :force => true do |t|
    t.integer  "user_id"
    t.string   "object"
    t.integer  "object_id"
    t.string   "action"
    t.string   "description"
    t.datetime "created_at"
  end

  create_table "admin_user_roles", :force => true do |t|
    t.string  "name"
    t.boolean "publish",           :default => false
    t.boolean "admin_content",     :default => false
    t.boolean "admin_assets",      :default => false
    t.boolean "admin_admin_users", :default => false
    t.boolean "comment",           :default => false
    t.boolean "admin_membership",  :default => false
  end

  create_table "admin_users", :force => true do |t|
    t.string   "firstname"
    t.string   "lastname"
    t.string   "photo_file_name"
    t.string   "photo_content_type"
    t.integer  "photo_file_size"
    t.datetime "photo_updated_at"
    t.string   "login"
    t.string   "email"
    t.string   "crypted_password"
    t.string   "password_salt"
    t.string   "persistence_token"
    t.integer  "login_count"
    t.datetime "last_request_at"
    t.datetime "last_login_at"
    t.datetime "current_login_at"
    t.string   "last_login_ip"
    t.string   "current_login_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "assigned_admin_user_roles", :force => true do |t|
    t.integer "admin_user_id"
    t.integer "admin_user_role_id"
  end

  add_index "assigned_admin_user_roles", ["admin_user_id"], :name => "index_assigned_admin_user_roles_on_admin_user_id"

  create_table "comments", :force => true do |t|
    t.string   "title",            :limit => 50, :default => ""
    t.text     "comment",                        :default => ""
    t.integer  "commentable_id"
    t.string   "commentable_type"
    t.integer  "admin_user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "comments", ["admin_user_id"], :name => "index_comments_on_admin_user_id"
  add_index "comments", ["commentable_id"], :name => "index_comments_on_commentable_id"
  add_index "comments", ["commentable_type"], :name => "index_comments_on_commentable_type"

  create_table "content", :force => true do |t|
    t.integer  "contentable_id"
    t.string   "type"
    t.string   "title"
    t.text     "content"
    t.boolean  "published",        :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "contentable_type", :default => "Page"
  end

  create_table "members", :force => true do |t|
    t.string   "login"
    t.string   "crypted_password"
    t.string   "password_salt"
    t.string   "persistence_token"
    t.integer  "login_count"
    t.datetime "last_request_at"
    t.datetime "last_login_at"
    t.datetime "current_login_at"
    t.string   "last_login_ip"
    t.string   "current_login_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "navigations", :force => true do |t|
    t.string   "title"
    t.integer  "page_id"
    t.integer  "parent_id"
    t.integer  "lft"
    t.integer  "rgt"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "display",                 :default => true
    t.boolean  "display_to_members_only", :default => false
  end

  create_table "pages", :force => true do |t|
    t.string   "title"
    t.string   "slug"
    t.string   "template_file"
    t.string   "meta_description"
    t.string   "meta_keywords"
    t.integer  "working_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "type"
    t.string   "url"
    t.boolean  "members_only",     :default => false
    t.boolean  "open_new_window",  :default => false
    t.integer  "video_id"
  end

  add_index "pages", ["slug"], :name => "index_pages_on_slug"

  create_table "videos", :force => true do |t|
    t.string   "type"
    t.string   "title"
    t.text     "description"
    t.string   "url"
    t.string   "clip_id"
    t.text     "duration_in_seconds"
    t.string   "thumbnail"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
