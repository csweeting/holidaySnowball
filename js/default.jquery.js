/***************************************************************************************************
*   default.jquery.js
*
*   This is a default javascript file.
*
*   For this file, only global javascript functions allowed.
*   If additional functions are required, those functions must be put
*   into the proper module.
*
*   @copyright     2015 CAMP PACIFIC
*
*   @authors       Cindy Son, Technical Director <cindy.son@camppacific.com>
*                  Gabrielle Carson, Sr. Front-End Developer <gabrielle.carson@camppacific.com>
*                  Mihai Lazar, Sr. Full Stack Developer <mihai.lazar@camppacific.com>
*                  Patrick Javier, Jr. Front-End Developer <patrick.javier@camppacific.com>
*
*   @since			October 1, 2015
*
*   @category      Javascript
*   @package		bcchf-donation
*   @subpackage	js
*
* TABLE OF CONTENTS
*
* A - GLOBAL VARIABLES
* B - WINDOW LOAD
* C - DOCUMENT READY
**************************************************************************************************/

jQuery.noConflict();
/* global jQuery */
(function() {
	'use strict';

	/* A - GLOBAL VARIABLES
	***********************************************/
	var app;
	
	/**
	* App  Main application javascript
	*/
	var	App = {
		inputs: jQuery('input'),
		textareas: jQuery('textarea'),
		selects: jQuery('.js_bcchf_custom_select'),
		submit_btn: jQuery('.js_bcchf_submit'),
		form: jQuery('form'),
		review_sections: jQuery('.js_bcchf_review span'),
		donation_steps: jQuery('.js_bcchf_step'),
		donation_slider: null,
		progress_bar: jQuery('.js_bcchf_progress'),
		progress_num: jQuery('.js_bcchf_step_num'),
		validator: null,
		
		
		

		/**
		* init  Initializes the app
		*/
		init: function() {
			app = this;
			
			// Initialize pages
			this.initThankyouPage();
			this.initSurveyPage();
			this.initDonationPage();

			// Initialize custom dropdown
			this.initCustomDropdown();

			// Initalize radio inputs
			this.initRadioButtons();
			
			
			var sup_pge_UUID = jQuery('#sup_pge_UUID').val();
		
			if (sup_pge_UUID == ''){
				//console.log('new form');
			} else {
				/// there is a ID present
				/// returning from a cancelled PayPal transaction
				//console.log('existing form');
				// move to S3 and display cancelled message
				jQuery('.js_bcchf_next').trigger('click');
				setTimeout(function(){
					jQuery('.js_bcchf_next').trigger('click')
					}, 500);
				jQuery('#s3topMSG').html("<p style='color:#F00; font-size:14px;'>&nbsp;<br /><span class='registerError'><strong>There was an error processing your donation. Your transaction has been cancelled. <br />Please choose a payment option to make a donation, or call 604-875-2444 to speak to a donor services representative.<br />Please note the Foundation's hours of operation are Monday - Friday, 8:30 a.m. to 5:00 p.m.</strong></span></p>");
			}
		},

		/**
		* initCustomDropdown  Initialize all the custom dropdowns so we can
		* trigger the underlying select element when a selection is chosen. Also validates,
		* the select input when an option is selected.
		*/
		initCustomDropdown: function() {
			var custom_selects = jQuery('.js_bcchf_custom_select'),
				ul = jQuery('.js_bcchf_custom_select ul'),
				li = custom_selects.find('li'),
				//country = jQuery('.js_bcchf_country li.active'),
				//province = jQuery('.js_bcchf_dropdown_container'),
				selects = jQuery('select'),
				target, parent, select, options, postal_code;

				// postal_error = 'Please enter a valid postal code using uppercase letters.';
			li.on('click', function(e) {
				target = jQuery(e.currentTarget);
				var index = target.index();
				// The parent container
				parent = target.parents('.js_bcchf_custom_select');

				// The underlying select input
				select = parent.find('select');
				options = select.find('options');

				parent.find('select option:eq(' + index + ')').prop('selected', true);

				validateSelect(custom_selects, e);
				select.removeClass('error');

				// Close any already opened dropdowns so only one can be opened at a time
				custom_selects.not(parent).removeClass('open');

				// If the parent is closed, open it
				if (!parent.hasClass('open')) {
					parent.addClass('open');
				} else {
					ul.scrollTop(0);
					// Update the active selection and the underlying select input
					if (!target.hasClass('active')) {
						select.val(target.attr('data-value'));
						target.siblings('.active').html(target.html());
						parent.removeClass('open');

						validateSelect(select, e);

					} else {
						// Close the dropdown when the default option is selected
						parent.removeClass('open');
					}
				}
			});

			// disable back navigation key 13 (return) for FireFox
			jQuery(document).keypress(function(e) {
				var moveNext = e.target.classList.contains('bcchf_next');

				if ((e.keyCode ? e.keyCode : e.which) == 13 && !moveNext) {
					e.preventDefault();
				}
			});

			// We need to detect the change event on the underlying select
			// in case the user autofills. This will update the visual
			// select box and validates the select
			selects.on('change focus keyup keydown', function(e) {
				var ul = jQuery(e.currentTarget).siblings('ul'),
					value = ul.find('[data-value="' + e.currentTarget.value + '"]' ).html(),

				active = ul.find('.active');

				if (e.currentTarget.value.length === 0) {
					value = '<span>' + e.currentTarget[0].innerHTML + '</span>';
				}

				active.html(value);

				// If it's the country dropdown, hide the province dropdown
				// if it's not US or Canada
				/*
				if (e.currentTarget.getAttribute('name') === 'bcchf_country') {
					hideProvinces(e.currentTarget.value);
				} */

				if(e.type === 'keyup' || e.type === 'change') {
					// Validate the input if it's required
					// Uses jquery validation plugin valid function
					validateSelect(jQuery(e.currentTarget), e);
				}

			});

			// Hides province input selection if country is neither Canada or US
			/*
			jQuery('.js_bcchf_country').on('click', function(e) {
				hideProvinces(country.text());
			});
			*/


			/**
			* hideProvinces  Hide the province dropdown based on the value of the country select
			
			function hideProvinces(value) {
				province.addClass('hide');

				if (value === 'CA' || value === 'US' || value === '' ||
					value == 'Canada' || value == 'United States of America' || value == "Please select one...") {
					province.removeClass('hide');
				}
			}*/


			/**
			* validateSelect  Validates the select inputs
			*/
			function validateSelect(select, e) {
				// Validate the input if it's required
				// Uses jquery validation plugin valid function

				var ul = jQuery(select).siblings('ul');

				if (select.attr('aria-required')) {
					if (select.valid()) {
						app.unhighlight(e.currentTarget);
						select.prev().removeClass('error');
						select.parents('.js_bcchf_input_container').find('.error').empty();
					} else {
						select.prev().addClass('error');
						select.parents('.js_bcchf_input_container').removeClass('valid');
					}
				}

				// If this select is a country, validate the postal code
				/*
				if (select.attr('name') === 'bcchf_country') {
					postal_code = jQuery('#bcchf_postal_code');
					app.unhighlight(postal_code[0]);

					if (!postal_code.valid()) {
						app.highlight(postal_code[0]);
						app.errorPlacement(postal_code[0], app.validator.errorList[0]);
					}
				} */
			}
		},

		/**
		* initRadioButtons  If the user selects a radio button
		* that also has text input, we need to handle it in a special way.
		*/
		initRadioButtons: function() {
			var radio = this.inputs.filter('.js_bcchf_radio_with_text'),
				input = radio.parent().find('input[type="text"]'),
				form = radio.parents('form'),
				p = input.siblings('p');

			// On focus, add focus to its text inputs
			radio.on('focus', function() {
				input.focus();
			});

			// Update the radio button value and the visible copy
			input.on('keyup', function(e) {
				radio.val(input.val().trim());
				p.html(input.val().trim());

				// We want to validate the radio value as we're typing
				if (input.valid()) {
					app.unhighlight(e.currentTarget);
				}

				if (input.val().trim().length === 0) {
					p.html('Other');
				}
			});

			input.on('blur', function(e) {
				if (!jQuery(e.currentTarget).valid()) {
					app.highlight(e.currentTarget);
					app.errorPlacement(e.currentTarget, app.validator.errorList[0]);
				}
			});
		},

		/**
		* initStepSlider  Initializes the form on the thankyou page
		*/
		initStepSlider: function(e) {
			//var progress = 1;
			var donor_first_name = this.inputs.filter('[name="bcchf_donor_first_name"]'),
				donor_last_name = this.inputs.filter('[name="bcchf_donor_last_name"]'),
				corporate_donor = this.inputs.filter('[name="bcchf_donor_company_name"]'),
				first_name = this.inputs.filter('[name="bcchf_first_name"]'),
				last_name = this.inputs.filter('[name="bcchf_last_name"]'),
				corporate_name = this.inputs.filter('[name="bcchf_company_name"]');


			jQuery('.js_bcchf_next').on('click', function(e) {
				e.preventDefault();
				var required_inputs = app.form.find('input, textarea, select').filter('[aria-required="true"]').remove('input[name="bcchf_donor_first_name"]');
				var continue_step = true;
				//console.log(app.form[0].slick.currentSlide);

				jQuery.each(required_inputs, function( key, input ) {

					if (!jQuery(input).valid()) {
    					app.highlight(input);
    					app.errorPlacement(input, app.validator.errorList[0]);
    					continue_step = false;

    					return;
    				}
				});

				if(!continue_step) {
					app.form.slick('slickGoTo', app.form[0].slick.currentSlide, false);
				}

				return false;
			});


			//console.log('wtf am i doing here'+app.form[0].slick.currentSlide);
			// slider setting
			this.donation_slider = jQuery('.js_bcchf_donation').slick({
				accessibility: false,
				slidesToScroll: 1,
				nextArrow: jQuery('.js_bcchf_next'),
				prevArrow: jQuery('.js_bcchf_return'),
				draggable: false,
				infinite: false,
				swipe:false,
				swipeToSlide:false,
				touchMove:false
			});

			// Remove the ignore_validation class to the current slide so we can validate it
			this.donation_slider.on('afterChange', function(slick, current_slide) {
				app.donation_steps.eq(current_slide.currentSlide).removeClass('ignore_validation');

				// If next slide is step 2, we need to validate the populated
				// inputs so it shows as valid
				if (current_slide.currentSlide === 1) {

					first_name.parent().removeClass('valid');
					last_name.parent().removeClass('valid');

					if (first_name.val() !== '') {
						app.unhighlight(first_name[0]);

						if (!first_name.valid()) {
							app.highlight(first_name);
	    					app.errorPlacement(first_name, app.validator.errorList[0]);
							first_name.parent().removeClass('valid');
						}
					}

					if (last_name.val() !== '') {
						app.unhighlight(last_name[0]);
						if (!last_name.valid()) {
							app.highlight(last_name);
	    					app.errorPlacement(last_name, app.validator.errorList[0]);
							last_name.parent().removeClass('valid');
						}
					}
				}
				
				//scroll up when slide changes
				window.scrollTo(0, 0);
				/*jQuery('html, body').animate({
					scrollTop: jQuery('.js_bcchf_progress').offset().top + (-20)
				}, 750); */
			});

			// Add the ignore_validation class to the previous slide so we can ignore validating it
			// if it's offscreen. Also, update the progress bar at this point as well.
			
			this.donation_slider.on('beforeChange', function(e, slick, current_slide, next_slide) {
				app.donation_steps.eq(current_slide).addClass('ignore_validation');
				app.donationPageHandler();

				// update progress bar
				app.progress_bar.removeClass(app.progress_bar.attr('class').match(/\bbcchf_progress_step\S+/g).join(' '));
				app.progress_bar.addClass('bcchf_progress_step' + (next_slide + 1));
				app.progress_num.html(next_slide + 1);

				// If next slide is step 2, get data from step 1 and prepopulate
				if (next_slide === 1 && current_slide === 0) {
					if (jQuery('.js_bcchf_personal').hasClass('hide')) {
						if (corporate_donor.val() !== '') {
							corporate_name.val(corporate_donor.val());
						}
					} else {
						if (donor_first_name.val() !== '') {
							first_name.val(donor_first_name.val());
						}

						if (donor_last_name.val() !== '') {
							last_name.val(donor_last_name.val());
						}
					}
				}
			});
		},


		/**
		* initThankyouPage  Initializes the form on the thankyou page
		*/
		initThankyouPage: function() {
			var ack_card_form = this.form.filter('.js_bcchf_ack_card'),
				card_select = ack_card_form.find('input[name="bcchf_send_card"]'),
				sections = ack_card_form.find('.js_bcchf_send_card');

			// Initalize the acknowledgement card form
			if (ack_card_form.length > 0) {

				// Hide or show the form depending on the user's selection
				card_select.on('change', function(e) {

					// Show the selected sections
					sections.filter('#js_' + e.currentTarget.id).removeClass('hide');

					// Hide the other section
					sections.not('#js_' + e.currentTarget.id).addClass('hide');
				});


				// When they autofill, we need to run the validation
				this.inputs.filter('[type="text"]').on('change', this, function(e) {
					if (jQuery(e.currentTarget).valid()) {
						e.data.unhighlight(e.currentTarget);
					} else {
						app.highlight(e.currentTarget);
						app.errorPlacement(e.currentTarget, app.validator.errorList[0]);
					}
				});

				this.inputs.filter('[type="email"]').on('change', this, function(e) {
					if (jQuery(e.currentTarget).valid()) {
						e.data.unhighlight(e.currentTarget);
					}
				});

				// Initialize validation
				this.initValidation(ack_card_form);

			}
		},

		/**
		 * initDonationPage  Initializes the form on the donation page (General Form)
		 */
		initDonationPage: function() {
			var donation_form = this.form.filter('.js_bcchf_donation'),
				dedication_type = donation_form.find('input[name="bcchf_donation_honour"]'),
				dedication_sections = donation_form.find('.js_bcchf_donation_honour'),
				//donor_name_select = donation_form.find('.js_bcchf_donor_name'),
				donor_name_corporate = donation_form.find('.js_bcchf_donor_corporate'),
				donor_name_personal = donation_form.find('.js_bcchf_donor_personal'),
				trib_hon_name = donation_form.find('input[name="bcchf_in_honour_name"]'),
				trib_mem_name = donation_form.find('input[name="bcchf_in_memory_name"]'),
				donor_names = donation_form.find('.js_bcchf_donor_container'),
				goto_button = donation_form.find('.js_bcchf_goto'),
				donation_types = donation_form.find('[name="bcchf_donation_type"]'),
				donation_radios = this.inputs.filter('[name="bcchf_gift_amount"]').not('.js_bcchf_radio_with_text'),
				donation_type_copy = donation_form.find('.js_bcchf_donation_amt'),
				donation_frequency = donation_form.find('.js_bcchf_monthly'),
				donation_pledge = donation_form.find('.js_bcchf_pledge'),
				donation_selected = false,
				_this = this;

			// Initalize the donation page form
			if (donation_form.length > 0) {
				// Character count in textbox
				_this.textCounter();
				
				// remove card number and CVV from from
				document.getElementById('bcchf_cc_number').value='';
				document.getElementById('bcchf_cvv').value='';
				document.getElementById('bcchf_cc_name').value='';
				document.getElementById('bcchf_expire_month').value='';
				document.getElementById('bcchf_expire_year').value='';
				
				//console.log('init Donation Page Function');

				// Hide or show additional inputs depending on how the user
				// wants to dedicate the donation
				dedication_type.on('change', function(e) {
					// Show the selected sections
					dedication_sections.filter('.js_' + e.currentTarget.id).removeClass('hide');
					
					var ded_Type_val = donation_form.find('input[name="bcchf_donation_honour"]:checked').val();
					
					var ded_Enc_MSG = document.getElementById('bcchf_encouragement_msg').innerHTML;
					
					var ded_TribName = document.getElementById('bcchf_in_honour_name').value;
					var ded_MemName = document.getElementById('bcchf_in_memory_name').value;
					
					if (ded_Enc_MSG == '' || ded_Enc_MSG == 'In honour of ' || ded_Enc_MSG == 'In memory of ' || ded_Enc_MSG == 'In honour of '+ded_TribName || ded_Enc_MSG == 'In memory of '+ded_TribName || ded_Enc_MSG == 'In honour of '+ded_MemName || ded_Enc_MSG == 'In memory of '+ded_MemName)
					{
						if (ded_Type_val == 'honour') {
							document.getElementById('bcchf_encouragement_msg').innerHTML = 'In honour of '+ded_TribName;
							document.getElementById('bcchf_in_memory_name').value = '';
						} else if (ded_Type_val == 'memory') {
							document.getElementById('bcchf_encouragement_msg').innerHTML = 'In memory of '+ded_MemName;
							document.getElementById('bcchf_in_honour_name').value = '';
						} else if (ded_Type_val == 'general') {
							document.getElementById('bcchf_encouragement_msg').innerHTML = '';
							document.getElementById('bcchf_in_honour_name').value = '';
							document.getElementById('bcchf_in_memory_name').value = '';
						} else if (ded_Type_val == 'pledge') {
							document.getElementById('bcchf_encouragement_msg').innerHTML = '';
							document.getElementById('bcchf_in_honour_name').value = '';
							document.getElementById('bcchf_in_memory_name').value = '';
						};
					};

					// Hide the other section
					// dedication_sections.not('.js_' + e.currentTarget.id).find('input[type="text"]').val('');
					dedication_sections.not('.js_' + e.currentTarget.id).addClass('hide');
				});

				/// add name in dedication text if required
				trib_hon_name.on('blur', function(e) {
					
					var ded_Enc_MSG = document.getElementById('bcchf_encouragement_msg').innerHTML;
					var ded_TribName = document.getElementById('bcchf_in_honour_name').value;
					
					if (ded_Enc_MSG == '' || ded_Enc_MSG == 'In honour of ' || ded_Enc_MSG == 'In memory of ' || ded_Enc_MSG == 'In honour of '+ded_TribName || ded_Enc_MSG == 'In memory of '+ded_TribName)
					{
						document.getElementById('bcchf_encouragement_msg').innerHTML = 'In honour of '+ded_TribName;
					};
					
				});
				
				trib_mem_name.on('blur', function(e) {
										
					var ded_Enc_MSG = document.getElementById('bcchf_encouragement_msg').innerHTML;
					var ded_TribName = document.getElementById('bcchf_in_memory_name').value;
					
					if (ded_Enc_MSG == '' || ded_Enc_MSG == 'In honour of ' || ded_Enc_MSG == 'In memory of ' || ded_Enc_MSG == 'In honour of '+ded_TribName || ded_Enc_MSG == 'In memory of '+ded_TribName)
					{
						document.getElementById('bcchf_encouragement_msg').innerHTML = 'In memory of '+ded_TribName;
					};
					
				});
				
				
				
				
				// Hide or show personal donor name or coporate donor name input fields
				/* donor_name_select.on('click', function(e) {
					e.preventDefault();
					donor_names.filter('.' + e.currentTarget.getAttribute('href')).removeClass('hide');
					donor_names.not('.' + e.currentTarget.getAttribute('href')).addClass('hide');
				}); */
				
				donor_name_corporate.on('click', function(e) {
					e.preventDefault();
					donor_names.filter('.' + e.currentTarget.getAttribute('href')).removeClass('hide');
					donor_names.not('.' + e.currentTarget.getAttribute('href')).addClass('hide');
					document.getElementById('hiddenDonationPCType').value = 'corporate';
					// doesnt work document.getElementById('js_bcchf_corporate_review').innerHTML = 'Corporate Donation';
					//console.log('switch to corp');
					alert('Note that your tax receipt will be in the name of the company you enter for a Corporate Donation');
				});
				
				donor_name_personal.on('click', function(e) {
					e.preventDefault();
					donor_names.filter('.' + e.currentTarget.getAttribute('href')).removeClass('hide');
					donor_names.not('.' + e.currentTarget.getAttribute('href')).addClass('hide');
					document.getElementById('hiddenDonationPCType').value = 'personal';
					// doesnt work document.getElementById('js_bcchf_corporate_review').innerHTML = 'Personal Donation';
					//console.log('switch to personal');
				});
				
				

				// Initialize the goto button
				goto_button.on('click', this, function(e) {
					e.preventDefault();
					e.data.donation_slider.slick('slickGoTo', parseInt(e.currentTarget.getAttribute('data-slide')));
				});


				// Hide or show the monthly or one time donation amounts radio buttons ON LOAD
				// load the gift amount to see if there is a pre load 
				
				var hiddenGiftAmount = document.getElementById('hiddenGiftAmount').value;
				
				
				var monthCheck = document.getElementById('bcchf_monthly').checked;
				var pledgeCheck = document.getElementById('bcchf_pledge').checked;
				
				if (monthCheck == 1) {
					//console.log('monthly');
					
					donation_frequency.removeClass('hide');
					// update paypal options 
					donation_form.find('.bcchf_payment_cta_monthly').removeClass('hide');
					donation_form.find('.bcchf_payment_cta').addClass('hide');
					
					// set donation amount
					var dtnAmtSet = 0;
					for (var i = 0; i < donation_radios.length; i++) {
						var amt = donation_radios.eq(i).attr('data-monthly');

						// Update the values
						donation_radios.eq(i).val(amt);

						// Update the copy
						amt += '';
						donation_type_copy.eq(i).html('$' + amt + '/mo.');

						// If the user hasn't selected the donation yet,
						if (hiddenGiftAmount == 0) {
							
							//console.log('set default amount');
							
							if (!donation_selected) {
								if (donation_radios.eq(i).attr('data-monthly_default')) {
									donation_radios.eq(i).prop('checked', true);
								} else {
									donation_radios.eq(i).prop('checked', false);
								}
							}	
							
						} else {
							
							//console.log('set selected amount');
							if (Number(hiddenGiftAmount) == Number(amt)) {
								donation_radios.eq(i).prop('checked', true);
								dtnAmtSet = 1;
							} else {
								donation_radios.eq(i).prop('checked', false);
							}
							
						}
						// set the default donation as checked
						
					}
					
					// if the radio has not been set AND there is a doantion amount
					// set and select bcchf_other
					//console.log('set other amount');
					if (hiddenGiftAmount != 0 && dtnAmtSet == 0) {
						
						jQuery("#bcchf_other").prop('checked', true);
						jQuery("#bcchf_other").val(Number(hiddenGiftAmount));
						jQuery("#bcchf_other_amt").val(Number(hiddenGiftAmount));
					}
						
				} else {
					//console.log('single');
					
					donation_frequency.addClass('hide');
					// update paypal options 
					donation_form.find('.bcchf_payment_cta_monthly').addClass('hide');
					donation_form.find('.bcchf_payment_cta').removeClass('hide');
					
					// set donation amount
					var dtnAmtSet = 0;
					for (var i = 0; i < donation_radios.length; i++) {
						var amt = donation_radios.eq(i).attr('data-once');

						// Update the values
						donation_radios.eq(i).val(amt);

						// Update the copy
						amt += '';
						donation_type_copy.eq(i).html('$' + amt);

						// If the user hasn't selected the donation yet,
						if (hiddenGiftAmount == 0) {
							
							//console.log('set default amount');
							
							if (!donation_selected) {
								if (donation_radios.eq(i).attr('data-once_default')) {
									donation_radios.eq(i).prop('checked', true);
								} else {
									donation_radios.eq(i).prop('checked', false);
								}
							}	
							
						} else {
							
							//console.log('set selected amount');
							if (Number(hiddenGiftAmount) == Number(amt)) {
								donation_radios.eq(i).prop('checked', true);
								dtnAmtSet = 1;
							} else {
								donation_radios.eq(i).prop('checked', false);
							}
							
						}
						// set the default donation as checked
						
					}
					
					// if the radio has not been set AND there is a doantion amount
					// set and select bcchf_other
					//console.log('set other amount');
					if (hiddenGiftAmount != 0 && dtnAmtSet == 0) {
						
						jQuery("#bcchf_other").prop('checked', true);
						jQuery("#bcchf_other").val(Number(hiddenGiftAmount));
						jQuery("#bcchf_other_amt").val(Number(hiddenGiftAmount));
					}
					
				}
				
				
				if (pledgeCheck == 1) {
					// enable pledge payment area 
					donation_pledge.removeClass('hide');
				} else {
					// hide pledge payment area
					donation_pledge.addClass('hide');
				}
				
				
				// Hide or show the monthly or one time donation amounts radio buttons ON CHANGE
				donation_types.on('change', function(e) {
					var type = e.currentTarget.id.replace('bcchf_', ''),
						default_attr = 'data-' + e.currentTarget.id.replace('bcchf_', '') + '_default',
						amt;

					// Update the input values and copy based on which
					// donation type was selected
					for (var i = 0; i < donation_radios.length; i++) {
						amt = donation_radios.eq(i).attr('data-' + type);

						// Update the values
						donation_radios.eq(i).val(amt);

						// Update the copy
						amt += (type === 'monthly') ? '/mo' : '';
						donation_type_copy.eq(i).html('$' + amt);

						// If the user hasn't selected the donation yet,
						// set the default donation as checked
						if (!donation_selected) {
							if (donation_radios.eq(i).attr(default_attr)) {
								donation_radios.eq(i).prop('checked', true);
							} else {
								donation_radios.eq(i).prop('checked', false);
							}
						}
					}

					// Show the frequency options only if the monthly option is chosen
					if (type === 'monthly') {
						donation_frequency.removeClass('hide');
						// update paypal options 
						donation_form.find('.bcchf_payment_cta_monthly').removeClass('hide');
						donation_form.find('.bcchf_payment_cta').addClass('hide');

					} else {
						donation_frequency.addClass('hide');
						// update paypal options 
						donation_form.find('.bcchf_payment_cta_monthly').addClass('hide');
						donation_form.find('.bcchf_payment_cta').removeClass('hide');

					}
				});

				// Set the flag that the user has made their own donation amount choice.
				// When this flag is set, the default options won't be highlighted when the
				// donation type is changed.
				this.inputs.filter('[name="bcchf_gift_amount"]').on('change', this, function(e) {
					donation_selected = true;
					e.data.inputs.filter('[name="bcchf_gift_amount"]').off('change');
				});


				// If we're on the second step, we need to detect if the user has autofilled
				// the inputs. When they autofill, we need to run the validation
				this.inputs.filter('[type="text"]').on('change', this, function(e) {
					if (e.data.donation_slider.slick('slickCurrentSlide') === 1) {
						if (jQuery(e.currentTarget).valid()) {
							e.data.unhighlight(e.currentTarget);
						} else {
							app.highlight(e.currentTarget);
							app.errorPlacement(e.currentTarget, app.validator.errorList[0]);
						}
					}
				});

				this.inputs.filter('[type="email"]').on('change', this, function(e) {
					if (e.data.donation_slider.slick('slickCurrentSlide') === 1) {
						if (jQuery(e.currentTarget).valid()) {
							e.data.unhighlight(e.currentTarget);
						}
					}
				});


				// There's nothing to validate on the last page,
				// so, the validate submit function is never called.
				// We manually set the submit button here.
				jQuery('.js_bcchf_submit').on('click', function(e) {
					//window.location.href = 'General-Form-Thank-You-Survey-E-Card.html';
					
					//hide form
					//display please wait messaging
					toggleDivOff('formContainer');
					toggleDivOn('mainDonationFormWaitMessageContainer');
					window.scrollTo(0, 0);
					
					// submit the form and wait for responses here
					jQuery.post( "processDonation.cfc?method=submitNewDonationForm", jQuery('#js_bcchf_donation').serialize(), function (data) {
						
						/// return data has been recieved
						//console.log(data)
						
						//read return data
						var dtnResult = JSON.parse(data)
						
						/// response variables
						var eventToken = dtnResult.EVENTTOKEN;
						var UUID = dtnResult.UUID;
						var responseMSG = dtnResult.MESSAGE;
						var rqst_exact_respCode = dtnResult.CHARGEATTMPT.EXACT_RESPCODE;
						
						
						if (dtnResult.SUCCESS == 1){
							// successful transaction
							toggleDivOn('formContainer');
							toggleDivOff('mainDonationFormWaitMessageContainer');
							toggleDivOn('exactResponseNegative');
							document.getElementById('exactResponseNegative').innerHTML = 'Ytransaction was successful, you will be directed to our thank you page in a moment.';
							
							if (eventToken == 'HolidaySnowball'){
								window.location.href = 'completeDonation-Snowball.cfm?Event='+eventToken+'&UUID='+UUID;
							} else {
								window.location.href = 'completeDonation-NEW.cfm?Event='+eventToken+'&UUID='+UUID;
							}
							
						} else {
							// declined messaging
							
							// get response clear text
							var textMessage = exactMessages(rqst_exact_respCode);
							
							toggleDivOn('formContainer');
							toggleDivOff('mainDonationFormWaitMessageContainer');
							toggleDivOn('exactResponseNegative');
							toggleDivOn('topExactMessage');
							window.scrollTo(0, 0);
							document.getElementById('exactResponseNegative').innerHTML = '<strong style="font-size:22px;">Your transaction was not successful.</strong><br /><span style="font-size:18px;">Message: '+textMessage+'.</span>';
							document.getElementById('topExactMessage').innerHTML = '<strong style="font-size:22px;">Your transaction was not successful.</strong><br /><span style="font-size:18px;">Message: '+textMessage+'.</span>';
						}
						
						});
				});
				
				
				jQuery('.bcchf_paypal').on('click', function(e) {
					e.preventDefault();
					
					
					//hide form
					//display please wait messaging
					toggleDivOff('formContainer');
					toggleDivOn('mainDonationFormWaitMessageContainer');
					window.scrollTo(0, 0);
					
					// submit the form and wait for responses here
					jQuery.post( "processDonation.cfc?method=submitNewDonationFormPayPal", jQuery('#js_bcchf_donation').serialize(), function (data) {
						
						/// return data has been recieved
						//console.log(data)
						
						//read return data
						var dtnResult = JSON.parse(data)
						
						/// response variables
						var eventToken = dtnResult.EVENTTOKEN;
						var UUID = dtnResult.UUID;
						var responseMSG = dtnResult.MESSAGE;
						var rqst_exact_respCode = dtnResult.CHARGEATTMPT.EXACT_RESPCODE;
						
						
						if (dtnResult.SUCCESS == 1){
							// successful transaction
							//toggleDivOn('formContainer');
							//toggleDivOff('mainDonationFormWaitMessageContainer');
							toggleDivOn('exactResponseNegative');
							document.getElementById('exactResponseNegative').innerHTML = 'PayPal payment creation successful, redirecting to PayPal.';
							
							var payPalExpress = dtnResult.CHARGEATTMPT.PPEXURL;
		
		
							window.location.href=payPalExpress;
							
							
						} else {
							// declined messaging
							
							// get response clear text
							var textMessage = exactMessages(rqst_exact_respCode);
							
							toggleDivOn('formContainer');
							toggleDivOff('mainDonationFormWaitMessageContainer');
							toggleDivOn('exactResponseNegative');
							toggleDivOn('topExactMessage');
							window.scrollTo(0, 0);
							document.getElementById('exactResponseNegative').innerHTML = '<strong style="font-size:22px;">Your transaction was not successful.</strong><br /><span style="font-size:18px;">Message: '+textMessage+'.</span>';
							document.getElementById('topExactMessage').innerHTML = '<strong style="font-size:22px;">Your transaction was not successful.</strong><br /><span style="font-size:18px;">Message: '+textMessage+'.</span>';
						}
						
						});
					
					
					
				});

				// Initialize steps slider
				this.initStepSlider();

				// Initialize validation
				this.initValidation(donation_form);
			}
		},

		/**
		* initValidation  Initializes the validation plugin
		* INFO: We're using this plugin http://jqueryvalidation.org/
		* @param (jQuery) form  The jquery form object
		*/
		initValidation: function(form) {
			var required_inputs;
			var unrequired_inputs;
			var fields_inputs;

			// Set postal code validation so validate plugin can use it
			// Reference http://geekswithblogs.net/MainaD/archive/2007/12/03/117321.aspx
			jQuery.validator.addMethod('postal', function(value, element, params) {
				//var select = jQuery('select[name="bcchf_country"]'),
				var	regex = /^[ABCEGHJKLMNPRSTVXY]{1}\d{1}[A-Z]{1} *\d{1}[A-Z]{1}\d{1}$/,
					test = true;		// If international, just accept whatever the user enters

				// If US, use a different regex
				/*
				if (select.val() === 'US') {
					regex = /^\d{5}(-\d{4})?$/;
					test = regex.test(value.toUpperCase());
				}

				if (select.val() === 'CA') {
					regex = /^[ABCEGHJKLMNPRSTVXY]{1}\d{1}[A-Z]{1} *\d{1}[A-Z]{1}\d{1}$/;
					test = regex.test(value.toUpperCase());
				} */

				return test; //regex.test(value.toUpperCase());
			}, 'Please enter a valid postal code.');

			// First name validation: letters, spaces and dashes only
			jQuery.validator.addMethod('letters_spaces', function(value, element, params) {
				var regex = /^[-\sa-zA-Z]+$/;

				return regex.test(value.toUpperCase());

			}, 'Only letters, dashes, and spaces are allowed.');

			// Email validation: we don't want sd@sd to be valid so we override the email method
			/* jQuery.validator.addMethod('email', function(value, element, params) {
				return /[a-z0-9!#$%&'*+\/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+\/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?/.test(value);
			}, 'Please enter a valid email address.'); */

			// Phone validation: we now allow special characters e.g (123)345-6789 or +1(234)567-8910 and on
			jQuery.validator.addMethod('telephone', function(value, element, params) {
				return /^(?:(?:\(?(?:00|\+)([1-4]\d\d|[1-9]\d?)\)?)?[\-\.\ \\\/]?)?((?:\(?\d{1,}\)?[\-\.\ \\\/]?){0,})(?:[\-\.\ \\\/]?(?:#|ext\.?|extension|x)[\-\.\ \\\/]?(\d+))?$/i.test(value);
			});

			// Credit card expiry date should always be in the future
			jQuery.validator.addMethod('expiry', function(value, element, params) {
				var month = parseInt(app.inputs.filter('[name="bcchf_expire_month"]').val()),
					year = parseInt(app.inputs.filter('[name="bcchf_expire_year"]').val()),
					date = new Date(),
					current_year = parseInt(String(date.getFullYear()).slice(2)),
					current_month = parseInt(date.getMonth()) + 1;				// January = 0, December = 11 -> January = 1, December = 12

					// The month and year needs to be valid
					if (month <= 12 && year >= current_year) {
						// if it's the current year, then the month
						// must be the next month onwards
						if (year === current_year && month > current_month) {
						 	return true;
						} else if (year === current_year && month === current_month) {
							// If is the current year and the current month, then it's STILL VALID
							return true;
						} else if (year === current_year && month < current_month) {
							// it is the current year, month is old
							return false;
						} else {
							// If it's a year in the future, the month doesn't matter so it's valid
							return true;
						}
					} else {
						return false;
					}
			}, 'Please enter a valid date');


			// Donation amount: Because the user can enter a custom amount,
			// we have to validate the actual value of the radio button
			jQuery.validator.addMethod('amount', function(value, element, params) {
				if (value === '') {
					return false;
				}
				return true;

			}, 'Please enter a donation amount');


			// Initialize validation plugin
			this.validator = form.validate({
				// Validates as the user selects a radio button
				onclick: function(element, event) {
					if (jQuery(element).valid()) {
						app.unhighlight(element);
					}
				},

				// Do not validate these selectors
				ignore: '.ignore_validation input, .ignore_validation select, :hidden',

				// The main key should be the name attribute of the input element
				// e.g. bcchf_email_confirm is the name attribute of <input type="email" id="bcchf_email_confirm" name="bcchf_email_confirm" required/>
				messages: {
					bcchf_gift_amount: {
						digits: 'Please enter a dollar amount. Numbers only.'
					},

					// Phone number error message
					bcchf_phone: {
						// digits: 'Please enter a valid phone number.'
						telephone: 'Please enter a valid phone number.',
						minlength: 'Please enter a 10 digit phone number.'
					},

					bcchf_email_confirm: {
						equalTo: 'Email mismatch, please check carefully.'
					}
				},

				// The main key should be the name attribute of the input element
				// e.g. bcchf_email_confirm is the name attribute of <input type="email" id="bcchf_email_confirm" name="bcchf_email_confirm" required/>
				rules: {
					// Name cannot have special characters or numbers
					bcchf_first_name: {
						required: true,
						letters_spaces: true

					},

					// Donor first Name, only letter spaces and dashes
					bcchf_donor_first_name: {
						//letters_spaces: true
					},

					// Postal code should match a certain format if Canadian or US
					bcchf_postal_code: {
						required: true,
						postal: true
					},

					// Double check the gift amount, because the user can enter a custom value if they select other
					// This doesn't work for the custom value
					bcchf_gift_amount: {
						amount: true
					},

					// The other donation amount text input must be digits only
					bcchf_other_amt: {
						//digits: true,
						number: true,
						min: 1,
						amount: true
					},

					// Credit card name must be letters and spaces only
					bcchf_cc_name: {
						letters_spaces: true
					},

					// Credit card number is required and must be digits only
					bcchf_cc_number: {
						digits: true,
						required: true
					},

					// Credit card verification number must be digits only
					bcchf_cvv: {
						digits: true
					},

					// Credit card expiry must be digits only and both are required together
					bcchf_expire_month: {
						digits: true,
						require_from_group: [2, '.js_bcchf_cc_expiry'],
						expiry: true
					},

					bcchf_expire_year: {
						digits: true,
						require_from_group: [2, '.js_bcchf_cc_expiry'],
						expiry: true
					},

					// The confirmation email input must match the
					// other email input
					bcchf_email_confirm: {
						required: true,
						email: true,
						equalTo: "#bcchf_email"
					},

					// Phone number rules
					bcchf_phone: {
						required: true,
						telephone: true,
						minlength: 10
						// digits: true
					},
					

					// In Memory of
					bcchf_in_memory: {
						required: true
						//letters_spaces: true
					},

					// In Honour of
					bcchf_in_honour: {
						letters_spaces: true
					}

				},

				// Add the error message for an invalid element
				errorPlacement: function(error, element) {
				},

				// The error message will be contained inside an em element
				errorElement: 'em',

				// Highlight the input fields with the error class to show the red border
				highlight: function(element, error_class, valid_class) {
				},

				// Remove the error highlight when the input is valid
				unhighlight: function(element, error_class, valid_class) {},

				// The validator automatically removes the error message, but for some reason
				// it doesn't remove it when you enter an invalid donation amount, then choose
				// a pre-defined amount. By setting this function, it forces the plugin to remove
				// the message.
				success: function(label, element) {
				},

				// Submit the form here
				submitHandler: function(form) {
					var inputs = jQuery(form).find('input, textarea'),
						value;

					// if the form is the acknowledgement card form
					if (jQuery(form).hasClass('js_bcchf_ack_card')) {
						// Cleanup inputs to prevent code injection
						for (var i = 0; i < inputs.length; i++) {
							value = inputs.eq(i).val().replace(/</g, '&lt;').replace(/>/g, '&gt;');
							inputs.eq(i).val(value);
						}

						// hide the form and show the survey
						jQuery(form).addClass('hide');
						jQuery('.js_bcchf_survey').removeClass('hide');
						
						// send the form to be processed
						// AWK CARD PROCESSOR
						// submit the form and wait for responses here
						jQuery.post( "processDonation.cfc?method=recordTributeGiftInfo", jQuery('#js_bcchf_ack_card').serialize(), function (data) {
						
						/// return data has been recieved
						//console.log(data)
						
						});
						
					}
				}
			});

			fields_inputs = form.find('input, textarea');

			required_inputs = fields_inputs.filter('[aria-required="true"]').add('input[name="bcchf_donor_first_name"]');
			unrequired_inputs = fields_inputs.not('[aria-required="true"]');

			required_inputs.on('keyup', function(e) {
				var element = jQuery(e.currentTarget);

				if (element.valid()) {
					app.unhighlight(e.currentTarget);
				}

			});

			unrequired_inputs.on('blur', function(e) {
				var parent = e.currentTarget.parentNode;
					parent.classList.remove('valid');

				if (jQuery(e.currentTarget).val().length > 0) {
					app.unhighlight(e.currentTarget);
					parent.classList.add('valid');
				}
			});

			required_inputs.on('blur', this, function(e) {
				var parent = jQuery(e.currentTarget.parentNode);
				var element = jQuery(e.currentTarget);
				var children = parent.find(element.get(0).tagName);
				var index = element.index();
				var count = children.length;

				if (!element.valid()) {

					app.highlight(e.currentTarget);
					app.errorPlacement(e.currentTarget, app.validator.errorList[0]);
					parent.removeClass('valid');

					if(element.attr('name') === 'bcchf_donor_first_name' && element.val() === '') {
						app.unhighlight(e.currentTarget);
						return;
					}

					if(count > 1) {
						app.unhighlight(e.currentTarget);
						parent.removeClass('valid');
					}

					if(count > 1 && index > 1) {
						//console.log('blur', count, index);
						jQuery.each(children, function(index, child){
							if (!jQuery(child).valid()) {
								app.highlight(child);
								app.errorPlacement(child, app.validator.errorList[0]);
							}
						});
					}
				}

			});
		},


		/**
		* unhighlight  Removes the error state and sets the valid state
		* INFO: We're putting this functionality outside the validation plugin setting
		* because we want to trigger this on keyup, no on focus out
		* @param (DOM) element  The element being validated
		*/
		unhighlight: function(element) {
			var element_dom = jQuery(element),
				error = element_dom.siblings('.error').not('input'),
				parent = element_dom.parents('.js_bcchf_input_container');

			element_dom.removeClass('error');

			// If it's a custom radio input, the error message will be somewhere else
			if (element_dom.parents('.js_bcchf_donation_amt_container').length > 0) {
				error = element_dom.parents('.js_bcchf_donation_amt_container').find('p.error');
			}

			// When it's the expiry month or year, we have to remove the error
			// class from the year manually
			if (element_dom.attr('name') === 'bcchf_expire_month' ||
				element_dom.attr('name') === 'bcchf_expire_year') {
				jQuery('.js_bcchf_cc_expiry').removeClass('error');
			}

			error.addClass('hide');

			// Add the valid class to the main parent container
			parent.addClass('valid');
		},


		/**
		* highlight  Adds the error state to the input
		* INFO: We're putting this functionality outside the validation plugin setting
		* because we want to trigger this on focus out only
		* @param (DOM) element  The element being validated
		*/
		highlight: function(element) {
			var element_dom = jQuery(element),
				error = element_dom.siblings('.error'),
				parent = element_dom.parents('.js_bcchf_input_container');

			element_dom.addClass('error');

			if(element_dom.is('select')) {
				element_dom.prev().addClass('error');
			}

			// Remove the valid class to the main parent container
			parent.removeClass('valid');
		},


		/**
		* errorPlacement  Add the error message for an invalid element
		* INFO: We're putting this functionality outside the validation plugin setting
		* because we want to trigger this on focus out only
		* @param (DOM) element  The element being validated
		* @param (Object) error_info  Error information for the validated element
		*/
		errorPlacement: function(element, error_info) {
			var element_dom = jQuery(element),
				error_dom = element_dom.siblings('.error'),
				parent = element_dom.parents('.js_bcchf_input_container'),
				error = '<em>' + error_info.message + '</em>';


			// If it's a custom dropdown input, the error dom will be at a different spot
			if (element_dom.is('select')) {
				error_dom = element_dom.parent().siblings('.error');
			}

			// If it's a custom radio button style, the error will be outside the container
			// Custom radio buttons have a specific structure, so we check is the next sibling
			// is a div element. The error message will be a sibling of the parent radio button container
			if (element_dom.is('input[type="radio"]') && element_dom.next().is('div')) {
				error_dom = element_dom.parent().siblings('.error');
			}

			// If the input is the custom donation text input, we need to find
			// the error copy
			if (element_dom.is('input[name="bcchf_other_amt"]')) {
				error_dom = element_dom.parents('.js_bcchf_donation_amt_container').find('p.error');
			}

			error_dom.html(error);
			error_dom.removeClass('hide');
		},

		/**
		* Textbox character counter
		* @return {[type]} [description]
		*/
		textCounter: function() {
			var target, counter, sibling, characters;

			jQuery('textarea').keyup(function(e) {
				target = jQuery(this),
				characters = target.val().length,
				sibling = target.siblings('p'),
				counter = sibling.find('.js_bcchf_textbox_counter');

				if (characters >= 180) {
					sibling.addClass('error');
					counter.text(characters);				// in case the user copy and pastes
				} else {
					counter.text(0 + characters);
					sibling.removeClass('error');
				}
			});
		},

		/**
		* [function description]
		* @return {[type]} [description]
		*/
		initSurveyPage: function() {
			var form = this.form.filter('.js_bcchf_survey');
			var form_container = form.parent();
			var visible = form_container.find('.show');
			var hidden =  form_container.find('.hide');

			form.on('submit', function(e) {
				e.preventDefault();

				//console.log("survey form submit by ajax");

				jQuery(hidden).removeClass('hide').addClass('show');
				jQuery(visible).removeClass('show').addClass('hide');
					
					// submit the form and wait for responses here
					jQuery.post( "processDonation.cfc?method=recordLegacyGiftInfo", jQuery('#js_bcchf_survey').serialize(), function (data) {
						
						/// return data has been recieved
						//console.log(data)
						
						});
				
			});
		},

		/**
		* getErrorDom  Get the error dom depending on the element. To be used with initValidation
		* INFO: Depending on the type of element, the error message will be placed in different positions
		* @param (jQuery) element  The form element that corresponds with the error message
		* @return (jQuery) error_dom  The DOM element where the error message will go
		*/
		getErrorDom: function(element) {
			var error_dom = element.siblings('.error');

			// If it's a custom dropdown input, the error dom will be at a different spot
			if (element.is('select')) {
				error_dom = element.parent().siblings('.error');
			}

			// If it's a custom radio button style, the error will be outside the container
			// Custom radio buttons have a specific structure, so we check is the next sibling
			// is a div element. The error message will be a sibling of the parent radio button container
			if (element.is('input[type="radio"]') && element.next().is('div')) {
				error_dom = element.parent().siblings('.error');
			}

			return error_dom;
		},

		/**
		* donationPageHandler  Either update the donation navigation or show the user's donation
		* information in the review section
		*/
		donationPageHandler: function() {
			var id, input, val, textbox;
			
			//console.log('donationPageHandler');

			// If we're on step 3, show the user's information
			if (this.donation_slider.slick('slickCurrentSlide') === 2) {
				for (var i = 0; i < this.review_sections.length; i++) {
					id = this.review_sections[i].id.replace('js_', '');
					input = this.form.find('[name="' + id + '"]');

					// Empty any existing copy
					this.review_sections.eq(i).html('');
					
					/// remove any past e-xact messaging
					toggleDivOff('exactResponseNegative');
					toggleDivOff('topExactMessage');
					document.getElementById('exactResponseNegative').innerHTML = '';
					document.getElementById('topExactMessage').innerHTML = '';

					// We only need to get the values of the visible inputs
					if (input.is(':visible')) {
						// If there's more than one input with the same name,
						// it's probably a radio button or checkbox
						if (input.length > 1) {
							input = input.filter(':checked');
						}

						val = input.val();

						// If it's a monthly donation, show the Withdrawn on copy
						if (id === 'bcchf_donation_on') {
							this.review_sections.eq(i).parent().removeClass('hide');
						}

						// Check if the user wants to hide their encouragement message
						// If so, we display a default message
						if (id === 'bcchf_encouragement_msg' && this.form.find('[name="bcchf_hide_message"]').prop('checked')) {
							val = 'As requested your message will not be shown';
						}

						// Check if the text input is more than 180 characters
						// If so, it trims the message down to 180
						if (id === 'bcchf_encouragement_msg' && val.length > 180) {
							val = val.substr(0, 180);
						}

						if (id === 'bcchf_special_instr' && val.length > 180) {
							val = val.substr(0, 180);
						}

						// Check if the user wants to hide their name from the honour roll
						// If so, display Anonymous as the name
						if ((id === 'bcchf_donor_first_name' || id === 'bcchf_donor_last_name' || id === 'bcchf_donor_company_name') &&
						this.form.find('[name="bcchf_hide_name"]').prop('checked')) {
							switch (id) {
								case 'bcchf_donor_first_name':
								case 'bcchf_donor_company_name':
									val = 'Anonymous';
									break;
								case 'bcchf_donor_last_name':
									val = '';
									break;
							}
						}

						// If credit card number, only display the last 4 digits
						if (id === 'bcchf_cc_number') {
							val = val.slice(val.length - 4);
						}

						// If credit card expiry month, we need to make sure we display 2 digits
						if (id === 'bcchf_expire_month' && val.length < 2) {
							val = '0' + val;
						}

						// Cleanup values to prevent code injection
						val = val.replace(/</g, '&lt;').replace(/>/g, '&gt;');

						// Update the copy based on the input value
						this.review_sections.eq(i).html(val);
					} else {
						// If an input is not visible

						// If it's just a one time donation, hide the Withdrawn on copy
						if (id === 'bcchf_donation_on') {
							this.review_sections.eq(i).parent().addClass('hide');
						}
					}
				}
			}

		}
	};

	/* B - WINDOW LOAD
	* when the complete page is fully loaded,
	* including all frames, objects and images.
	***********************************************/
	// jQuery has deprecated the load() method since version 1.8 and removed it from jQuery version 3.0.
	//jQuery(window).load(function() will not work in 3.0
	//try and use the on() method or bind() method. The on() method is good if your element might not be there when the page loads so jQuery can keep listening for your element.
	jQuery(window).on("load", function() {
	
	});


	/* C - DOCUMENT READY
	* when the HTML document is loaded and the DOM is ready,
	* even if all the graphics haven't loaded yet.
	***********************************************/
	jQuery(document).ready(function() {
		App.init();
	});
}());

///////////////// toggle div functions ////////////////////
function toggleDivOn(divid){
      document.getElementById(divid).style.display = 'block';
  }
  
function toggleDivInline(divid){
      document.getElementById(divid).style.display = 'inline';
  }
  
function toggleDivOff(divid){
      document.getElementById(divid).style.display = 'none';
  }
