$(function () {
$.validator.setDefaults({
    submitHandler: function() {
        alert("submitted!");
    }
});

$("#js-bcchf-registration-form").validate({
		// Validate Login form
			rules: {
				bcchf_username: {
					required: true,
					minlength: 3
				},
				bcchf_password: {
					required: true,
					minlength: 3
				},
				bcchf_cnf_password: {
					required: true,
					minlength: 3,
					equalTo: "#bcchf_password"
				},
				js_bcchf_firstname: {
					required: true,
					minlength: 1
				},
				js_bcchf_lastname: {
					required: true,
					minlength: 1
				},
				js_bcchf_email: {
					required: true,
					minlength: 4,
					email: true
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
				bcchf_username: "Please enter a username.",
				bcchf_password: "Please enter a password.",
				bcchf_cnf_password: "Please confirm your password.",
				js_bcchf_email: "Please enter a valid email address."
			},
			submitHandler: function(form) {
				//ajaxHandler($('#js-bcchf-login-form'));
				form.submit();
			}
		});
	
	


});
