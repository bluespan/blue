//Extend WYMeditor
WYMeditor.editor.prototype.blue_image_dialog = function(options) {
  var blue_image_dialog = new BlueImageDialog(options, this);
  return(blue_image_dialog);
};

//WymTidy constructor
function BlueImageDialog(options, wym) {

  options = jQuery.extend({

    sUrl:          "wymeditor/plugins/tidy/tidy.php",
    sButtonHtml:   "<li class='wym_tools_image'>"
                 + "<a name='InsertImage' href='#'>"
                 + "Insert Image"
                 + "</a></li>",
    
    sButtonSelector: "li.wym_tools_image a"
    
  }, options);
  
  this._options = options;
  this._wym = wym;
	
};

//WymTidy initialization
BlueImageDialog.prototype.init = function() {
  var blue_image_dialog = this;
            
  jQuery(this._wym._box).find('.wym_tools_unlink')
    .after(this._options.sButtonHtml);
  
  //handle click event
  jQuery(this._wym._box).find(this._options.sButtonSelector).click(function() {
    blue_image_dialog.open();
    return(false);
  });

};


BlueImageDialog.prototype.open = function() {

	var current_dialog = this._options.current_dialog;
	var wym = this._wym;
	var path = "/admin/assets/selector/images";
	
///assets/images/test/Photo%20107.jpg
	if (current_dialog.toggleLeftTray())
	{
		if (wym._selected_image) {
			src = "/images"
			if (jQuery(wym._selected_image).attr("src").indexOf("http") < 0)
				src = jQuery(wym._selected_image).attr("src").replace("/assets", "").replace(/\/[^\/]*$/, "");
				
			path = "/admin/assets/selector" + src
			
		}
		
		this.selectedPos = wym.selectedPosition();
		this.loadDirectory(path);
	}
};

BlueImageDialog.prototype.bindImages = function() {
	
	var thisBlueImageDialog = this;
	var current_dialog = this._options.current_dialog;  
	var wym = this._wym;
	var sStamp = wym.uniqueStamp();

	current_dialog.dialog.leftTray.find("a.file").click(function() {

		
		sUrl = $(this).attr("href").replace(/^.*selector/, "");
		sUrl = "/assets" + sUrl;

		if (!$.browser.msie) {
			wym._exec(WYMeditor.INSERT_IMAGE, sUrl);
		}
		else {
			thisBlueImageDialog.selectedPos.execCommand(WYMeditor.INSERT_IMAGE, false, sUrl);
		}

		
  	jQuery("img[src='" + sUrl + "']", wym._doc.body)
      .attr(WYMeditor.TITLE, "")
      .attr(WYMeditor.ALT, "");

		current_dialog.closeLeftTray();
		
		return false;
		
	});
	
}

BlueImageDialog.prototype.bindDirectories = function() {
	var thisBlueImageDialog = this;
	current_dialog.dialog.leftTray.find("a.directory").click(function() {
		thisBlueImageDialog.loadDirectory($(this).attr("href"));
		return false;
	});
}

BlueImageDialog.prototype.loadDirectory = function(path) {
	var thisBlueImageDialog = this;
	var current_dialog = this._options.current_dialog;
	var tray_dialog = current_dialog.dialog.leftTray.find(".trayDialog .content");
	var tray_loading = current_dialog.dialog.leftTray.find(".trayDialog .loading");
		
	tray_dialog.hide();
	tray_loading.show();	
		
	$.get(path, {}, function(data) {
		
		tray_dialog.html(data);

		tray_loading.fadeOut(150, function() {
					tray_dialog.fadeIn(150);
		});

		// Have folders load on click
		thisBlueImageDialog.bindImages();
		thisBlueImageDialog.bindDirectories();
	});
}