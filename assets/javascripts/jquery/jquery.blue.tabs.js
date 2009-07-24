(function ($) {
	
	// Init namespace
	if (!$.blue) {
		$.fn.blue = {};
		$.blue = {};
	}
		
	$.blue.tabs = function (selector, options) {
		return $.blue.tabs.impl.init(selector, options);
	};	
		
	$.fn.blue.tabs = function (options) {
		return $.blue.tabs.impl.init(this, options);
	};
	
	$.blue.tabs.defaults = {
		tab_selector: "ul li",
		content_selector: "div.tab_content",
		classes: $.extend({current: 'current', disabled: 'disabled'})		
	};
	
	$.blue.tabs.impl = {
		
		opts: null,
		tabs: null,
		content: null,

		init: function (selector, options) {
			var tab_control = this;
			
			// Merge Default Options
			this.opts = $.extend({}, $.blue.tabs.defaults, options);
			if (options) {
				this.opts.classes = $.extend({}, $.blue.tabs.defaults.classes, options.classes || {});
			}
			
			this.tabs = $(selector).find(this.opts.tab_selector);
			var contents = this.content = $(selector).find(this.opts.content_selector);

			
			this.tabs.each(function(i, tab){
				var content = contents[i];
				
				if (content) {
					$(this).click(function(){
						tab_control.clear();
						$(this).addClass(tab_control.opts.classes.current)
						$(content).show();
						
						return false;
					});
				} else {
					$(this).addClass(tab_control.opts.classes.disabled)
				}
			});
			
			// Select the first tab by default
			$(this.tabs[0]).trigger("click");
		},
		
		clear: function() {
			this.tabs.removeClass(this.opts.classes.current);
			this.content.hide();
		}
	};
	
})(jQuery);