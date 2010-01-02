$(document).ready(function(){
	bind_asset_dialog("#upload_asset_button");
	bind_asset_dialog("#new_folder_button");
	bind_asset_delete(".assets .delete")
});


// Page Dialogs
var asset_dialog = {
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
						dialog.data.find('.close').click(function () { $.modal.close();return false; });
						dialog.data.find('ul.tags li').click(function() {$(this).toggleClass("use")});
				
						// Create Upload iframe
						dialog.container.append('<iframe id="upload_frame" name="upload_frame" style="display:none;"/>'); 
						dialog.data.find('form').attr("target", "upload_frame").attr("action", function() { return $(this).attr("action") });
						dialog.data.find('form').submit(function(){
							$("#upload_frame").load(function() {
								document.location.reload();
							})
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

function bind_asset_dialog(selector) {
	$(selector).click(function() {
		var link = $(this);
		$("#asset_dialog").modal({
			onOpen: function(dialog){ asset_dialog.open(dialog, link)	},
			onClose: asset_dialog.close,		  
			onShow: asset_dialog.show,
			containerId: "modalContainerAsset"
		});
		return false
	});
}

function bind_asset_delete(selector) {
	$(selector).click(function() {
		if (confirm("Are you sure you want to delete asset: '"+$(this).prev("a").text()+"'")) {
			$(this).parents("li").addClass("destroy_asset");
			$.post($(this).attr('href') + ".js", {_method:"delete"}, null, "script");
		}
		return false;
	})
}