//This is bcchf javascript
$(document).foundation();

var off_canvas_left;

(function($) {

	/**
	* when the complete page is fully loaded,
	* including all frames, objects and images.
	**/
	$(window).load(function(){
		
	});
	
	/**
	* when the HTML document is loaded and the DOM is ready,
	* even if all the graphics haven't loaded yet.
	**/
	$(document).ready(function() {
		/* Instatiate Fastclick */
		//FastClick.attach(document.body);

		// Handle the off-canvas menu
		$('.js-bcchf-menu-icon').click(function(e){
			e.preventDefault();
			off_canvas_left = $('.bcchf-off-canvas-menu').position().left;
			//alert(off_canvas_left);
			//$('.bcchf-off-canvas-menu').animate({'left' : 0}, 300);
			$('.bcchf-off-canvas-menu').addClass('reveal');

			// Make the content position absolute so the menu will scroll down
			$('.bcchf-content').css('position', 'absolute');

			// Hide the bottom menu so it will not overlap on the home content
			$('.bcchf-bottom-menu').css('display', 'none');
		});

		$('.js-bcchf-icon-close').click(function(e){
			e.preventDefault();
			//$('.bcchf-off-canvas-menu').animate({'left' : off_canvas_left}, 300);
			$('.bcchf-off-canvas-menu').removeClass('reveal');

			// Set the content position back to relative
			$('.bcchf-content').css('position', 'relative');

			// Show the bottom menu back
			$('.bcchf-bottom-menu').css('display', 'block');
		});
		
		/*// Handle the off-canvas menu
		$('.js-bcchf-menu-icon').click(function(){
			off_canvas_left = $('.bcchf-off-canvas-menu').position().left;
			$('.bcchf-off-canvas-menu').animate({'left' : 0});
		});

		$('.js-bcchf-icon-close').click(function(e){
			e.preventDefault();
			$('.bcchf-off-canvas-menu').animate({'left' : off_canvas_left});
		});*/
	});
})(jQuery);