//This is bcchf javascript
/***************************************************************************************************
 *   secure.js
 *
 *   This is a default javascript file for BCCHF Secure pages. 
 *
 *   For this file, only global facebook javascript functions allowed.
 *   If additional functions are required, those functions must be put
 *   into the proper module.
 *
 *   @copyright     2014 DARE
 *                  
 *   @authors       Cindy Son, Technical Director <cindy.son@thisisdare.com>
 *                  Gabrielle Carson, Front-End Developer <gabrielle.carson@thisisdare.com>
 *                  Carolvie Ozar, Front-End Developer <carolvie.ozar@thisisdare.com>
 * 
 *   @since         April 2014
 *
 *   @category      Javascript
 *   @package       landing
 *   @subpackage    bcchf_mobile
 *
 *  * TABLE OF CONTENTS
 *
 * A - GLOBAL VARIABLES 
 * B - WINDOW LOAD
 * C - DOCUMENT READY
 * D - FUNCTION DEFINITIONS
***************************************************************************************************/
$(document).foundation();

/* A - GLOBAL VARIABLES 
***********************************************/
var after_resize,
	donate_validator,
	callback = true,
	reposition = false;

(function($) {
	/* FastClick is a simple, easy-to-use library for eliminating the 300ms delay
	between a physical tap and the firing of a click event on mobile browsers. */
	//FastClick.attach(document.body);

	/* B - WINDOW LOAD
	*  when the complete page is fully loaded,
	*  including all frames, objects and images.
	***********************************************/
	$(window).load(function(){
		$(window).on('resize', function(){
 			// Make sure resize ends before doing anything
 			clearTimeout(after_resize);
 			after_resize = setTimeout(function(){
 				
 				// Reposition Steps
 				if ($('.bcchf-login').length == 0) {
 					positionPages();	
 				}

 			}, 100);
 		});
	});
	
	/* C - DOCUMENT READY
	*  when the HTML document is loaded and the DOM is ready,
	*  even if all the graphics haven't loaded yet.
	***********************************************/
	$(document).ready(function() {
		init();
		positionPages();
		page1Handler();
		page2Handler();
		page3Handler();
		page4Handler();
		gotoPage();
		validateLogin();
		validateForgot();
		validateDonate();
		navigationHandler();
		initModalEffects();
		
		// Handle PayPal button
		$('.js-bcchf-paymentOption-PayPal').on("click", function(e){
			
			e.preventDefault();
			//console.log('we got here');
			
			bcchfSlideUp($('.js-bcchf-cardoptions-row'));
	
			checkMobileDFormPayPal();
			//ajaxHandler($('#js-bcchf-donate-form'));
		});
		
	});		


	/* D - FUNCTION DEFINITIONS
	***********************************************/
	/*
	* init - handles the initialization
	*/
	function init() {
		// Clear all input fields and set to default value all dropdowns
		//$('input, select').val('');
		// we only want to clear if there is no sup_pge_UUID
		var sup_pge_UUID = $('#sup_pge_UUID').val();
		
		if (sup_pge_UUID == ''){
			$('input[type="radio"]').prop('checked', false);
		} else {
			/// there is a ID present
			/// returning from a cancelled PayPal transaction
			//bcchfSlideUp($('.js-bcchf-cardoptions-row'));
			window.scroll(0,2000);
		}

		// Disable tab
		document.onkeydown = function (e) {
			if ( e.which == 9 ) {
				return false;
			}
		}

		// Customize the functionality for enter/return key
		$('input').keypress(function(e){
			var keycode = (e.keycode ? e.keycode : e.which);
			if (keycode == 13) {
				//$(this).trigger('focusout');
				if ( $('#js-bcchf-login-btn').length > 0 ) {
					e.preventDefault();
					$('#js-bcchf-login-btn').focus();
				}else if ( $('.js-bcchf-btn-next').length > 0 ) {
					e.preventDefault();
					$('.js-bcchf-btn-next').focus();
				}

				customValidate();
			}
		});

		// Disable prev and next on Mobile
		var device = navigator.userAgent.toLowerCase();

		var ios = device.match(/OS 7(_\d)+ like Mac OS X/i);

		if (ios) {
			$('input, textarea, select').on('focus', function() {
				$('input, textarea').not(this).attr("readonly", "readonly");
				$('select').not(this).attr("disabled", "disabled");
			});
			$('input, textarea, select').on('blur', function() {
				$('input, textarea').removeAttr("readonly");
				$('select').removeAttr("disabled");
			});
		}
	}

	/*
	* positionPages - positions the pages and adjusts the height of the parent
	*/
	function positionPages() {
		// Position bcchf-steps
		var screen_width = window.innerWidth,
			screen_height = window.innerHeight,
			offset = 250,
			position = 0,
			current = $('.js-bcchf-current-page'),
			left_pos,
			multiplier = 0;

		if ( !reposition || $('#bcchf-step1').hasClass('js-bcchf-current-page') ) {
			$('.js-bcchf-steps').each(function(){
				current.css('left', position);
				position += screen_width + offset;
				current = current.next('.js-bcchf-steps');
			});
			reposition = true;
		} else {
			//left_pos = current.next('.js-bcchf-steps').position().left;
			left_pos = Math.round(Math.abs(current.prev('.js-bcchf-steps').position().left));
			$('.js-bcchf-steps').each(function(){
				multiplier = $(this).position().left / left_pos;
				position = (screen_width + offset) * multiplier;
				$(this).css('left', position);
			});
		}

		// Assign height to the form
		adjustPageHeight(200);
	}

	/*
	* page1Handler - handles the buttons and inputs on page 1
	*/
	function page1Handler() {
		var btn = $('.js-bcchf-step1 .bcchf-btn:not(.bcchf-btn-paypal)');
		var input = $('.js-bcchf-step1 input');
		var select = $('.js-bcchf-step1 select, .js-bcchf-step1 input');
		var hidden_input;
		
		// This handle the input and select fields
		select.change(function() {
			var field = $(this).attr('id');
			var	value = $(this).val();
			
			// Check Donate Type
			if ( field == 'js-bcchf-donate-type' ) {
				if (value == 'corporate') {
					//console.log(1);
					bcchfSlideDown('.js-bcchf-corpo-name');
				}else {
					bcchfSlideUp('.js-bcchf-corpo-name:visible');
				}

				// Store values
				$('#js-form-donation-type').attr('value', value);

			} else if ( field == 'js-bcchf-gift-type' ){
				// Check Gift Type dropdown
				if ( value == 'honour' || value == 'memory' ) {
					bcchfSlideUp('.js-bcchf-pledge:visible');
					$('#js-bcchf-lb-honour').html('I am making my donation in '+value+' of:');
					$('#js-bcchf-lb-send-email').html('Would you like to send an email notification to someone that a donation has been made in '+value+':');
					bcchfSlideDown('.js-bcchf-honour');
					bcchfSlideDown('.js-bcchf-send-email');
				}else if (value == 'support' ) {
					bcchfSlideUp('.js-bcchf-pledge:visible');
					$('#js-bcchf-lb-honour').html('I am making my donation in '+value+' of:');
					$('#js-bcchf-lb-send-email').html('Would you like to have your donation scroll on the thank you scroll:');
					bcchfSlideDown('.js-bcchf-honour');
					bcchfSlideUp('.js-bcchf-send-email');
					bcchfSlideUp('.js-bcchf-recepient-email');
				}else if (value == 'pledge' ) {
					bcchfSlideUp('.js-bcchf-honour:visible');
					bcchfSlideUp('.js-bcchf-send-email:visible');
					bcchfSlideUp('.js-bcchf-recepient-email:visible');
					bcchfSlideDown('.js-bcchf-pledge');
				} else {
					bcchfSlideUp('.js-bcchf-honour:visible');
					bcchfSlideUp('.js-bcchf-send-email:visible');
					bcchfSlideUp('.js-bcchf-recepient-email:visible');
					bcchfSlideUp('.js-bcchf-pledge:visible');
				}

				// Close the help if it is open
				if ( value != '' && $('.js-bcchf-details-container:visible') ) {
					$('.js-bcchf-close').trigger('click');
				}

				// Store values
				$('#js-form-gift-type').attr('value', value);

			} else if ( field == 'js-bcchf-corpo-name' ) {
				$('#js-form-corporation').attr('value', value.capitalize());
			} else if ( field == 'js-bcchf-honour' ) {
				$('#js-form-honour').attr('value', value);
			} else if ( field == 'js-bcchf-pledgeid' ) {
				$('#js-form-pledgeid').attr('value', value);
			} else {
				if ( field == 'js-bcchf-recepient-email' ) {
					$('#js-form-recepient-email').attr('value', value.toLowerCase());
				}
			}
			customValidate();
		});

		input.bind('input propertychange', function() {
			customValidate();
		});

		btn.on('click tap', function(e){
			e.preventDefault();
			clicked = $(e.currentTarget);
			hidden_input = clicked.siblings('input[type="radio"]');
			label = $('label[for="' + hidden_input.attr('name') + '"]');

			// Remove the error class on label if buttons are selected
			if ( label.hasClass('error') ) {
				label.removeClass('error');
			}

			// Set the selected state
			clicked.parent().siblings().find('.bcchf-active').removeClass('bcchf-active');
			clicked.addClass('bcchf-active');

			// select the hidden input associated with the button
			if ( hidden_input ) {
				hidden_input.prop('checked', true);
			}

			// Show or hide the recepient's email input box
			if ( clicked.attr('id') == 'js-bcchf-send-email-yes' ) {
				bcchfSlideDown('.js-bcchf-recepient-email');
			}else {
				bcchfSlideUp('.js-bcchf-recepient-email');
			}

			customValidate();
		});

		// Check if first page; display Paypal instead of back button
		if ( $('#bcchf-step1').hasClass('js-bcchf-current-page') ) {
			$('.js-bcchf-btn-prev').addClass('bcchf-btn-paypal');
		}

		// Display the help box
		$('.js-bcchf-icon-help').click(function(e){
			e.preventDefault();
			bcchfSlideDown('.js-bcchf-details-container');
		});

		// Hide the help box
		$('.js-bcchf-close').click(function(e){
			e.preventDefault();
			bcchfSlideUp('.js-bcchf-details-container');
		});
	}

	/*
	* page2Handler - handles the buttons and inputs on page 2
	*/
	function page2Handler() {
		var btn = $('.js-bcchf-step2 .bcchf-btn');
		var amount = $('.js-bcchf-amount');
		var other_amt = $('#js-bcchf-other-amt');
		var frequency = $('.js-bcchf-frequency')
		var bill_cycle = $('.js-bcchf-bill-cycle');
		var input;
		var once_array = [250, 100, 50, 25];
		var monthly_array = [100, 50, 30, 18];

		// Make sure other amount is disabled on load
		other_amt.prop('disabled', true);
		
		 // This handle the buttons
		btn.on('click tap', function(e){
			e.preventDefault();
			clicked = $(e.currentTarget);
			input = clicked.siblings('input[type="radio"]');
			label = $('label[for="' + input.attr('name') + '"]');

			// If a disabled button is clicked, return
			if ( ! frequency.hasClass('bcchf-active') && clicked.hasClass('bcchf-btn-disabled') ) {
				return;
			}

			// Set the selected state
			clicked.parent().siblings().find('.bcchf-active').removeClass('bcchf-active');
			clicked.addClass('bcchf-active');

			// select the hidden input associated with the button
			input.prop('checked', true);

			// Remove the error class on label if buttons are selected
			if ( label.hasClass('error') && clicked.hasClass('bcchf-active') ) {
				label.removeClass('error');
			}

			// If frequency is selected, enable amount options and other amount
			if ( clicked.hasClass('js-bcchf-frequency') ) {
				
				if ( clicked.attr('id') == 'js-bcchf-frequency-once') {
					bill_cycle.siblings('input[type="radio"]').prop('checked', false);
					bill_cycle.removeClass('bcchf-active');
					amount.siblings('input[type="radio"]').prop('checked', false);
					amount.removeClass('bcchf-active');
					bcchfSlideUp($('.js-bcchf-billcycle-row'));
					
					bcchfSlideDown($('.bcchf-CCpayPalOption-container'));

					var i = 0;
					amount.each(function(){
						$(this).attr('data-val', once_array[i]);
						$(this).text('$' + once_array[i]);
						i++;
					});
				} else {
					amount.siblings('input[type="radio"]').prop('checked', false);
					amount.removeClass('bcchf-active');
					bill_cycle.siblings('input[type="radio"]').prop('checked', false);
					bill_cycle.removeClass('bcchf-active bcchf-btn-disabled');
					bcchfSlideDown($('.js-bcchf-billcycle-row'));

					bcchfSlideUp($('.bcchf-CCpayPalOption-container'));
					

					var i = 0;
					amount.each(function(){
						$(this).attr('data-val', monthly_array[i]);
						$(this).text('$' + monthly_array[i]);
						i++;
					})
				}

				// Enable amount option if other amount is empty
				if ( ! other_amt.val() ) {
					amount.removeClass('bcchf-btn-disabled');
				}
				
				other_amt.prop('disabled', false);

				// Store values
				$('#js-form-frequency').attr('value', clicked.attr('data-val'));

			}else if ( clicked.hasClass('js-bcchf-amount') ) {
				// Set the selected button as active
				clicked.addClass('bcchf-active');
				amount.removeClass('bcchf-btn-disabled');

				// remove error on other amount label if there is
				if ( $('#js-bcchf-lb-other-amt').hasClass('error') ) $('#js-bcchf-lb-other-amt').removeClass('error');

				// Clear other amount
				other_amt.val('');

				// Store values
				$('#js-form-amount').attr('value', clicked.attr('data-val'));
			}else {
				// Store Bill Cycle
				if ( clicked.hasClass('js-bcchf-bill-cycle') ) {
					$('#js-form-bill-cycle').attr('value', clicked.attr('data-val'));
				}
			}

			customValidate();
		});
		
		other_amt.bind('input propertychange', function() {
			amount.removeClass('bcchf-active');
			amount.addClass('bcchf-btn-disabled');
			amount.siblings('input[type="radio"]').prop('checked', false);
			other_amt.prop('disabled', false);

			if ( $('#js-bcchf-frequency-monthly').hasClass('bcchf-active') ) bill_cycle.removeClass('bcchf-btn-disabled');

			// Store values
			$('#js-form-amount').attr('value', $(this).val());

			customValidate();
		});
	}

	/*
	* page3Handler - handles the buttons and inputs on page 3
	*/
	function page3Handler() {
		var btn = $('.js-bcchf-step3 .bcchf-btn');
		var input = $('.js-bcchf-step3 input');
		var select = $('.js-bcchf-step3 select, .js-bcchf-step3 input');
		var hidden_input;
		
		btn.on('click tap', function(e){
			e.preventDefault();
			clicked = $(e.currentTarget);
			hidden_input = clicked.siblings('input[type="radio"]');
			label = $('label[for="' + hidden_input.attr('name') + '"]');

			// Remove the error class on label if buttons are selected
			if ( label.hasClass('error') ) {
				label.removeClass('error');
			}

			// Set the selected state
			clicked.parent().siblings().find('.bcchf-active').removeClass('bcchf-active');
			clicked.addClass('bcchf-active');

			// select the hidden input associated with the button
			if ( hidden_input ) {
				hidden_input.prop('checked', true);
			}

			if ( clicked.hasClass('js-bcchf-btn-allow-email') ) {
				$('#js-form-allowemail').attr('value', clicked.attr('data-val'));
			}

			customValidate();
		});

		// This handle the select fields
		select.change(function() {
			var field = $(this).attr('id');
			var	value = $(this).val();
			
			if ( field == 'js-bcchf-fname' || field == 'js-bcchf-lname') {
				if ( ! $('#js-bcchf-fname').val() || ! $('#js-bcchf-lname').val() ) {
					$('#js-bcchf-lb-name').addClass('error');
				} else {
					$('#js-bcchf-lb-name').removeClass('error');
				}
			}

			// Store first name
			if ( field == 'js-bcchf-fname' ) {
				$('#js-form-fname').attr('value', value.capitalize());
			} else if ( field == 'js-bcchf-lname' ) {
				$('#js-form-lname').attr('value', value.capitalize());
			} else {
				if ( field == 'js-bcchf-email' ) {
					$('#js-form-receipt-email').attr('value', value);
				}	
			}

			customValidate();
		});

		input.bind('input propertychange', function() {
			customValidate();
		});
	}

	/*
	* page4Handler - handles the buttons and inputs on page 4
	*/
	function page4Handler() {
		var provinceStartIndex = 1;
		var provinceEndIndex = 13;
		var defaultProvinceIndex = 2;
		var stateStartIndex = 14;
		var stateEndIndex = 64;
		var defaultStateIndex = 61;
		var otherIndex = 0;
		var country = $('#js-bcchf-country');
		var province = $('#js-bcchf-province');
		var exp_month = $('#js-bcchf-expiration-month');
		var exp_year = $('#js-bcchf-expiration-year');
		var exp_label = $('#js-bcchf-lb-expiration-month');
		var select = $('.js-bcchf-step4 input, .js-bcchf-step4 select');
		var input = $('.js-bcchf-step4 input');

		// This handle the input and select fields
		select.change(function() {
			var field = $(this).attr('id');
			var	value = $(this).val();
			
			if ( field == 'js-bcchf-cardholder' ) {
				// Store cardholder's name
				$('#js-form-cardholder').attr('value', value.capitalize());

			} else if ( field == 'js-bcchf-cardnumber' ) {
				// Store cardnumber
				$('#js-form-cardnumber').attr('value', value);
				
			}else if ( field == 'js-bcchf-cvv' ) {
				// Store cardholder's cvv
				$('#js-form-cvv').attr('value', value);
				
			}else if ( field == 'js-bcchf-address' ) {
				// Store cardholder's address
				$('#js-form-address').attr('value', value.capitalize());
				
			}else if ( field == 'js-bcchf-city' ) {
				// Store cardholder's city
				$('#js-form-city').attr('value', value.capitalize());
			
			}else if ( field == 'js-bcchf-prov' ) {
				// Store cardholder's province
				$('#js-form-prov').attr('value', value.capitalize());
				
			}else if ( field == 'js-bcchf-country' ) {
				// Store cardholder's country
				$('#js-form-country').attr('value', value.capitalize());
				
			}else if ( field == 'js-bcchf-postal' ) {
				// Store cardholder's postal
				$('#js-form-postal').attr('value', value.toUpperCase());
				
			}else {
				// Handle Expiration Date Dropdown
				if ( field == 'js-bcchf-expiration-month' || field == 'js-bcchf-expiration-year' ) {
					ValidateExpDate();

					if ( field == 'js-bcchf-expiration-month' ) {
						// Store cardholder's name
						$('#js-form-expiration-month').attr('value', value);
					}else {
						// Store cardholder's name
						$('#js-form-expiration-year').attr('value', value);
					}
				}
			}

			customValidate();
		});

		input.bind('input propertychange', function() {
			customValidate();
		});
		
	}

	/*
	* page5Handler - populates the content on page 5 from the form
	*/
	function page5Handler() {
		//return;
		var pages = $('.js-bcchf-steps-container .bcchf-steps');
		var donate_amt = $('#js-form-amount').val();
		var frequency = $('#js-form-frequency').val();
		var creditcard = $('#js-form-cardnumber').val();
		var expiry_month = $('#js-form-expiration-month').val();
		var expiry_year = $('#js-form-expiration-year').val();
		var billcycle = $('#js-form-bill-cycle').val();
		var firstname = $('#js-form-fname').val();
		var lastname = $('#js-form-lname').val();
		var email = $('#js-form-receipt-email').val();

		//console.log('donate_amt', donate_amt, 'frequency', frequency, 'creditcard', creditcard, 'expiry_month', expiry_month, 'expiry_year', expiry_year, 'billcycle', billcycle, 'firstname', firstname, 'lastname', lastname, 'email', email);

		// Do not display next if step5 is current page
		if ( $('#bcchf-step5').hasClass('js-bcchf-current-page') ) {
			$('.js-bcchf-btn-next').css('display', 'none');
		}

		// Handle Donation Amout
		$('.js-bcchf-donation-amt-review').text('$' + donate_amt);

		if ( frequency == 'once' ) {
			$('.js-bcchf-donation-duration-review').html('<br>ONCE')
		} else if (frequency == 'single'){
			$('.js-bcchf-donation-duration-review').html('<br>ONCE');
		} else {
			$('.js-bcchf-donation-duration-review').html('PER <br> MONTH');
		}

		// Handle Payment Info
		creditcard = creditcard.substring(creditcard.length-4, creditcard.length);
		$('.js-bcchf-cc-end-review').text(creditcard);

		$('.js-bcchf-exp-month-review').text(expiry_month);
		$('.js-bcchf-exp-year-review').text(expiry_year);

		if ( billcycle == '' ) {
			billcycle = 'Not Available';
			$('.bcchf-billing-cycle-confirmation').hide();
		}else if ( billcycle == 0 ) {
			billcycle = '1st';
			$('.bcchf-billing-cycle-confirmation').show();
		} else {
			billcycle = '15th';
			$('.bcchf-billing-cycle-confirmation').show();
		}

		$('.js-bcchf-billcycle-review').text(billcycle);

		// Handle Donor Info
		$('.js-bcchf-fname-review').text(firstname + ' ');
		$('.js-bcchf-lname-review').text(lastname + ' ');
		$('.js-bcchf-email-review').text(email);

		// Handle Donate Now button
		$('.js-bcchf-btn-donate-now').click(function(e){
			e.preventDefault();
			// show popup 
			$('.md-overlay').addClass('show');
			$('#' + $(e.currentTarget).attr('data-modal')).addClass('show');

			checkMobileDForm();
			//ajaxHandler($('#js-bcchf-donate-form'));
		});
	
	}

	/*
	* confirmationBoxHandler - populates the content on page 5 from the form
	*/
	function confirmationBoxHandler() {
		var pages = $('.js-bcchf-steps-container .bcchf-steps');
		var donate_amt = $('#js-form-amount').val();
		var frequency = $('#js-form-frequency').val();
		var creditcard = $('#js-form-cardnumber').val();
		var expiry_month = $('#js-form-expiration-month').val();
		var expiry_year = $('#js-form-expiration-year').val();
		var billcycle = $('#js-form-bill-cycle').val();
		var firstname = $('#js-form-fname').val();
		var lastname = $('#js-form-lname').val();
		var email = $('#js-form-receipt-email').val();
		var address = $('#js-form-address').val();
		var x = 'x';

		//console.log('donate_amt', donate_amt, 'frequency', frequency, 'creditcard', creditcard, 'expiry_month', expiry_month, 'expiry_year', expiry_year, 'billcycle', billcycle, 'firstname', firstname, 'lastname', lastname, 'email', email);

		// Do not display next if step5 is current page
		if ( $('#bcchf-step5').hasClass('js-bcchf-current-page') ) {
			$('.js-bcchf-btn-next').css('display', 'none');
		}

		// Handle Donation Amout
		$('.js-bcchf-donation-amt-confirmation').text('$' + donate_amt);

		if ( frequency == 'once' ) {
			$('.js-bcchf-donation-duration-confirmation').html('<br>ONCE')
		} else if (frequency == 'single'){
			$('.js-bcchf-donation-duration-review').html('<br>ONCE');
		} else {
			$('.js-bcchf-donation-duration-confirmation').html('PER <br> MONTH');
		}

		// Handle Billing Info
		for ( var i = 1; i < creditcard.length - 3; i++ ) {
			if ( i == 1 ) {
				x = 'x'
			} else {
				x += 'x';
			}

			if ( i % 4 == 0 ) {
				x += ' ';
			}
		}
		creditcard = creditcard.substring(creditcard.length-4, creditcard.length);

		$('.js-bcchf-cc-end-confirmation').text(x + creditcard);
		$('.js-bcchf-total-charge-confirmation').text('$' + donate_amt);
		$('.js-bcchf-receipt-confirmation').text(email);

		// User's Information
		$('.js-bcchf-fname-confirmation').text(firstname + ' ');
		$('.js-bcchf-lname-confirmation').text(lastname + ' ');
		$('.js-bcchf-address-confirmation').text(address);
	}

	/*
	* navigationHandler - handle the next and back buttons
	*/
	function navigationHandler() {
		$('.js-bcchf-btn-next').click(function(e){
			e.preventDefault();

			var current = $('.js-bcchf-current-page');
			var index = $(".js-bcchf-steps").index(current);
			var direction = '-=';
			var next = index + 1;
			var tab = $('.js-bcchf-current-page');
			var valid = true;

			$('input:visible, select:visible', tab).each(function(i, v) {
				// Validate Page 4
				page4Validate();

				valid = donate_validator.element(v) && valid;
			});

			if (! valid) {
				return;
			}else {
				//console.log('no erros');

				// Show prev button and remove paypal
				if ( $('.js-bcchf-btn-prev').hasClass('bcchf-btn-paypal') ) {
					$('.js-bcchf-btn-prev').removeClass('bcchf-btn-paypal');
				}

				// Show next page
				pageSlider(current, next, direction);

				customValidate();
			}
		});

		$('.js-bcchf-btn-prev').on('click tap', function(e){
			e.preventDefault();

			var current = $('.js-bcchf-current-page');
			var index = $(".js-bcchf-steps").index(current);
			var direction = '+=';
			var next = index - 1;

			// Do not proceed if the previous button is button Paypal
			if ( $(this).hasClass('bcchf-btn-paypal') ) {
				// do nothing !! //
				//document.payPalConnect.submit();
				//window.location = $('.bcchf-btn-paypal').attr('href');
				return;
			}

			// Display next button and hide the text
			if ( $('.js-bcchf-btn-next:hidden') ) {
				$('.js-bcchf-btn-next').css('display', 'block');
				$('.bcchf-btn-desc').css('display', 'none');
			}

			// Enable next button
			$('.js-bcchf-btn-next').removeClass('bcchf-btn-disabled');

			// Show prev page
			pageSlider(current, next, direction);
		});
	}

	/*
	* pageSlider - slide to next/prev page and set it up
	*/
	function pageSlider(current, next, direction) {
		var pages = $('.js-bcchf-steps-container .bcchf-steps');
		var screen_width = window.innerWidth;
		var offset = 250;

		// Remove warning message
		$('.js-bcchf-donate-warning').fadeOut(10);

		// Make the next page the new current page
		current.removeClass('js-bcchf-current-page');
		$(".js-bcchf-steps").eq(next).addClass('js-bcchf-current-page');

		// Hide next button if new current page is page5
		if ( $('.js-bcchf-current-page').attr('id') == 'bcchf-step5' ) {
			$('.js-bcchf-btn-next').css('display', 'none');
			$('.bcchf-btn-desc').css('display', 'block');
			page5Handler();
		}

		if ( $('.js-bcchf-current-page').attr('id') == 'bcchf-confirmation-box' ) {
			adjustPageHeight(20);
			confirmationBoxHandler();
		}else {
			adjustPageHeight(200);
		}

		pages.animate({
			left: direction + (screen_width + offset) + 'px'
		}, 300, function(){
			// scroll up
			$("html, body").stop().animate({ scrollTop: 0 }, 300);
		});

		// Change the back button to paypal if current page is page 1
		if ( $('.js-bcchf-current-page').attr('id') == 'bcchf-step1' ) {
			$('.js-bcchf-btn-prev').addClass('bcchf-btn-paypal');
			return;
		}
	}

	/*
	* adjustPageHeight - update the height of the parent container
	*/
	function adjustPageHeight(height_offset) {
		var screen_width = window.innerWidth;

		// Set offset for smaller screen
		if ( screen_width <= 640 && height_offset > 20 ) {
			$('.bcchf-donate-warning').css('bottom', '50px');
			height_offset = 100;
		}

		//console.log($('.js-bcchf-current-page').attr('id'), $('.js-bcchf-current-page').height());
		// Assign height to the form
		var steps_container_height = $('.js-bcchf-current-page').height() + height_offset;
		$('.js-bcchf-steps-container').css('height', steps_container_height);
	}

	/*
	* bcchfSlideUp - handle the hiding of new fields
	* @param: e - element
	* @param: s - speed
	* @param: callback - callback function
	*/
	function bcchfSlideUp(e) {
		$(e).slideUp(300, function(){
			adjustPageHeight(200);
		});
	}

	/*
	* bcchfSlideDown - handle the showing of new fields
	* @param: e - element
	* @param: s - speed
	* @param: callback - callback function
	*/	
	function bcchfSlideDown(e) {	
		$(e).slideDown(300, function(){
			adjustPageHeight(200);
		});
	}

	/*
	* customValidate - enable or disable the next button
	* - this is necessary because jquery validator
	* does not validate the fields before the submit/next button is clicked
	* except for the fields that requires specific format like email/credit card
	*/
	function customValidate(){
		var tab = $('.js-bcchf-current-page');
		var valid = true,
			valid_temp,
			radio_checked = true;

		$('input:visible, select:visible', tab).each(function(i, v){
			if ( $(this).is(':radio') ) {
				if ( $(this).siblings('.bcchf-btn').hasClass('bcchf-btn-disabled') ) {
					return;
				}

				var name = $(this).attr('name');
				if ($('input[name='+ name +']:checked').length) {
					radio_checked = true;
				}else {
					radio_checked = false;
				}

				if ( !radio_checked ) {
					valid_temp = false;
				}else {
					valid_temp = true;
				}
			}else {
				if ( !$(this).val() && $(this).attr('id') != 'js-bcchf-other-amt' ) {
					valid_temp = false;
				}else {
					valid_temp = true;
				}
			}

			valid = valid_temp && valid;
		});

		//console.log(valid);

		// If valid, enable the next button, otherwise disable
		if (valid) {
			$('.js-bcchf-btn-next').removeClass('bcchf-btn-disabled');
			if ( $('.js-bcchf-donate-warning:visible') ) {
				$('.js-bcchf-donate-warning').fadeOut(10);
			}
		} else {
			$('.js-bcchf-btn-next').addClass('bcchf-btn-disabled');
		}
	}

	/*
	* gotoPage - return to a previous page
	* @params: page_id - the page id (including the #)
	*/
	function gotoPage() {
		// Handle Edit buttons
		$('.bcchf-btn-edit').click(function(e){
			e.preventDefault();
			var href = $(this).attr('href');
			var href_pos = Math.round(Math.abs($(href).position().left));

			// Make the id of the edit button the new current page
			$('.js-bcchf-step5').removeClass('js-bcchf-current-page');
			$(href).addClass('js-bcchf-current-page');
			//console.log(href, href_pos);

			adjustPageHeight(200);

			// Display next button
			$('.js-bcchf-btn-next').show();
			$('.bcchf-btn-desc').hide();

			// Handle go to page
			$('.js-bcchf-steps').each(function(e){
				$(this).animate({
					'left': '+=' + href_pos + 'px'
				});
			});
		});
	}

	
	/*
	* ValidateExpDate - validate expiration date
	*/
	function ValidateExpDate() {
		var ccExpYear = 20 + $('#js-bcchf-expiration-year').val();
		var ccExpMonth = $('#js-bcchf-expiration-month').val();
		var expDate = new Date();
		expDate.setFullYear(ccExpYear, ccExpMonth, 1);

		var today = new Date();
		if (expDate < today) {
			$('#js-bcchf-lb-expiration-month').addClass('error');
			customValidate();
		} else {
			$('#js-bcchf-lb-expiration-month').removeClass('error');
			customValidate();
		}
	}

	/*
	* page4Validate - validates values on page 4
	* @return: is_valid - boolean value
	*/
	function page4Validate() {
		// If first name is still empty, keep the error message on the label
		if ( $('#bcchf-step4').hasClass('js-bcchf-current-page') ) {
			if ( ! $('#js-bcchf-expiration-month').val() || ! $('#js-bcchf-expiration-year').val() ) {
				$('#js-bcchf-lb-expiration-month').addClass('error');
				if ( $('.js-bcchf-donate-warning').is(':hidden') ) {
					$('.js-bcchf-donate-warning').fadeIn(500);
				}
			}else {
				$('#js-bcchf-lb-expiration-month').removeClass('error');
				if ( $('.js-bcchf-donate-warning').is(':visible') ) {
					$('.js-bcchf-donate-warning').fadeOut(500);
				}
			}
		}
	}

	/*
	* validateLogin - populates the content on page 5 from the form
	*/
	function validateLogin() {
		// Validate Login form
		$("#js-bcchf-login-form").validate({
			rules: {
				js_bcchf_username: {
					required: true,
					minlength: 3
				},
				js_bcchf_password: {
					required: true,
					minlength: 3
				}
			},
			errorContainer: "#js-bcchf-error-messages",
			errorLabelContainer: "#js-bcchf-error-messages ul",
			wrapper: "li",
			debug:true,
			highlight: function(element, errorClass, validClass) {
				$(element).addClass(errorClass).removeClass(validClass);
				$(element.form).find("label[for=" + element.id + "]").addClass(errorClass);
			},
			unhighlight: function(element, errorClass, validClass) {
				$(element).removeClass(errorClass).addClass(validClass);
				$(element.form).find("label[for=" + element.id + "]")
				.removeClass(errorClass);
			},
			messages: {
				js_bcchf_username: "Please enter a username.",
				js_bcchf_password: "Please enter a password."
			},
			submitHandler: function(form) {
				//ajaxHandler($('#js-bcchf-login-form'));
				form.submit();
			}
		});
	}

	/*
	* validateForgot - populates the content on page 5 from the form
	*/
	function validateForgot() {
		// Validate Forgot form - Email
		$("#js-bcchf-forgot-password-form").validate({
			rules: {
				js_bcchf_username: {
					required: true,
					minlength: 3
				}
			},
			errorContainer: "#js-bcchf-error-username",
			errorLabelContainer: "#js-bcchf-error-username ul",
			wrapper: "li",
			highlight: function(element, errorClass, validClass) {
				$(element).addClass(errorClass).removeClass(validClass);
				$(element.form).find("label[for=" + element.id + "]").addClass(errorClass);
			},
			unhighlight: function(element, errorClass, validClass) {
				//console.log('no errror');
				$(element).removeClass(errorClass).addClass(validClass);
				$(element.form).find("label[for=" + element.id + "]")
				.removeClass(errorClass);
			},
			messages: {
				js_bcchf_username: "Please enter a username."
			},
			submitHandler: function(form) {
				form.submit();
			}
		});

		// Validate Forgot form - Username
		$("#js-bcchf-forgot-username-form").validate({
			rules: {
				js_bcchf_email: {
					email: true,
					required: true,
					minlength: 5
				}
			},
			errorContainer: "#js-bcchf-error-email",
			errorLabelContainer: "#js-bcchf-error-email ul",
			wrapper: "li",
			highlight: function(element, errorClass, validClass) {
				$(element).addClass(errorClass).removeClass(validClass);
				$(element.form).find("label[for=" + element.id + "]").addClass(errorClass);
			},
			unhighlight: function(element, errorClass, validClass) {
				$(element).removeClass(errorClass).addClass(validClass);
				$(element.form).find("label[for=" + element.id + "]")
				.removeClass(errorClass);
			},
			messages: {
				js_bcchf_email: "Please enter an email address."
			},
			submitHandler: function(form) {
				//ajaxHandler($('#js-bcchf-forgot-username-form'));
				form.submit();
			}
		});
	}

	/*
	* validateDonate - populates the content on page 5 from the form
	*/
	function validateDonate() {
		// Add method to handle postal code and zip code validation
		jQuery.validator.addMethod('zipcode', function(value) {
		  return /\b[0-9]{5}(?:-[0-9]{4})?\b/.test(value);
		}, 'Please enter a valid US zip code.');

		jQuery.validator.addMethod('postalcode', function(value) {
		  return /^[A-Za-z]\d[A-Za-z][\s]?\d[A-Za-z]\d$/.test(value);
		}, 'Please enter a valid Canadian postal code.');
		
		// Validate Donate Form
		donate_validator = $('#js-bcchf-donate-form').validate({
			ignore: ".bcchf-btn-prev",
			debug: true,
			ignoreTitle: true,
			rules: {
				js_bcchf_donate_type: {
					required: true,
				},
				js_bcchf_corpo_name: {
					required: {
						depends: function(element){
							if ( $('#js-bcchf-donate-type').val() == 'corporate' ) {
								return true;
							}else {
								return false;
							}
						}
					},
					minlength: 5
				},
				js_bcchf_gift_type: {
					required: true,
				},
				js_bcchf_honour: {
					required: {
						depends: function(element){
							if ( $('#js-bcchf-gift-type').val() == 'honour' || $('#js-bcchf-gift-type').val() == 'memory' ) {
								return true;
							}else {
								return false;
							}
						}
					},
					minlength: 5
				},
				js_bcchf_send_email: {
					required: {
						depends: function(element){
							if ( $('#js-bcchf-gift-type').val() == 'honour' || $('#js-bcchf-gift-type').val() == 'memory' ) {
								return true;
							}else {
								return false;
							}
						}
					}
				},
				js_bcchf_recepient_email: {
					required: {
						depends: function(element){
							if ( ($('#js-bcchf-gift-type').val() == 'honour' || $('#js-bcchf-gift-type').val() == 'memory') && $('#js-bcchf-send-email-yes').hasClass('bcchf-active') ) {
								return true;
							}else {
								return false;
							}
						}
					},
					email: true,
					minlength: 5
				},
				js_bcchf_pledge_id: {
					required: {
						depends: function(element){
							if ( $('#js-bcchf-gift-type').val() == 'pledge' ) {
								return true;
							}else {
								return false;
							}
						}
					},
					minlength: 3
				},
				js_bcchf_donation_frequency: {
					required: true
				},
				js_bcchf_donation_amount: {
					required: {
						depends: function(element){
							if ( $('.js-bcchf-frequency').hasClass('bcchf-active') && ! $('#js-bcchf-other-amt').val() ) {
								return true;
							}else {
								return false;
							}
						}
					}
				},
				js_bcchf_other_amt: {
					required: {
						depends: function(element){
							if ( $('.js-bcchf-frequency').hasClass('bcchf-active') && ! $('.js-bcchf-amount').hasClass('bcchf-active') ) {
								return true;
							}else {
								return false;
							}
						}
					},
					//digits: true,
					number: true,
				},
				js_bcchf_bill_cycle: {
					required: {
						depends: function(element){
							if ( $('#js-bcchf-frequency-monthly').hasClass('bcchf-active') ) {
								return true;
							}else {
								return false;
							}
						}
					},
				},
				js_bcchf_firstname: {
					required: true,
					minlength: 2
				},
				js_bcchf_lastname: {
					required: true,
					minlength: 2
				},
				js_bcchf_email: {
					required: true,
					email: true,
					minlength: 5
				},
				js_bcchf_allow_email: {
					required: true,
				},
				js_bcchf_cardholder: {
					required: true,
					minlength: 4
				},
				js_bcchf_cardnumber: {
					required: true,
					creditcard: true
				},
				js_bcchf_expiration_month: {
					required: true
				},
				js_bcchf_expiration_year: {
					required: true
				},
				js_bcchf_country: {
					required: true
				},
				js_bcchf_cvv: {
					required: true,
					digits: true,
					minlength: 3,
					maxlength: 4
				},
				js_bcchf_address: {
					required: true,
					minlength: 8
				},
				js_bcchf_city: {
					required: true,
					minlength: 2
				},
				js_bcchf_province: {
					required: {
						depends: function(element){
							if ( $('#js-bcchf-country').val() == 'CA' || $('#js-bcchf-country').val() == 'US' || $('#js-bcchf-country').val() == 'Canada') {
								return true;
							}else {
								return false;
							}
						}
					}
				},
				
				js_bcchf_postal: {
					required: true,
					postalcode: {
						depends: function(element){
							if ( $('#js-bcchf-country').val() == 'CA' || $('#js-bcchf-country').val() == 'Canada') {
								return true;
							}else {
								return false;
							}
						}
					},
					zipcode: {
						depends: function(element){
							if ( $('#js-bcchf-country').val() == 'US') {
								return true;
							}else {
								return false;
							}
						}
					},
					minlength: 4
				},
				js_bcchf_phone: {
					required: true,
					minlength: 5
				}
			},
			errorContainer: ".js-bcchf-donate-warning",
			errorLabelContainer: ".js-bcchf-donate-warning",
			wrapper: ".js-bcchf-donate-warning",
			highlight: function(element, errorClass, validClass) {
				$(element).addClass(errorClass).removeClass(validClass);
				// support multiple fields for one label; use the name attribute to match the label instead
				if ( $(element.form).find("label[for=" + element.id + "]").length == 0 ) {
					$(element.form).find("label[for=" + element.name + "]").addClass(errorClass);
				}else {
					$(element.form).find("label[for=" + element.id + "]").addClass(errorClass);
				}
			},
			unhighlight: function(element, errorClass, validClass) {
				// Keep the error message if the first name is still empty
				if ( ! $('#js-bcchf-fname').val() && $('#bcchf-step3').hasClass('js-bcchf-current-page') ) {
					$(element.form).find("label[for=js-bcchf-lname]").addClass(errorClass);
					return;
				}else {
					$(element).removeClass(errorClass).addClass(validClass);
					// support multiple fields for one label; use the name attribute to match the label instead
					if ( $(element.form).find("label[for=" + element.id + "]").length == 0 ) {
						$(element.form).find("label[for=" + element.name + "]").removeClass(errorClass);
					}else {
						$(element.form).find("label[for=" + element.id + "]").removeClass(errorClass);
					}

					// Manually remove the error icon to handle first name
					if ( $('#js-bcchf-lname').val() ) {
						$(element.form).find("label[for=js-bcchf-lname]").removeClass(errorClass);
					}
				}
			},
 			messages: {},
		});
	}

	/*
	* initModalEffects - handles the popup
	* modalEffects.js v1.0.0
 	* http://www.codrops.com
	*/
	function initModalEffects() {
		$('.js-bcchf-rth-link').click(function(e) {
			e.preventDefault();
			$('.js-bcchf-popup-bg').addClass('show');
			$('#' + $(e.currentTarget).attr('href')).addClass('show');
		});

		$('.js-bcchf-continue-donation, .js-bcchf-close-process-popup, .js-bcchf-return-to-payment').click(function(e) {
			e.preventDefault();
			$('.js-bcchf-popup-bg').removeClass('show');
			$(e.currentTarget).parents('.bcchf-pop-up').removeClass('show');
		});

		$('.js-bcchf-btn-error').click(function(e) {
			e.preventDefault();
			$('.js-bcchf-popup-bg').addClass('show');
			$('#' + $(e.currentTarget).attr('data-modal')).addClass('show');
		});
	}

	/* ajaxHandler - submits the values of form to database using AJAX
	***********************************************/
	function ajaxHandler(form){
		var url = form.attr('action');
		
		$.ajax({
			type: 'POST',
			url: url + 'https://secure.bcchf.ca/API/api.cfm/donate/Donation.json',		
			data: form.serializeJSON(),
			
        	dataType: "json",
	
			success: function(data){
				// on Success of Donate Page
				if ( form.attr('id') == 'js-bcchf-donate-form' ) {
					$('.js-bcchf-close-process-popup').trigger('click');

					// Show final confirmation page
					$('.js-bcchf-btn-next').trigger('click');
					$('.bcchf-step-button').css('display', 'none');
				} else {
					// on Success of Login and Forgot Page
					return;
				}
				//console.log('success');
			},
			error: function(){
				// on Error of Donate Page
				if ( form.attr('id') == 'js-bcchf-donate-form' ) {
					$('.js-bcchf-close-process-popup').trigger('click');

					// Show Error Popup
					$('.js-bcchf-btn-error').trigger('click');
				} else {
					// on Error of Login and Forgot Page
					//return;
					alert('URL needed for Form');
				}
				//console.log('error');
			}
		});
	}

	/* Capitalize values
	***********************************************/
	String.prototype.capitalize = function(){
		return this.replace( /(^|\s)([a-z])/g , function(m,p1,p2){ return p1+p2.toUpperCase(); } );
	};
	
})(jQuery);


function checkMobileDForm() {
	ColdFusion.Ajax.submitForm('js-bcchf-donate-form', 'processDonation.cfc?method=submitMobileDonationForm&returnFormat=JSON', mdonationResultHandler, mdonationErrorHandler);
	
}

function checkMobileDFormPayPal() {
	// open the modal box for processing donation 
	var d = document.getElementById("bcchf-modal-5");
		d.className = d.className + " show";
	
	//toggleDivOff('cardPaymentOptions-container');
	
	
	ColdFusion.Ajax.submitForm('js-bcchf-donate-form', 'processDonation.cfc?method=submitMobileDonationFormPayPal&returnFormat=JSON', mdonationResultHandlerPayPal, mdonationErrorHandler);
	
}

function mdonationResultHandlerPayPal(result) {
	
	//new JSON parser
	var donationReturnProcess = json_parse(result);
	/// DONATION success 1 or 0
	var donationSuccessful = donationReturnProcess.SUCCESS;
	// response message 
	var responseMSG = donationReturnProcess.MESSAGE;
	// UUID of transaction
	var UUID = donationReturnProcess.UUID;
	//check for event
	var eventToken = donationReturnProcess.EVENTTOKEN;
	
	// if error / decline - display message
	if (donationSuccessful == 0){
		// check message 
		
		var d = document.getElementById("bcchf-modal-3");
		d.className = d.className + " show";
		
		/*$('.js-bcchf-btn-error').click(function(e) {
			e.preventDefault();
			$('.js-bcchf-popup-bg').addClass('show');
			$('#' + $(e.currentTarget).attr('data-modal')).addClass('show');
		}); */
		
		//toggleDivOn('bcchf-modal-3');
		//toggleDivOff('bcchf-modal-2');
		
		if(donationReturnProcess.CHARGEATTMPT.CATTEMPTED == 1){
			// attempted charging - get e-xact response
			
			// charge attempted
			// get the response code
			var rqst_exact_respCode = donationReturnProcess.CHARGEATTMPT.EXACT_RESPCODE;
			
			if(donationReturnProcess.CHARGEATTMPT.GOODXDS == 0){
				// Session expired - message to refresh 
				var textMessage = 'Your Session has Expired. Please refresh your browser and try your donation again.';
			}
			else {
				// use exact response code to construct error message 
				// get what the response code means
				var textMessage = exactMessages(rqst_exact_respCode);
			}
			
			
			
			// redirect if IP has now been blocked 
			// that means too many failed attempts by this IP
			if(donationReturnProcess.CHARGEATTMPT.IPBLOCKER == 1){
				//window.location='../error/SHPerror.cfm?Err=10';
			}
			
		}
		else{
			// did not attempt charge but returned error
			/// log error
			alert('Some error happened');
			var textMessage = 'Some error happened';
						
		}
			
		// write response to page
		//toggleDivOn('exactResponseNegative');
		//toggleDivOn('topExactResponseNegative');
		document.getElementById('exactResponseNegative').innerHTML='<p><strong>Message: '+textMessage+'</strong></p>';
		//document.getElementById('topExactResponseNegative').innerHTML='&nbsp;<br /><span class="registerError"><strong>Your transaction was not successful.<br />Message: '+textMessage+'</strong></span><br />&nbsp;';
		
	} else if (donationSuccessful == 1){
		// send user to paypal checkout with details to confirm
		var d = document.getElementById("bcchf-modal-6");
		d.className = d.className + " show";
		
		shouldsubmit=true;
		
		
		payPalExpress = donationReturnProcess.CHARGEATTMPT.PPEXURL;
		
		window.location=payPalExpress;
		
		
	}
	
	
}


function mdonationResultHandler(result) {

	// remove card number and CVV from from
	//document.getElementById('post_card_number').value='';
	//document.getElementById('post_CVV').value='';
	
	//new JSON parser
	var donationReturnProcess = json_parse(result);
		
	/// DONATION success 1 or 0
	var donationSuccessful = donationReturnProcess.SUCCESS;
	
	// response message 
	var responseMSG = donationReturnProcess.MESSAGE;
	
	// charging messages 
	// 0 - no charge
	// 1 - charge attempt
	
	// e-xact success
	// e-xact response
	
	// UUID of transaction
	var UUID = donationReturnProcess.UUID;
	
	//sendToTracer('UUID:'+UUID);
	
	//check for event
	var eventToken = donationReturnProcess.EVENTTOKEN;
	
	
	// if error / decline - display message
	if (donationSuccessful == 0){
		// check message 
		
		var d = document.getElementById("bcchf-modal-3");
		d.className = d.className + " show";
		
		var d = document.getElementById("bcchf-modal-2");
		d.className = "bcchf-pop-up bcchf-processing-box js-bcchf-processing-box";
		
		/*$('.js-bcchf-btn-error').click(function(e) {
			e.preventDefault();
			$('.js-bcchf-popup-bg').addClass('show');
			$('#' + $(e.currentTarget).attr('data-modal')).addClass('show');
		}); */
		
		//toggleDivOn('bcchf-modal-3');
		//toggleDivOff('bcchf-modal-2');
		
		// if we are NOT charging and there is an error
		if(donationReturnProcess.CHARGEATTMPT.CATTEMPTED == 1){
			// attempted charging - get e-xact response
			
			// charge attempted
			// get the response code
			var rqst_exact_respCode = donationReturnProcess.CHARGEATTMPT.EXACT_RESPCODE;
			
			if(donationReturnProcess.CHARGEATTMPT.GOODXDS == 0){
				// Session expired - message to refresh 
				// 
				var textMessage = 'Your Session has Expired. Please refresh your browser and try your donation again.';
			}
			else {
				// use exact response code to construct error message 
				// get what the response code means
				var textMessage = exactMessages(rqst_exact_respCode);
			}
			
			
			
			// redirect if IP has now been blocked 
			// that means too many failed attempts by this IP
			if(donationReturnProcess.CHARGEATTMPT.IPBLOCKER == 1){
				//window.location='../error/SHPerror.cfm?Err=10';
			}
			
		}
		else{
			// did not attempt charge but returned error
			/// log error
			alert('Some error happened');
			var textMessage = 'Some error happened';
						
		}
			
		// write response to page
		//toggleDivOn('exactResponseNegative');
		//toggleDivOn('topExactResponseNegative');
		document.getElementById('exactResponseNegative').innerHTML='<p><strong>Message: '+textMessage+'</strong></p>';
		//document.getElementById('topExactResponseNegative').innerHTML='&nbsp;<br /><span class="registerError"><strong>Your transaction was not successful.<br />Message: '+textMessage+'</strong></span><br />&nbsp;';
		
	}
	else if (donationSuccessful == 1){
		// move to next step (confirmation page)
		
		// a couple of control measures on the form in case we fail to move to next step
		
		var d = document.getElementById("bcchf-modal-4");
		d.className = d.className + " show";
		
		var d = document.getElementById("bcchf-modal-2");
		d.className = "bcchf-pop-up bcchf-processing-box js-bcchf-processing-box";
		
		//toggleDivOff('bcchf-modal-2');
		//toggleDivOn('bcchf-modal-4');
		
		//document.getElementById('donationWaitMessage-container').innerHTML = 'Donation Successful';
		//toggleDivOff('exactResponseNegative');
		//toggleDivOff('topExactResponseNegative');
		
		//toggleDivOff('mainDonationForm-container');
		//toggleDivOn('mainDonationFormWaitMessage-container');
		//document.getElementById('donationWaitMessage-container').innerHTML = 'Donation Successful, Thank You.';
		
		
		// move to confirmation page
		if (eventToken == 'HolidaySnowball'){
			window.location='completeDonation-Snowball.cfm?Event='+eventToken+'&UUID='+UUID;
		} else {
			window.location='completeDonation-mobile.cfm?Event='+eventToken+'&UUID='+UUID;
		}
		
		
	}
	else{
		alert('error in response message');
		//alert(donationReturnProcess);
	}
	
	/**/
}

// error responses
function mdonationErrorHandler(code, msg) 
    { 
        alert("Error!!! " + code + ": " + msg); 
		// re-open form
		
		// check message 
		
		toggleDivOn('bcchf-modal-3');
		toggleDivOff('bcchf-modal-2');
		
		//alert('Unknown error');
		var textMessage = 'An unknown error occurred';
						
			
		// write response to page
		toggleDivOn('exactResponseNegative');
		toggleDivOn('topExactResponseNegative');
		document.getElementById('exactResponseNegative').innerHTML='&nbsp;<br /><span class="registerError"><strong>Transaction not successful.<br />Message: '+textMessage+'</strong></span><br />&nbsp;';
		document.getElementById('topExactResponseNegative').innerHTML='&nbsp;<br /><span class="registerError"><strong>Your transaction was not successful.<br />Message: '+textMessage+'</strong></span><br />&nbsp;';
		
    } 
