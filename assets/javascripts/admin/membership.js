$(document).ready(function(){
	bind_member_dialog("#new_member_button");
	bind_members("#members li");	
});


// Page Dialogs
var member_dialog = {
	open: function(dialog, link) {
		dialog.overlay.fadeIn('normal')
    dialog.container.slideDown('normal');

		$.ajax({
				url: $(link).attr("href"),
				type: 'get',
				cache: false,
				dataType: 'html',
				success: function (html) {
				  dialog.data.html('<div class="content" >' + html + '</div>').fadeIn(200);
					dialog.data.find('.close').click(function () { $.modal.close();return false; });
					
					// Add Ajax Submit
					dialog.data.find('form').submit(function(){
						$.post($(this).attr("action") + ".js", $(this).serialize(), null, "script");
						return false;
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

// var member_dialog = {
//  display: function(dialog, link, xhr) {
// 
//    dialog.data.find('.loading').fadeOut(150, function() {
// 
//      dialog.data.html('<div class="content" style="display:none;">' + xhr.responseText + '</div>');
//    
//      dialog.data.find('.close').click(function () { $.modal.close();return false; });
//    
//      // Add Ajax Submit
//      dialog.data.find('form').submit(function(){
//        $.post($(this).attr("action") + ".js", $(this).serialize(), null, "script");
//        return false;
//      });
//              
//      dialog.data.find('.content').fadeIn(500);
//    });
//  },
//  open: function(dialog, link) {
//    dialog.overlay.fadeIn('normal')
//     dialog.container.slideDown('normal');
//    dialog.data.html('<div class="loading"></div>').show();
//    member_dialog = this
//    $.ajax({
//        url: $(link).attr("href"),
//        type: 'get',
//        cache: false,
//        dataType: 'html',
//        complete: function (xhr) {
//          member_dialog.display(dialog, link, xhr);
//        }
//    });
//  },
//  show: function(dialog) {
//  },
//  close: function(dialog) {
//    dialog.overlay.fadeOut('normal')
//    dialog.data.fadeOut('normal'); 
//     dialog.container.slideUp('normal', function() {$.modal.close();})
//  }
// }

function bind_member_dialog(selector) {
	$(selector).click(function() {
		var link = $(this);
		$("#member_dialog").modal({
			onOpen: function(dialog){ member_dialog.open(dialog, link)	},
			onClose: member_dialog.close,		  
			onShow: member_dialog.show
		});
		return false
	});
}

function bind_members(member) {

	// Bind Edit
	bind_member_dialog($(member).find(".edit"));

	// Bind Delete
	$(member).find('.delete').click(function() {
		if (confirm("Are you sure you want to DELETE the MEMBER: \""+$(this).parents("li").find(".name").html()+"?\"")) {
			$.post($(this).attr("href") + ".js", "_method=delete&authenticity_token="+form_authenticity_token, null, "script");
		}
		return false
	})
}


