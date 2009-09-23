(function ($) {
	
	$.slide_panel = function (page, options) {
		return $.slide_panel.impl.init(page, options);
	};
	
	$.slide_panel.close = function (page, options) {
		$.slide_panel.impl.close();
	};
	
	$.fn.slide_panel = function (options) {
		return $.slide_panel.impl.init(this, options);
	};
	
	$.slide_panel.defaults = {
		containerId: 'slide_panel',
		height: "150px",
		width: "100%",
		close: true,
		onOpen: null,
		onShow: null,
		speed: 500
	};
	
	$.slide_panel.impl = {
		
		opts: null,
		
		page: {},
		
		init: function(page, options) {
			if (this.panel) { return this; }
			this.page = $(page);
			this.opts = $.extend({}, $.slide_panel.defaults, options);
			
			this.panel = $("<div>").appendTo("body");
			this.panel.attr("id", this.opts.containerId);
			this.panel.css({opacity:0.9})
			
			height = parseInt(this.opts.height.replace("px", ""))
			 			 + parseInt(this.panel.css("borderTopWidth").replace("px", "")) 
						 + parseInt(this.panel.css("borderBottomWidth").replace("px", "")) 
						 + parseInt(this.panel.css("paddingTop").replace("px", "")) 
						 + parseInt(this.panel.css("paddingBottom").replace("px", "")) 

			this.opts.slideHeight = height + "px";
			this.panel.css({height:this.opts.height, width:this.opts.width, position:"fixed", bottom:"-"+this.opts.slideHeight}) 
			

			return this;
		},
		
		open: function() {
			this.page.animate({paddingBottom:this.opts.slideHeight}, this.opts.speed);
			this.panel.animate({bottom:0}, this.opts.speed);
		},
		
		close: function() {
			this.page.animate({paddingBottom:0}, this.opts.speed);
			this.panel.animate({bottom:"-"+this.opts.slideHeight}, this.opts.speed);
		}
		
	}
	
})(jQuery);