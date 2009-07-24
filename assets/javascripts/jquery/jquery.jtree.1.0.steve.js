/* Copyright (c) 2008 Kean Loong Tan http://www.gimiti.com/kltan
 * Licensed under the MIT (http://www.opensource.org/licenses/mit-license.php)
 * Copyright notice and license must remain intact for legal use
 * jTree 1.0
 * Version: 1.0 (May 5, 2008)
 * Requires: jQuery 1.2+
 */
(function($) {

	$.fn.jTree = function(options) {
		if ($("#jTreeHelper").length == 0)
			$("body").append('<ul id="jTreeHelper"></ul>');
			
		var opts = $.extend({}, $.fn.jTree.defaults, options);
		var cur = 0, curOff = 0, off =0, h =0, w=0, hover = 0, curContainer = 0, hotspotOff = 0;
		var jTreePlacement='<li class="jTreePlacement" style="background:'+opts.pBg+';border:'+opts.pBorder+';color:'+opts.pColor+';width:'+opts.pWidth+';height:'+opts.pHeight+'"></li>';
		var container = this;
		//events are written here

		var mousedown = function(e) {
			
			// Determine Hotspot
			hotspot = $($(this).find(".navigation_page").get(0) || this);
			hotspotOff = hotspot.offset();
			
			clicked_hotspot = (hotspotOff.left >= e.pageX - parseInt(hotspot.css("paddingLeft")))
	
			if ($("#jTreeHelper").is(":not(:animated)") && e.button !=2 && clicked_hotspot) {
				$("body").css("cursor","move");
				// append jTreePlacement to body and hides
				$("body").append(jTreePlacement);				
				$(".jTreePlacement").hide();
				//get the current li and append to helper
				$(this).clone().appendTo("#jTreeHelper");
				
				cur = this;
				curOff = $(cur).offset();
			
				$(cur).css({opacity:0.3});
				// show initial helper
				$("#jTreeHelper").css ({
					position: "absolute",
					top: e.pageY + 5,
					left: e.pageX + 5,
					opacity: opts.hOpacity
				}).hide();
				
				if(opts.showHelper)
					$("#jTreeHelper").show();

				// start binding events to use
				// prevent text selection
				$(document).bind("selectstart", doNothing);
				
				// doubleclick is dejTreePlacementuctive, better disable
				$(container).find("li").bind("dblclick", doNothing);
				
				// in single li calculate the offset, width height of hovered block
				$(container).filter(":not(.list)").find("li").bind("mouseover", getInitial);
				
				// in single li put placement in correct places, also move the helper around
				$(container).filter(":not(.list)").bind("mousemove", sibOrChild);
				
				// in container put placement in correct places, also move the helper around
				$(container).filter(":not(.list)").find("li").andSelf().bind("mousemove", putPlacement);
				
				// handle mouse movement outside our container
				$(document).bind("mousemove", helperPosition);
				
				$(document).bind("mousemove", scrollPage);
			}
			//prevent bubbling of mousedown
			return false;
		};
		
		var mouseup = function(e){
			// if placementBox is detected
			var navigation;
		
			$("body").css("cursor","default");
			if ($(".jTreePlacement").is(":visible")) {
				
				// Clone if from a list
				if ($(cur).parents(".list").length > 0) {
					clonedCur = $(cur).clone()
					$(clonedCur).find("span.tools").remove(); 
					$(clonedCur).bind("mousedown", mousedown).bind("mouseup", mouseup).css({opacity:1});
					$(clonedCur).insertBefore(".jTreePlacement").show();			
					navigation = clonedCur;
				} else {
					$(cur).insertBefore(".jTreePlacement").show();
					navigation = cur;
				}
				
			}
			$(cur).css({opacity:1});
			// remove helper and placement box and clean all empty ul
			$(container).find("ul:empty").remove();
			$("#jTreeHelper").empty().hide();
			$(".jTreePlacement").remove();		
			
			// remove bindings
			destroyBindings();			
		
			if(opts.onChangeCallback && navigation)
			 	opts.onChangeCallback.call(this, $(navigation));
	
			return false;
		};
		
		$(document).mouseup(function(e){
			$("body").css("cursor","default");
			if ($("#jTreeHelper").is(":not(:empty)")) {
				$("#jTreeHelper").animate({
					top: curOff.top,
					left: curOff.left
						}, opts.snapBack, function(){
							$("#jTreeHelper").empty().hide();
							$(".jTreePlacement").remove();
							$(cur).css({opacity:1});
						}
				);
				
				destroyBindings();
			}			

			return false;
		});

		// unbind in the case of a reload
		$(this).find("li").andSelf().unbind("mousedown").unbind("mouseup")
		
		$(this).find("li").bind("mousedown", mousedown);
		
		// in single li or in container, snap into placement if present then dejTreePlacementoy placement
		// and helper then show snapped in object/li
		// also dejTreePlacementoys events
		$(this).find("li").andSelf().bind("mouseup", mouseup);
		
		//functions are written here
		var doNothing = function(){
			return false;
		};
		
		
		var destroyBindings = function(){
			$(document).unbind("selectstart", doNothing);
			$(container).find("li").unbind("dblclick", doNothing);
			$(container).find("li").unbind("mouseover", getInitial);
			$(container).find("li").andSelf().unbind("mousemove", putPlacement);
			$(document).unbind("mousemove", helperPosition);
			$(container).unbind("mousemove", sibOrChild);
			
			$(document).unbind("mousemove", scrollPage);
			return false;
		};
				
		var helperPosition = function(e) {
			$("#jTreeHelper").css ({
				top: e.pageY + 5,
				left: e.pageX + 5
			});
			
			$(".jTreePlacement").remove();

			return false;
		};
		
		var scrollPage = function(e) {
			if (e.pageY < $(document).scrollTop() + 20 && $(document).scrollTop() > 0) {
				$.scrollTo("-=20", 50);
				$(document).trigger("mouseover");
			}
			if (e.pageY > $(window).height() + $(document).scrollTop() - 20 && $(document).scrollTop() + $(window).height() < $(document).height() - 20) {
				$.scrollTo("+=20", 50);
				$(document).trigger("mouseover");			
			}

			return false;
		}
		
		var getInitial = function(e){
			off = $(this).offset();
			h = $(this).height();
			w = $(this).width();
			hover = this;
			hotspot = $($(this).find(".navigation_page").get(0) || this);
			hotspotOff = hotspot.offset();
			return false;
		};
		
		var sibOrChild = function(e){
			$("#jTreeHelper").css ({
				top: e.pageY + 5,
				left: e.pageX + 5
			});
			return false;
		};
		
		var putPlacement = function(e){

			
			//$(cur).hide();
			$("#jTreeHelper").css ({
				top: e.pageY + 5,
				left: e.pageX + 5
			});
			
			
		 	if ($(this).is("ul")) {
				// Inserting into empty list
				if ($(this).is(":empty")) {
					$(".jTreePlacement").remove();
					$(this).append(jTreePlacement);
				}
			}	else {
				
						//console.log(hover, h,w,e.pageX,off);
				
			 	 insertBeforeVertical = e.pageY >= hotspotOff.top && e.pageY <= (hotspotOff.top + (h * .10));
				 //insertBeforeHorizontal = e.pageX >= off.left && e.pageX < (off.left + w/2 - 1);
 
				 insertAfterVertical = e.pageY >(hotspotOff.top + (h * .35)) &&  e.pageY <= (off.top + h);
				 //insertAfterHorizontal = e.pageX >(off.left + w/2) &&  e.pageX <= (off.left + w);
 
				 insertAfterAsSiblingVertical = e.pageX > hotspotOff.left && e.pageX < hotspotOff.left + parseInt($(hotspot).css("paddingLeft")) //+ opts.childOff;
				 //insertAfterAsSiblingHorizontal = e.pageY > off.top && e.pageY < off.top + opts.childOff;
 
				 insertAfterAsChildVertical = e.pageX >= hotspotOff.left + parseInt($(hotspot).css("paddingLeft"))//+ opts.childOff;
				 //insertAfterAsChildHorizontal = e.pageY > off.top + opts.childOff;
		
				//inserting before
				if ( insertBeforeVertical ) {
					if (!$(this).prev().hasClass("jTreePlacement")) {
						$(".jTreePlacement").remove();
						$(this).before(jTreePlacement);
					}
				}
				//inserting after
				else if ( insertAfterVertical ) {
					
					// as a sibling
					if ( insertAfterAsSiblingVertical ) {
						//console.log("hi")
						if (!$(this).next().hasClass("jTreePlacement")) {
							$(".jTreePlacement").remove();
							$(this).after(jTreePlacement);
						}
					}
					// as a child
					else if ( insertAfterAsChildVertical ) {
						$(".jTreePlacement").remove();
						if ($(this).find("ul").length == 0)
							$(this).append('<ul>'+jTreePlacement+'</ul>');
						else
							$(this).find("ul").prepend(jTreePlacement);
					}
				}
			}
			
			if($(".jTreePlacement").length>1)
				$(".jTreePlacement:first-child").remove();
	
			return false;
		}
		
		var lockIn = function(e) {
			// if placement box is present, insert before placement box
			if ($(".jTreePlacement").length==1) {
				$(cur).insertBefore(".jTreePlacement");
			}
			$(cur).show();
			
			// remove helper and placement box
			$("#jTreeHelper").empty().hide();
			
			$(".jTreePlacement").remove();
			
			return false;
		}

	}; // end jTree


	$.fn.jTree.defaults = {
		showHelper: true,
		hOpacity: 0.5,
		hBg: "#FCC",
		hColor: "#222",
		pBorder: "1px dashed #CCC",
		pBg: "#EEE",
		pColor: "#222",
		pHeight: "20px",
		pWidth: "auto",
		childOff: 20,
		snapBack: 300,
		onChangeCallback: null
	};
		  
})(jQuery);

