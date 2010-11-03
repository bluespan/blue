//Extend WYMeditor
WYMeditor.editor.prototype.blue_link_dialog = function(options) {
  var blue_link_dialog = new BlueLinkDialog(options, this);
  return(blue_link_dialog);
};

//WymTidy constructor
function BlueLinkDialog(options, wym) {

  options = jQuery.extend({

    sButtonHtml:   "<li class='wym_tools_link'>"
                 + "<a name='CreateLink' href='#'>"
                 + "Link"
                 + "</a></li>",
    
    sButtonSelector: "li.wym_tools_link a"
    
  }, options);
  
  this._options = options;
  this._wym = wym;

};

//WymTidy initialization
BlueLinkDialog.prototype.init = function() {

  var blue_link_dialog = this;
            
  jQuery(this._wym._box).find('.wym_tools_unlink')
    .before(this._options.sButtonHtml);
  
  //handle click event
  jQuery(this._wym._box).find(this._options.sButtonSelector).click(function() {
    blue_link_dialog.open();
    return(false);
  });

};


BlueLinkDialog.prototype.open = function() {

	var current_dialog = this._options.current_dialog;
	var wym = this._wym;
	var path = "/admin/assets/link";
	var selected = wym.selected();
	

	var selectedPos = wym.selectedPosition();


	// Init Form Fields
	if(selected && selected.tagName && selected.tagName.toLowerCase != WYMeditor.A)
    selected = $(selected).parentsOrSelf(WYMeditor.A);

  //fix MSIE selection if link image has been clicked
  if(!selected && wym._selected_image)
    selected = $(wym._selected_image).parentsOrSelf(WYMeditor.A);
	if ((selected != null && selectedPos != null) && current_dialog.toggleTopTray())
	{
		var thisBlueLinkDialog = this;
		var tray_dialog = current_dialog.dialog.topTray.find(".trayDialog .content");
		var tray_loading = current_dialog.dialog.topTray.find(".trayDialog .loading");

		tray_dialog.hide();
		tray_loading.show();	

		$.get(path, {}, function(data) {

			tray_dialog.html(data);

			tray_loading.fadeOut(150, function() {
						tray_dialog.fadeIn(150);
						thisBlueLinkDialog.loadDirectory("/admin/assets/selector/documents")
			});
			


			if (selected && selected.length > 0) {
				$("input[name='href']").val($(selected).attr("href"));
				$("input[name='name']").val($(selected).attr("name"));
				$("select[name='target']").val($(selected).attr("target"));
				$("input[name='insert']").val("Update Link");
			}

			$("input[name='insert']").click(function() {
			
				var sStamp = wym.uniqueStamp();

				var sUrl = jQuery.trim($("input[name='href']").val());
		
				if (!$.browser.msie) {
					wym._exec(WYMeditor.CREATE_LINK, sStamp);
				}
				else {
					selectedPos.execCommand(WYMeditor.CREATE_LINK, false, sStamp);
				}

	      a_tag = $("a[href='" + sStamp + "']", wym._doc.body).attr("href", sUrl).attr("name", jQuery("input[name='name']").val());

				if (jQuery("select[name='target']").val() != "_self") {
	          a_tag.attr("target", jQuery("select[name='target']").val());
				} else {
						a_tag.removeAttr("target");
				}


				current_dialog.closeTopTray();
				return false;
			});

			$(".cancel").click(function() {
				current_dialog.closeTopTray();
				return false;
			})
		});
		
		
	}
};

BlueLinkDialog.prototype.bindFiles = function() {
	
	var thisBlueLinkDialog = this;
	var current_dialog = this._options.current_dialog;  
	var wym = this._wym;
	var sStamp = wym.uniqueStamp();

	current_dialog.dialog.topTray.find("a.file").click(function() {
		sUrl = $(this).attr("href").replace(/^.*selector/, "").replace("/.thumbnails", "").replace("/assets", "");
		sUrl = "/assets" + sUrl;
		
		$("input[name='href']").val(sUrl);
		
		return false;
		
	});
	
}

BlueLinkDialog.prototype.bindDirectories = function() {
	var thisBlueLinkDialog = this;
	current_dialog.dialog.topTray.find("a.directory").click(function() {
		thisBlueLinkDialog.loadDirectory($(this).attr("href"));
		return false;
	});
}

BlueLinkDialog.prototype.loadDirectory = function(path) {
	var thisBlueLinkDialog = this;
	var current_dialog = this._options.current_dialog;
	var tray_dialog = current_dialog.dialog.topTray.find(".trayDialog .content #assets");
	var tray_loading = current_dialog.dialog.topTray.find(".trayDialog .loading");
	var wym = this._wym
		
	tray_dialog.html();
	tray_dialog.addClass("loading");
	//tray_loading.show();	
		
	$.get(path, {}, function(data) {
		
		tray_dialog.removeClass("loading");
		tray_dialog.html(data);
		tray_dialog.fadeIn(150);
		// tray_loading.fadeOut(150, function() {
		// 			
		// });

		// Have folders load on click
		thisBlueLinkDialog.bindFiles();
		thisBlueLinkDialog.bindDirectories();
	});
}