$(document).ready(function(){
	bind_verbiage_dialog(".admin_content .tools .edit_verbiage");
	bind_verbiage_dialog("#blue_toolbar .blue_context_toolbar .edit_verbiage");
	bind_verbiage_field_dialog(".edit_verbiage_field")
});


var wymeditor_config = {};
var verbiage_updated_callback = function() {};

// Page Dialogs
var verbiage_dialog = {
	open: function(dialog, link) {
	  dialog.link = link;
		dialog.overlay.fadeIn('normal')
    dialog.container.slideDown('normal');
		dialog.data.html('<div class="loading"></div>').show();	  
	},
	show: function(dialog, options) {
	  var url = $(dialog.link).attr("href");
	  options = $.extend({content_loaded_callback : function(){}, editor_loaded_callback : function(){}, complete_callback : function(){},
	  form_submit_callback : function(dialog, form) {
	    $.post($(form).attr("action") + ".js", $(form).serialize(), null, "script");
	    return false;
	  }}, options)
	  var locale = options.locale
	  if (options.locale != null) {
	    console.log(url)
	    if (url.indexOf("?") > 0) {
	      url += "&verbiage[locale]="+options.locale
	    } else {
	      url += "?verbiage[locale]="+options.locale
	    }
	  }
	  	$.ajax({
  				url: url,
  				type: 'get',
  				cache: false,
  				dataType: 'html',
  				success: function (html) {
  					dialog.data.find('.loading').fadeOut(150, function() {

  						// Replace asset images with their thumbnails
  						//html = html.replace(/src=&quot;\/assets\/images\/([^\.])/gi, 'src=&quot;/assets/images/.thumbnails/$1');
  						//html = html.replace(/src=&quot;(.*)\/assets\/images\/([^\.].*)&quot;/gi, 'src=&quot;$1/assets/images/.thumbnails/$2&quot;');
  						//html = html.replace(/src="(.*)\/assets\/images\/([^\.].*)"/gi, 'src="$1/assets/images/.thumbnails/$2"');
  				    html = html.replace(/assets\/images/gi, "assets/images/.thumbnails").replace(/\.thumbnails\/\.thumbnails/gi, "/.thumbnails")
  						dialog.data.html('<div class="content">' + html + '</div>');

  						dialog.data.find('.close').click(function () { $.modal.close(); return false; });

  						// Add Change Locales
  						if (options.locale != null) {
  						  dialog.data.find("#verbiage_locale").val(options.locale)
					    }
  						
  						dialog.data.find("#verbiage_locale").change(function(){
  						  dialog.data.html('<div class="loading"></div>').show();
  						  verbiage_dialog.show(dialog, $.extend(options, {locale : $(this).val()}) );
  						});

              options.content_loaded_callback(dialog);
              
  						$('.wymeditor').wymeditor($.extend({}, {
  						    jQueryPath:"/javascripts/blue/jquery.js",
  								toolsItems: [
  							    {'name': 'Bold', 'title': 'Strong', 'css': 'wym_tools_strong'}, 
  							    {'name': 'Italic', 'title': 'Emphasis', 'css': 'wym_tools_emphasis'},
  							    {'name': 'Superscript', 'title': 'Superscript', 'css': 'wym_tools_superscript'},
  							    {'name': 'Subscript', 'title': 'Subscript', 'css': 'wym_tools_subscript'},
  							    {'name': 'InsertOrderedList', 'title': 'Ordered_List', 'css': 'wym_tools_ordered_list'},
  							    {'name': 'InsertUnorderedList', 'title': 'Unordered_List', 'css': 'wym_tools_unordered_list'},
  							    {'name': 'Indent', 'title': 'Indent', 'css': 'wym_tools_indent'},
  							    {'name': 'Outdent', 'title': 'Outdent', 'css': 'wym_tools_outdent'},
  							    {'name': 'Undo', 'title': 'Undo', 'css': 'wym_tools_undo'},
  							    {'name': 'Redo', 'title': 'Redo', 'css': 'wym_tools_redo'},
  							    {'name': 'Unlink', 'title': 'Unlink', 'css': 'wym_tools_unlink'},
  							    {'name': 'InsertTable', 'title': 'Table', 'css': 'wym_tools_table'},
  							    {'name': 'Paste', 'title': 'Paste_From_Word', 'css': 'wym_tools_paste'},
  							    {'name': 'ToggleHtml', 'title': 'HTML', 'css': 'wym_tools_html'}
  							  ],
  								containersItems: [
  						        {'name': 'P', 'title': 'Paragraph', 'css': 'wym_containers_p'},
  						        {'name': 'H1', 'title': 'Heading_1', 'css': 'wym_containers_h1'},
  						        {'name': 'H2', 'title': 'Heading_2', 'css': 'wym_containers_h2'},
  						        {'name': 'H3', 'title': 'Heading_3', 'css': 'wym_containers_h3'}
  						    ],
  								stylesheet: "/stylesheets/editor.css",
  							 	boxHtml:   "<div class='wym_box'>"
  						              + "<div class='wym_area_top'>" 
  						              + WYMeditor.TOOLS
  						              + WYMeditor.CLASSES
  						              + WYMeditor.CONTAINERS
  						              + "</div>"
  						              + "<div class='wym_area_left'></div>"
  						              + "<div class='wym_area_right'></div>"
  						              + "<div class='wym_area_main'>"
  						              + WYMeditor.HTML
  						              + WYMeditor.IFRAME
  						              + WYMeditor.STATUS
  						              + "</div>"
  						              + "<div class='wym_area_bottom'>"
  						              + "</div>"
  						              + "</div>",
  						 postInit: function(wym) {
  						    var blue_image_dialog = wym.blue_image_dialog({current_dialog: current_dialog});
  						    blue_image_dialog.init();
  						    var blue_link_dialog = wym.blue_link_dialog({current_dialog: current_dialog});
  						    blue_link_dialog.init();
  								var page_verbiage_comments_dialog = blue_page_verbiage_comments_dialog({current_dialog: current_dialog});
  						  	page_verbiage_comments_dialog.init();
  							},
  							postInitDialog: function() {

  								dialog.data.find('.content').fadeIn(500);
  							}

  						}, wymeditor_config));

              
              options.editor_loaded_callback(dialog);

  						// Add Ajax Submit
  						dialog.data.find('form').submit(function(){
                
  							var editor = $(".wymeditor, .tinymce");

  							// Make absolute paths that point to our server relative
  							html = editor.val()

  							var re = new RegExp('(src|href)="?https?:\/\/' + document.location.host + '([^"]+)', 'gi');
  							html = html.replace(re, '$1=\"$2')

  							// Replace asset thumbnails with their full images
  							html = html.replace(/src="([^"]*)\/\.thumbnails\/([^"]*)"/gi, 'src="$1/$2"');

  							editor.val(html);
  							options.form_submit_callback(dialog, this);

    			      return false;
  						});

              options.complete_callback(dialog);

  					});

  				}
  		});
	},
	close: function(dialog) {
		dialog.overlay.fadeOut('normal');
		current_dialog.closeLeftTray();
		dialog.data.fadeOut('normal'); 
    dialog.container.slideUp('normal', function() {$.modal.close();})
	}
}

var current_dialog;
function bind_verbiage_dialog(selector) {

	if ($("#verbiage_dialog").length == 0) {
		$("body").append('<div id="verbiage_dialog" class="dialog"></div>');
	}
	
	var unbound_selectors = $(selector).filter(function(){  return !($(this).attr("verbiage_dialog_bound") == "true") })

	$(unbound_selectors).attr("verbiage_dialog_bound", "true")
	$(unbound_selectors).click(function() {
		var link = $(this);
		current_dialog = $("#verbiage_dialog").modal({
			onOpen: function(dialog){ verbiage_dialog.open(dialog, link)	},
			onClose: verbiage_dialog.close,		  
			onShow: verbiage_dialog.show
		});
		return false
	});
}

function bind_verbiage_field_dialog(selector) {
	if ($("#verbiage_dialog").length == 0) {
		$("body").append('<div id="verbiage_dialog" class="dialog"></div>');
	}
	
	var unbound_selectors = $(selector).filter(function(){  return !($(this).attr("verbiage_dialog_bound") == "true") })

	$(unbound_selectors).attr("verbiage_dialog_bound", "true")
	$(unbound_selectors).click(function() {
		var link = $(this);
		var field_id = link.attr("id").replace("edit_verbiage_field_", "");
		current_dialog = $("#verbiage_dialog").modal({
			onOpen: function(dialog){ verbiage_dialog.open(dialog, link)	},
			onClose: verbiage_dialog.close,		  
			onShow: function(dialog) {
			  verbiage_dialog.show(dialog, {
			    content_loaded_callback : function(dialog) {
			      var locale = dialog.data.find("#verbiage_locale").val();
						if (locale) {
						  textarea = $("#"+field_id+"_"+locale);
						} else {
			        textarea = $("textarea[id^='"+field_id+"']").get(0);
			      }
			      dialog.data.find("#verbiage_content").val($(textarea).val());
			    },
			    form_submit_callback : function (dialog, form) {
			      var locale = dialog.data.find("#verbiage_locale").val();
						if (locale) {
						  textarea = $("#"+field_id+"_"+locale);
						} else {
			        textarea = $($("textarea[id^='"+field_id+"']").get(0));
			      }
			      var content = dialog.data.find("#verbiage_content").val();
  			    preview = $("#"+field_id+"_content");
  			  
			      textarea.val(content);
			      preview.html(content);
			      $.modal.close();
			      return false;
			    },
			    complete_callback : function(dialog) {
		      	dialog.data.find("#verbiage_locale").val()
			    }
			  })
			}
		});
		return false
	});
}

blue_page_verbiage_comments_dialog = function(options) {
  var blue_page_verbiage_comments_dialog = new BluePageVerbiageCommentsDialog(options);
  return(blue_page_verbiage_comments_dialog);
};

//WymTidy constructor
function BluePageVerbiageCommentsDialog(options) {
	this._options = options;
};

//WymTidy initialization
BluePageVerbiageCommentsDialog.prototype.init = function() {

  var blue_page_verbiage_comments_dialog = this;
  
  //handle click event
  jQuery("#view_page_verbiage_comments_button").click(function() {
    blue_page_verbiage_comments_dialog.open($(this).attr('href'));
    return(false);
  });

};


BluePageVerbiageCommentsDialog.prototype.open = function(path) {

	var current_dialog = this._options.current_dialog;

	if (current_dialog.toggleRightTray())
	{

		var tray_dialog = current_dialog.dialog.rightTray.find(".trayDialog .content");
		var tray_loading = current_dialog.dialog.rightTray.find(".trayDialog .loading");

		tray_dialog.hide();
		tray_loading.show();	

		$.get(path, {}, function(data) {

			tray_dialog.html(data);
			
			tray_dialog.find("form").submit(function(){
				
				$.post($(this).attr("action"), $(this).serialize(), function(data){
					$("#comments").append(data);
				});
				
				return false;
			});

			tray_loading.fadeOut(150, function() {
			tray_dialog.fadeIn(150);
			});
		});
	}
};
