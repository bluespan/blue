jQuery.fn.canvasSlide = function(settings) {
	settings = jQuery.extend(
		{
			
		}, settings
	);
	

	var slides = [];
	var images = [];
	var mask = null;
	var canvas = $(this);
	var current_slide =  null;
	var slideOutTimeout = null;
	
	return this.each(function(){
		
		var init = function() {
			slides = canvas.children(".slide");
			images = canvas.children("img.background");
			titles = canvas.children("img.slide_title");
			mask = canvas.find("#mask");
			
			mask.bind("mousemove", slideMouseMove);
			
			mask.bind("mouseout", animateSlideOut);
		}
		
		var slideMouseMove = (function(e) {
			x = e.pageX - $(this).offset().left
			width = $(this).width();
											
							
			cancelSlideOut();
			
			if (current_slide == null) {
				if (x < width / 2)
					animateAppearRight();
				else
					animateAppearLeft();
			} else {
				if ( (x < width * 0.5 && current_slide == 1) || (x > width * 0.5 && current_slide == 0) )
					slideToggle();
			}
		});
		
		
		var slideToggle = function() {
			slide = $(slides[current_slide]);
			slide.stop().hide();
			if (current_slide == 0) {
				animateAppearLeft();
			} else {
				animateAppearRight();
			}
		}
		
		var animateAppearRight = function() {
			//mask.unbind("mousemove");
			mask.bind("mouseover", cancelSlideOut);
			slides.stop().hide();
			if (current_slide != null)
			$(titles[current_slide]).stop().css({opacity:100});
			
			current_slide = 0;
			$(titles[current_slide]).css({opacity:100});
			
			image = $(images[0]);
			slide = $(slides[0]);
				
			slide.stop();
			
			slide.show();
			slide.css({opacity:0, position:"absolute", left:image.offset().left+281, top:image.offset().top,width:"0px", marginTop:0, marginLeft:"0"});
			$(titles[current_slide]).stop().animate({opacity: 0}, 800);
			slide.animate({ 
			        width: "313px",
			        opacity: 1
			      }, 800);
		}

		
		var animateAppearLeft = function() {
			mask.bind("mouseover", cancelSlideOut);
			slides.hide();
			if (current_slide != null)
			$(titles[current_slide]).stop().css({opacity:100});
			
			current_slide = 1;
			$(titles[current_slide]).css({opacity:100});
			
			image = $(images[0]);
			slide = $(slides[1]);
				
			slide.stop();
			slide.show();
			slide.css({opacity:0, position:"absolute", left:image.offset().left+231, top:image.offset().top,width:"0px", marginTop:0, marginLeft:"83px"});
			$(titles[current_slide]).stop().animate({opacity: 0}, 800);
			slide.animate({ 
			        width: "313px",
			        opacity: 1,
			        marginLeft: "-230px"
			      }, 800);
		}
		
		var animateSlideOut = function() {
			slide = $(slides[current_slide]);
			title = $(titles[current_slide]);
			slideOutTimeout = window.setTimeout(function(){
					title.css({opacity:0}).animate({opacity: 100}, 1000);
					slide.stop();			
					slide.animate({ 
								opacity: 0
					      }, 1000, function() {$(this).hide(); current_slide = null} );
			}, 500);
		}	
		
		var cancelSlideOut = function() {
			window.clearTimeout(slideOutTimeout);
		}
		
		init();
		
	});
}