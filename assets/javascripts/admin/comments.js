$(document).ready(function(){
	$("body").append('<div class="dialog" id="admin_comment_dialog"></div>');
	bind_comment_dialog("a.view_comments");
	
	//$("#comments .iehover").hoverfix();
});

// Comments Dialogs
var comment_dialog = {
	open: function(dialog, link) {
		dialog.overlay.fadeIn('normal')
    dialog.container.slideDown('normal');
		dialog.data.html('<div class="loading"></div>').show();
		
		$.ajax({
				url: $(link).attr("href"),
				type: 'get',
				cache: false,
				dataType: 'html',
				complete: function (xhr) {
					dialog.data.find('.loading').fadeOut(150, function() {
					
						dialog.data.html('<div class="content" style="display:none;">' + xhr.responseText + '</div>');
					
						dialog.data.find('.close').click(function () { $.modal.close();return false; });

						// Add Notifcation Functionality
						dialog.data.find('#post_comment').click(function(){
							if ($("#comment_comment").val() != "")
							{
								$("#comment_form").hide();
								$("#notify_form").show();
							}
							return false;
						});
						
						$("#notify_all_users").click(function() {
							if ($(this).is(":checked")) {
								$(".users .user input").attr("checked", 1);
							} else {
								$(".users .user input").attr("checked", 0);
							}
						});
						
						$(".users .user input").click(function() {
							$("#notify_all_users").attr("checked", 0);
						})

						// Add Ajax Submit
						dialog.data.find('form').submit(function(){
							if ($("#comment_comment").val() != "")
							{
								$.post($(this).attr("action"), $(this).serialize(), function(data) {
									//$(".comments").append(data)
									li = $(".comments li:last")
									li.hide();
									li.fadeIn();
									$("#no_comments").hide();
									$(".dialog").scrollTo(li);
									
									$("#comment_form").show();
									$("#notify_form").hide();
								});
							}
							
							$("#comment_comment").val("");
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

function bind_comment_dialog(selector) {
	$(selector).click(function() {
		var link = $(this);
		$("#admin_comment_dialog").modal({
			onOpen: function(dialog){ comment_dialog.open(dialog, link)	},
			onClose: comment_dialog.close,		  
			onShow: comment_dialog.show,
			containerId: "modalContainerComments"
		});
		return false
	});
	
}


