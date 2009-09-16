$(document).ready(function(){
	bind_admin_user_dialog("#new_admin_user_button");
	bind_admin_users("#admin_users li");
	
});

var current_dialog;
// Page Dialogs
var admin_user_dialog = {
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
					
						dialog.data.html('<div class="content" style="display:none;">' + html + '</div>');
						dialog.data.find('.close').click(function () { current_dialog.close(); return false; });
						dialog.data.find('ul.roles li').click(function() {$(this).toggleClass("use")});

					
						dialog.data.find('.select_file')
							.click(function() {
								current_dialog.toggleLeftTray();
								if (current_dialog.dialog.leftTray && current_dialog.dialog.leftTray.find(".trayDialog #admin_user_photo_form").length == 0)
								{
									current_dialog.dialog.leftTray.find('.loading').remove()
									photo_form = $($("#admin_user_photo_form_template").clone()).attr("id", "admin_user_photo_form")
									current_dialog.dialog.leftTray.find(".trayDialog").append(photo_form);
									current_dialog.dialog.leftTray.find("a.close").click(function() {
										current_dialog.closeLeftTray();
									});
								}
							});
					
						// Add Ajax Submit
						dialog.data.find('form').submit(function(){
							$.post($(this).attr("action") + ".js", $(this).serialize(), null, "script");
							return false;
						});
						
						dialog.data.find('.content').fadeIn(500);
					});
					
				}
		});
	},
	show: function(dialog) {
	},
	close: function(dialog) {
		dialog.overlay.fadeOut('normal')
		dialog.data.fadeOut('normal'); 
    dialog.container.slideUp('normal', function() {$.modal.close();})
	}
}

function bind_admin_user_dialog(selector) {
	$(selector).click(function() {
		var link = $(this);
		current_dialog = $("#admin_user_dialog").modal({
			onOpen: function(dialog){ admin_user_dialog.open(dialog, link)	},
			onClose: admin_user_dialog.close,		  
			onShow: admin_user_dialog.show
		});
		return false
	});
}

function bind_admin_users(admin_user) {
	// Bind Edit
	bind_admin_user_dialog($(admin_user).find(".edit"));

	// Bind Delete
	$(admin_user).find('.delete').click(function() {
		if (confirm("Are you sure you want to delete this admin user: "+$(this).parents("li").find('.name').html()+"?")) {
			params = {"_method":"delete", "authenticity_token":form_authenticity_token}
			$.post($(this).attr("href") + ".js", params, null, "script");
			return false;
		}
		return false;
	})
}


