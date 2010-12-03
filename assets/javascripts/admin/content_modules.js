$(document).ready(function(){
  	bind_verbiage_dialog("#new_content_module_button")
	bind_content_modules("#content_modules li, .admin_placement .tools");
	bind_content_module_dialog("#blue_toolbar .blue_context_toolbar .edit_content_module");
	bind_content_module_dialog(".admin_content .tools .edit_content_module");
});



function bind_content_modules(content_module) {
	// Bind Edit Content Module Verbiage
	bind_verbiage_dialog($(content_module).find(".edit_verbiage"));
	
	// Bind Choose Content Module
	bind_content_module_dialog($(content_module).find(".choose_module"));
	
	// Bind Delete
	$(content_module).find('.delete').click(function() {
		if (confirm("Are you sure you want to DELETE the CONTENT MODULE: \""+$(this).parents(".content_module").find(".title").html()+"?\"")) {
			params = {"_method":"delete", "authenticity_token":form_authenticity_token} 
			$.post($(this).attr("href") + ".js", params, null, "script");
		}
		return false
	})
}



// Page Dialogs
var content_module_dialog = {
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
function bind_content_module_dialog(selector) {
	if ($("#content_module_dialog").length == 0) {
		$("body").append('<div id="content_module_dialog" class="dialog"></div>');
	}
	
	$(selector).click(function() {
		var link = $(this);
		current_dialog = $("#content_module_dialog").modal({
			onOpen: function(dialog){ content_module_dialog.open(dialog, link)	},
			onClose: content_module_dialog.close,		  
			onShow: content_module_dialog.show,
			containerId: "modalContainerContentPlacement"
		});
		return false
	});
}
