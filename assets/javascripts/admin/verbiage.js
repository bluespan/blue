$(document).ready(function(){
	bind_verbiage_dialog(".admin_content .tools .edit");
	bind_verbiage_dialog("#blue_toolbar .blue_context_toolbar .edit_verbiage");
});

// Page Dialogs
var verbiage_dialog = {
	open: function(dialog, link) {
		dialog.overlay.fadeIn('normal')
    dialog.container.slideDown('normal');
		dialog.data.html('<div class="loading"></div>').show();

		$.ajax({
				url: $(link).attr("href"),
				type: 'get',
				cache: false,
				dataType: 'html',
				success: function (html) {
					
					dialog.data.find('.loading').fadeOut(150, function() {
						dialog.data.html('<div class="content">' + html + '</div>');
						
						dialog.data.find('.close').click(function () { $.modal.close(); return false; });
										
						$('.wymeditor').wymeditor({
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
							    {'name': 'ToggleHtml', 'title': 'HTML', 'css': 'wym_tools_html'},
							    {'name': 'Preview', 'title': 'Preview', 'css': 'wym_tools_preview'}
							  ],
								containersItems: [
						        {'name': 'P', 'title': 'Paragraph', 'css': 'wym_containers_p'},
						        {'name': 'H2', 'title': 'Heading_2', 'css': 'wym_containers_h2'},
						        {'name': 'H3', 'title': 'Heading_3', 'css': 'wym_containers_h3'}
						    ],
							 	boxHtml:   "<div class='wym_box'>"
						              + "<div class='wym_area_top'>" 
						              + WYMeditor.TOOLS
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
		
						});
			
						// Add Ajax Submit
						dialog.data.find('form').submit(function(){
							$.post($(this).attr("action") + ".js", $(this).serialize(), null, "script");
							return false;
						});
						
						
					});
					
				}
		});
	},
	show: function(dialog) {
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
	
	$(selector).click(function() {
		var link = $(this);
		current_dialog = $("#verbiage_dialog").modal({
			onOpen: function(dialog){ verbiage_dialog.open(dialog, link)	},
			onClose: verbiage_dialog.close,		  
			onShow: verbiage_dialog.show
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