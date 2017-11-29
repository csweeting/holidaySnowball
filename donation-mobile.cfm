<cfsilent>
<!--- ensure security --->
<cfinclude template = "../includes/_checkSecure.cfm">

<!--- unicode --->
<cfscript> 
SetEncoding("form","utf-8"); 
SetEncoding("url","utf-8"); 
</cfscript> 
<cfcontent type="text/html; charset=utf-8">
<cfprocessingdirective pageEncoding="utf-8" />

<cfajaximport tags="cfform, cfdiv, cfwindow">

<!--- 
	secure.BCCHF.ca donation page container
	used for many donation types
	settings in Application cfc
	processing in processDonation cfc
	confirmation message in completeDonation cfm
	--->


<!--- try --->
<cftry>

	<cfset gift_type = ''>
    
    <cfif IsDefined('URL.Donation') AND URL.Donation EQ 'Stories'>
    
    <cfmail to="csweeting@bcchf.ca" from="stories@bcchf.ca" subject="Sties CGI" type="html">
    <cfdump var="#CGI#">
    </cfmail>
    
    <cfif Left(CGI.HTTP_REFERER, 58) EQ 'http://www.bcchf.ca/stories/miracle-stories/taylin-mcgill/'
		OR Left(CGI.HTTP_REFERER, 59) EQ 'https://www.bcchf.ca/stories/miracle-stories/taylin-mcgill/'>
    <cflocation url="https://secure.bcchf.ca/donate/donation-mobile.cfm?Event=WOT&Member=70239&Donation=WOT&em=&TeamID=11178&SHP=Yes&rs" addtoken="no">
    </cfif>
    </cfif>
    
<cfcatch type="any">
</cfcatch>
</cftry>

</cfsilent>

<!doctype html>
<html>
<head>

<!-- Google Tag Manager -->
<script>(function(w,d,s,l,i){w[l]=w[l]||[];w[l].push({'gtm.start':
new Date().getTime(),event:'gtm.js'});var f=d.getElementsByTagName(s)[0],
j=d.createElement(s),dl=l!='dataLayer'?'&l='+l:'';j.async=true;j.src=
'https://www.googletagmanager.com/gtm.js?id='+i+dl;f.parentNode.insertBefore(j,f);
})(window,document,'script','dataLayer','GTM-5B9CK54');</script>
<!-- End Google Tag Manager -->

<meta charset="UTF-8">
<title>BCCHF Mobile | Secure Donate</title>

<meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" /> 
<meta name="apple-mobile-web-app-capable" content="yes">
<meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no">
<meta name="description" content="Discover More Moments in BC">

<!-- For live -->
<!-- compressed files go here -->
	
<!-- For development -->
<link rel="stylesheet" href="css/secure-new.css" media="all">
<!--- donation processing --->
<script type="text/javascript" src="//secure.bcchf.ca/js/donation.js"></script>
<!--- exact msg format --->
<script type="text/javascript" src="//secure.bcchf.ca/js/exactResponseMessages.js"></script>

<script type="text/javascript" src="//secure.bcchf.ca/js/ua-parser.js"></script>
<!-- Foundation Components -->
<script src="bower_components/modernizr/modernizr.js"></script>
<script src="bower_components/jquery/dist/jquery.min.js"></script>
<script src="bower_components/foundation/js/foundation.min.js"></script>
<script type="text/javascript" src="bower_components/fastclick/lib/fastclick.js"></script>
<script type="text/javascript" src="js/jquery.validate.js"></script>
<script type="text/javascript" src="js/additional-methods.js"></script>

<!-- Javascript for the sharethis button -->
<script type="text/javascript">var switchTo5x=true;</script>
<script type="text/javascript" src="https://ws.sharethis.com/button/buttons.js"></script>
<script type="text/javascript">stLight.options({publisher: "ur-324d2f06-d845-18d1-5498-e429ec8415", onhover: false, publisherGA:"UA-9668481-2"}); </script>
<!-- end for share this button -->

<!-- Typography -->
<script type="text/javascript" src="https://use.typekit.com/tcs6epu.js"></script>
<script type="text/javascript">try{Typekit.load();}catch(e){}</script>

<!-- Custom JS for BCCHF Login/Donate Page -->
<script type="text/javascript" src="js/default.js"></script>
<script type="text/javascript" src="js/secure-new.js"></script>



<!-- Site Improve Scripting -->
<script type="text/javascript">
/*<![CDATA[*/
(function() {
var sz = document.createElement('script'); sz.type = 'text/javascript'; sz.async = true;
sz.src = '//siteimproveanalytics.com/js/siteanalyze_6062404.js';
var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(sz, s);
})();
/*]]>*/
</script>

<!-- Google Analytics -->
<script type="text/javascript">
//<![CDATA[
(function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
(i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
})(window,document,'script','//www.google-analytics.com/analytics.js','ga');
ga('create', 'UA-9668481-2', 'auto');
ga('send', 'pageview', 'donation-mobile.cfm'+window.location.search);
//]]>
</script>
</head>

<body>
<!-- Google Tag Manager (noscript) -->
<noscript><iframe src="https://www.googletagmanager.com/ns.html?id=GTM-5B9CK54"
height="0" width="0" style="display:none;visibility:hidden"></iframe></noscript>
<!-- End Google Tag Manager (noscript) -->


	<div class="bcchf-container">
		<header>
			<nav class="tab-bar">
				<section class="left-small">
					<img class="bcchf-logo" src="images/secure/logo-bcchf-225x178.png" width="104" height="82" alt="BC Children's Hospital Foundation">
				</section>
				<section class="right-small bcchf-right-small">
					<a href="bcchf-modal-1" class="bcchf-rth-link js-bcchf-rth-link">Return to Home</a>
				</section>
			</nav>
			<aside class="bcchf-off-canvas-menu">
				<a href="#" class="bcchf-icon-close js-bcchf-icon-close">
					<span class="rtl"></span>
					<span class="ltr"></span>
				</a>
				<cfinclude template="../includes/mobileMenu.cfm">
			</aside>
		</header>
		<section class="main-section bcchf-content bcchf-secure-content">
			<div class="bcchf-donate">
				<form id="js-bcchf-donate-form" action="" method="post">
					<div class="bcchf-steps-container js-bcchf-steps-container">
						<div class="bcchf-steps js-bcchf-steps <cfif sup_pge_UUID EQ ''>js-bcchf-current-page</cfif> js-bcchf-step1" id="bcchf-step1">
                        	<cfoutput>
							<cfif NOT IsDefined("pty_date")><cfset pty_date= "#Now()#"></cfif>
                            <!--- donation ID --->
                            <input type="hidden" name="sup_pge_UUID" id="sup_pge_UUID" value="#sup_pge_UUID#" />
							<!--- gift type --->
                            <input type="hidden" name="hiddenGiftType" id="hiddenGiftType" value="#THIS.EVENT.gift_type#" />
                            <!--- gift date --->
                            <input type="hidden" name="donationDate" value="#pty_date#" />
                            <!--- email referal token --->
                            <input type="hidden" name="emailReferal" value="#THIS.EVENT.emailReferral#" />
                            <input type="hidden" name="pty_tax" id="pty_tax" value="#THIS.EVENT.taxReceiptValue#" />
                            
                            <input type="hidden" name="hiddentext" value="">
                            <input type="hidden" name="hiddentype" id="hiddentype" value="#THIS.EVENT.SupportType#">
                            <input type="hidden" name="hiddenmessage" value="#THIS.EVENT.Supporting_Member#">
                            <input type="hidden" name="hiddenshow" value="0">
                            <input type="hidden" name="hiddenamount" value="">
                            <input type="hidden" name="hiddenShowValue" value="No" />
                            <input type="hidden" name="hiddenEventToken" value="#THIS.EVENT.token#" />
                            <input type="hidden" name="hiddenEventCurrentYear" value="#THIS.EVENT.CurrentYear#" />
                            <input type="hidden" name="hiddenTeamID" value="#THIS.EVENT.TeamID#" id="hiddenTeamID" />
                            <input type="hidden" name="hiddenSupID" value="#THIS.EVENT.SupID#" id="hiddenSupID" />
                            <input type="hidden" name="App_verifyToken" value="#APPLICATION.AppVerifyXDS#" />
                            <input type="hidden" name="Message" id="Message" value="#THIS.EVENT.Supporting_Member#" />
                            
                            <cfset hiddenDonationPCTypeDef = 'personal'>
							<input type="hidden" name="HIDDENDONATIONPCTYPE" id="js-form-donation-type" value="#hiddenDonationPCTypeDef#"/>
							<input type="hidden" name="form-gift-type" id="js-form-gift-type" value=""/>
							<input type="hidden" name="form-corporation" id="js-form-corporation" value=""/>
							<input type="hidden" name="HIDDENTRIBUTETYPE" id="js-form-honour" value="#THIS.EVENT.hiddenTributeType#"/>
							<input type="hidden" name="form-recepient-email" id="js-form-recepient-email" value=""/>
							<input type="hidden" name="form-pledgeid" id="js-form-pledgeid" value=""/>
                            
                            
                            <input type="hidden" name="uaosname" id="uaosname" value="" />
                            <input type="hidden" name="uaosversion" id="uaosversion" value="" />
                            <input type="hidden" name="uabrowsername" id="uabrowsername" value="" />
                            <input type="hidden" name="uabrowsermajor" id="uabrowsermajor" value="" />
                            <input type="hidden" name="uabrowserversion" id="uabrowserversion" value="" />
                            <input type="hidden" name="uadevicename" id="uadevicename" value="" />
                            <input type="hidden" name="uadevicetype" id="uadevicetype" value="" />
                            <input type="hidden" name="uadevicevendor" id="uadevicevendor" value="" />
                            <input type="hidden" name="ePhilanthropySource" id="ePhilanthropySource" value="#THIS.EVENT.ePhilSource#" />
							</cfoutput>
							<div class="bcchf-row">
                            	<cfif THIS.EVENT.token EQ 'Holiday'>
                                <h1>Give a gift that really matters</h1>
                                <cfelseif THIS.EVENT.token EQ 'HolidaySnowball'>
                                <cfif IsDefined('URL.lp')>
                                <p class="bcchf-business-number" style="color:#01bbd6;">STEP 1</p></cfif>
                                <h1 style="color:#01bbd6;">Donate<cfif IsDefined('URL.lp')> to Participate</cfif></h1>
                                <p class="bcchf-business-number">Donating only takes a minute or two, and when you're done you'll get your snowball for the Big BC Snowball Fight for Kids. Thank you for participating and helping us make the holidays brighter for thousands of kids and their families.</p>
                                <cfelse>
								<h1>Help support BC Children's Hospital</h1>
                                </cfif>
								<p class="bcchf-business-number">Charitable Business Number: 118852433RR0001</p>
							</div>
							<div class="bcchf-row">
								<p class="bcchf-step-counter"><cfif THIS.Event.token EQ 'HolidaySnowball'>Your Donation<cfelse>Step 1 of 5</cfif>:</p>
								<div class="small-9 medium-8 bcchf-note-info">
									<span class="bcchf-icon-info-blue">Info icon</span>
									<p>All fields with <span class="bcchf-star">*</span> are required</p>
								</div>
							</div>
							<div class="bcchf-row">
								<div class="large-12">
									<label id="js-bcchf-lb-donatetype" for="js-bcchf-donate-type" class="bcchf-label">I am making a: <span class="bcchf-star">*</span></label>
									<select id="js-bcchf-donate-type" name="js_bcchf_donate_type" tabindex="-1">
										<option value=""<cfif hiddenDonationPCTypeDef NEQ 'personal' AND hiddenDonationPCTypeDef NEQ 'corporate'> selected="selected"</cfif>>Please Select</option>
										<option value="personal"<cfif hiddenDonationPCTypeDef EQ 'personal'> selected="selected"</cfif>>Personal donation</option>
										<option value="corporate"<cfif hiddenDonationPCTypeDef EQ 'corporate'> selected="selected"</cfif>>Corporate donation</option>
									</select>
								</div>
							</div>
							<div class="bcchf-row bcchf-corpo-name js-bcchf-corpo-name">
								<div class="large-12">
									<label id="js-bcchf-lb-corpo-name" for="js-bcchf-corpo-name" class="bcchf-label">Corporation Name: <span class="bcchf-star">*</span></label>
									<cfoutput><input id="js-bcchf-corpo-name" name="js_bcchf_corpo_name" class="" type="text" value="#SUPPORTER.cName#" placeholder=""></cfoutput>
								</div>
							</div>
							
                            <!--- EVENT Donation ---->
                            <cfif THIS.EVENT.hiddenTributeType EQ 'event'>
                            	<cfif THIS.Event.token NEQ 'DM'
									AND THIS.Event.token NEQ 'Holiday'
									AND THIS.Event.token NEQ 'SOC'
									AND THIS.Event.token NEQ 'HolidaySnowball'>
                                <div class="bcchf-row bcchf-gift-type">
                                <div class="large-12">
                                <label>In Support of <cfoutput>#THIS.EVENT.Supporting_Member#</cfoutput><cfif THIS.EVENT.hiddenTributeType EQ 'hon-WOT'><cfif selectWOTName.TeamType EQ 'in celebration of birthday'>'s Birthday</cfif></cfif>
                                </label>
                                </div>
                                </div>
                                </cfif>
                                
                            <div class="bcchf-row bcchf-gift-type" style="display:none;">
								<div class="large-12">
									<label id="js-bcchf-lb-gift-type" for="js-bcchf-gift-type" class="bcchf-label">My gift is: <span class="bcchf-star">*</span></label>
									<div class="row">
										<div class="small-10 columns bcchf-no-lpadding">
											<select id="js-bcchf-gift-type" name="js_bcchf_gift_type" tabindex="-1">
												<option selected="selected" value="support">In Support of</option>
												<option value="honour">In Honour of</option>
												<option value="memory">In Memory of</option>											
												<option value="pledge">Recent pledge</option>
                                                <option value="general">General donation</option>
											</select>
										</div>
										<div class="small-2 columns bcchf-no-rpadding">
											<a href="#" class="bcchf-icon-help js-bcchf-icon-help">Help</a>
										</div>
									</div>
								</div>
							</div>
							<div class="bcchf-row bcchf-details-container js-bcchf-details-container">
								<div class="large-12 bcchf-details">
									<a href="#" class="bcchf-icon-close js-bcchf-close">Close</a>
									<div class="row">
										<h3>In Support Of</h3>
										<p>In support of an individual, team or event.</p>
									</div>
									<hr>
									<div class="row">
										<h3>In Honour</h3>
										<p>To celebrate an individual who is alive</p>
									</div>
									<hr>
									<div class="row">
										<h3>In Memory</h3>
										<p>To celebrate an individual who is deceased</p>
									</div>
									<hr>
									<div class="row">
										<h3>A payment for a Recent pledge</h3>
										<p>To follow up with a donation you committed to at an earlier date and now want fulfill</p>
									</div>
                                    <hr>
                                    <div class="row">
										<h3>General donation</h3>
										<p>In support of the hospital's most urgent needs</p>
									</div>
								</div>
							</div>
                            
                            <!---- WOT Donation ? --->
                            <cfelseif THIS.EVENT.hiddenTributeType EQ 'hon-WOT'
								OR THIS.EVENT.hiddenTributeType EQ 'mem-WOT'>
                                
                                
                                <div class="bcchf-row bcchf-gift-type">
                                <div class="large-12">
                                <label>
                                <cfif THIS.EVENT.hiddenTributeType EQ 'hon-WOT'>In Honour of<cfelseif THIS.EVENT.hiddenTributeType EQ 'mem-WOT'>In Memory of<cfelse>In Support of </cfif> <cfoutput>#THIS.EVENT.Supporting_Member#</cfoutput><cfif THIS.EVENT.hiddenTributeType EQ 'hon-WOT'><cfif selectWOTName.TeamType EQ 'in celebration of birthday'>'s Birthday</cfif></cfif>
                                </label>
                                </div>
                                </div>
                            
                            <div class="bcchf-row bcchf-gift-type" style="display:none;">
								<div class="large-12">
									<label id="js-bcchf-lb-gift-type" for="js-bcchf-gift-type" class="bcchf-label">My gift is: <span class="bcchf-star">*</span></label>
									<div class="row">
										<div class="small-10 columns bcchf-no-lpadding">
											<select id="js-bcchf-gift-type" name="js_bcchf_gift_type" tabindex="-1">
												
												<option <cfif THIS.EVENT.hiddenTributeType EQ 'hon-WOT'>selected="selected"</cfif> value="honour">In Honour of</option>
												<option <cfif THIS.EVENT.hiddenTributeType EQ 'mem-WOT'>selected="selected"</cfif> value="memory">In Memory of</option>											
												<option value="pledge">Recent pledge</option>
                                                <option value="general">General donation</option>
											</select>
										</div>
										<div class="small-2 columns bcchf-no-rpadding">
											<a href="#" class="bcchf-icon-help js-bcchf-icon-help">Help</a>
										</div>
									</div>
								</div>
							</div>
							<div class="bcchf-row bcchf-details-container js-bcchf-details-container">
								<div class="large-12 bcchf-details">
									<a href="#" class="bcchf-icon-close js-bcchf-close">Close</a>
									
									<div class="row">
										<h3>In Honour</h3>
										<p>To celebrate an individual who is alive</p>
									</div>
									<hr>
									<div class="row">
										<h3>In Memory</h3>
										<p>To celebrate an individual who is deceased</p>
									</div>
									<hr>
									<div class="row">
										<h3>A payment for a Recent pledge</h3>
										<p>To follow up with a donation you committed to at an earlier date and now want fulfill</p>
									</div>
                                    <hr>
                                    <div class="row">
										<h3>General donation</h3>
										<p>In support of the hospital's most urgent needs</p>
									</div>
								</div>
							</div>
                            
                            
                            <cfelse>
                            <!--- not an event donation --->
                            <hr>
                            <cfif THIS.Event.token EQ 'DM'>
							<!--- DM mobile ----  --->
                            <input type="hidden" name="js_bcchf_gift_type" value="" />
                            <cfelse>
                            <!--- general donations --->
                            
							<div class="bcchf-row bcchf-gift-type">
								<div class="large-12">
									<label id="js-bcchf-lb-gift-type" for="js-bcchf-gift-type" class="bcchf-label">Please make my gift a: <span class="bcchf-star">*</span></label>
									<div class="row">
										<div class="small-10 columns bcchf-no-lpadding">
                                        	<cfif THIS.EVENT.gift_tributeType_generalCHKstatus EQ 'Yes'>
                                            <cfset THIS.EVENT.hiddenTributeType = 'general'>
                                            </cfif>
											<select id="js-bcchf-gift-type" name="js_bcchf_gift_type" tabindex="-1">
												<option value="">Please Select</option>
												<option value="general"<cfif THIS.EVENT.hiddenTributeType EQ 'general'> selected="selected"</cfif>>General donation</option>
												<option value="honour"<cfif THIS.EVENT.hiddenTributeType EQ 'honour'> selected="selected"</cfif>>In Honour of</option>
												<option value="memory"<cfif THIS.EVENT.hiddenTributeType EQ 'memory'> selected="selected"</cfif>>In Memory of</option>											
												<option value="pledge"<cfif THIS.EVENT.hiddenTributeType EQ 'pledge'> selected="selected"</cfif>>Recent pledge</option>
											</select>
										</div>
										<div class="small-2 columns bcchf-no-rpadding">
											<a href="#" class="bcchf-icon-help js-bcchf-icon-help">Help</a>
										</div>
									</div>
								</div>
							</div>
                            
							<div class="bcchf-row bcchf-details-container js-bcchf-details-container">
								<div class="large-12 bcchf-details">
									<a href="#" class="bcchf-icon-close js-bcchf-close">Close</a>
									<div class="row">
										<h3>General donation</h3>
										<p>In support of the hospital's most urgent needs</p>
									</div>
									<hr>
									<div class="row">
										<h3>In Honour</h3>
										<p>To celebrate an individual who is alive</p>
									</div>
									<hr>
									<div class="row">
										<h3>In Memory</h3>
										<p>To celebrate an individual who is deceased</p>
									</div>
									<hr>
									<div class="row">
										<h3>A payment for a Recent pledge</h3>
										<p>To follow up with a donation you committed to at an earlier date and now want fulfill</p>
									</div>
								</div>
							</div>
                            
                            </cfif>
                            </cfif>
                            
                            <!--- tribute information ---->
                            <!--- initially display for event and WOT gifts --->
							<cfif THIS.EVENT.hiddenTributeType EQ 'event'>
                            	<cfset tribDisplay = 'none'>
                            <cfelseif THIS.EVENT.hiddenTributeType EQ 'hon-WOT' 
								OR THIS.EVENT.hiddenTributeType EQ 'mem-WOT'>
                                <cfset tribDisplay = 'none'>
                            <cfelse>
                            	<cfset tribDisplay = 'none'>
                            </cfif>
							<div class="bcchf-row bcchf-honour js-bcchf-honour" style="display:<cfoutput>#tribDisplay#</cfoutput>;">
								<div class="large-12">
									<label id="js-bcchf-lb-honour" for="js-bcchf-honour" class="bcchf-label"><span>
                                    
									<cfif THIS.EVENT.hiddenTributeType EQ 'hon-WOT'
										OR  THIS.EVENT.hiddenTributeType EQ 'mem-WOT'>
                                    <cfoutput>
                                    I am making my donation 
                                    <cfif selectWOTName.TeamType EQ 'in celebration of birthday'>in Celebration of<cfelse>#selectWOTName.TeamType#</cfif>:
                                    </cfoutput>
                                    <cfelse>
                                    I am making my donation in support of:
                                    </cfif>
                                    </span> <span class="bcchf-star">*</span></label>
									<input id="js-bcchf-honour" name="js_bcchf_honour" type="text" value="<cfoutput>#THIS.EVENT.Supporting_Member#</cfoutput><cfif THIS.EVENT.hiddenTributeType EQ 'hon-WOT'><cfif selectWOTName.TeamType EQ 'in celebration of birthday'>'s Birthday</cfif></cfif>" placeholder="<cfoutput>#THIS.EVENT.Supporting_Member#</cfoutput>" tabindex="-1">
								</div>
							</div>
                            
                            
							<div class="bcchf-row bcchf-send-email js-bcchf-send-email">
								<div class="large-12">
									<label id="js-bcchf-lb-send-email" for="js_bcchf_send_email" class="bcchf-label">Would you like to send an email notification to someone that a donation has been made in honour: <span class="bcchf-star">*</span></label>
									<div class="row">
										<div class="small-6 columns bcchf-no-lpadding">
											<input class="bcchf-sendemail-input" type="radio" name="js_bcchf_send_email" value="yes" tabindex="-1">
											<a id="js-bcchf-send-email-yes" href="#" class="bcchf-btn js-bcchf-btn-send-email" data-val="yes">Yes</a>
										</div>
										<div class="small-6 columns bcchf-no-rpadding">
											<input class="bcchf-sendemail-input" type="radio" name="js_bcchf_send_email" value="no" tabindex="-1">
											<a id="js-bcchf-send-email-no" href="#" class="bcchf-btn js-bcchf-btn-send-email" data-val="no">No</a>
										</div>
									</div>
								</div>
							</div>
							<div class="bcchf-row bcchf-recepient-email js-bcchf-recepient-email">
								<div class="large-12">
									<label id="js-bcchf-lb-recepient-email" for="js-bcchf-recepient-email" class="bcchf-label">Enter recipient's email address here: <span class="bcchf-star">*</span></label>
									<input id="js-bcchf-recepient-email" name="js_bcchf_recepient_email" type="text" placeholder="" tabindex="-1">
								</div>
							</div>
                            
							<div class="bcchf-row bcchf-pledge js-bcchf-pledge">
								<div class="large-12">
									<label id="js-bcchf-lb-pledgeid" for="js-bcchf-pledgeid" class="bcchf-label">Tell us about your pledge: <span class="bcchf-star">*</span></label>
									<input id="js-bcchf-pledgeid" name="js_bcchf_pledge_id" type="text" placeholder="" tabindex="-1">
								</div>
							</div>
                            
							<hr>
						</div> <!-- end step1 -->

						<div class="bcchf-steps js-bcchf-steps js-bcchf-step2" id="bcchf-step2">
                        <cfoutput>
							<input type="hidden" name="hiddenDonationType" id="js-form-frequency" value="#THIS.EVENT.hiddenDonationType#"/>
                            <!--- name="form-frequency"--->
							<!--- <input type="hidden" name="form-amount" id="js-form-amount" value=""/> --->
                            <input type="hidden" name="hiddenGiftAmount" id="js-form-amount" value="#THIS.EVENT.gift_onetime_other_value#" />
                            <!--- name="form-billcycle" --->
							<input type="hidden" name="hiddenFreqDay" id="js-form-bill-cycle" value="1"/>
						</cfoutput>
							<div class="bcchf-row">
								<p class="bcchf-step-counter"><cfif THIS.Event.token EQ 'HolidaySnowball'><cfelse>Step 2 of 5</cfif></p>
								<h1>donation information</h1>
							</div>
                            
                            
                            <!--- mobile donation form cannot be defaulted single / monthly --->
                            <cfif IsDefined('sup_pge_UUID') AND sup_pge_UUID NEQ ''>
                            <!--- there is an ID in the URL, load info --->
                            
							<div class="bcchf-row">
								<div class="large-12">
									<label id="js-bcchf-lb-donation-frequency" for="js_bcchf_donation_frequency" class="bcchf-label">I would like to make a donation: <span class="bcchf-star">*</span></label>
                                    
                                    <div class="row">
										<ul class="small-block-grid-2 large-block-grid-4">
											<li>
												<input class="bcchf-frequency-input" type="radio" name="js_bcchf_donation_frequency" value="single" <cfif THIS.EVENT.hiddenDonationType EQ 'single'>checked="checked"</cfif> tabindex="-1">
												<a id="js-bcchf-frequency-once" href="#" class="bcchf-btn js-bcchf-frequency <cfif THIS.EVENT.hiddenDonationType EQ 'single'>bcchf-active</cfif>" data-val="once">Once</a>
											</li>
											<li>
												<input class="bcchf-frequency-input" type="radio" name="js_bcchf_donation_frequency" value="monthly" <cfif THIS.EVENT.hiddenDonationType EQ 'monthly'>checked="monthly"</cfif> tabindex="-1">
												<a id="js-bcchf-frequency-monthly" href="#" class="bcchf-btn js-bcchf-frequency <cfif THIS.EVENT.hiddenDonationType EQ 'monthly'>bcchf-active</cfif>" data-val="monthly">Monthly</a>
											</li>
										</ul>
									</div>
                                </div>
							</div> 
                            
                            <div class="bcchf-row">
								<div class="large-12">
									<label id="js-bcchf-lb-donation-amount" for="js_bcchf_donation_amount" class="bcchf-label">For the following amount: <span class="bcchf-star">*</span></label>
									<cfif THIS.EVENT.hiddenDonationType EQ 'monthly'>
                                    <div class="row js-bcchf-donate-amt js-bcchf-once-amts">
										<ul class="small-block-grid-2 large-block-grid-4">
											<li>
												<input class="bcchf-amount-input" type="radio" name="js_bcchf_donation_amount" value="100" tabindex="-1" <cfif THIS.EVENT.gift_onetime_other_value EQ 100>checked="checked"</cfif>>
												<a href="#" class="bcchf-btn js-bcchf-amount <cfif THIS.EVENT.gift_onetime_other_value EQ 100>bcchf-active</cfif>" data-val="100">$100</a>
											</li>
											<li>
												<input class="bcchf-amount-input" type="radio" name="js_bcchf_donation_amount" value="50" tabindex="-1" <cfif THIS.EVENT.gift_onetime_other_value EQ 50>checked="checked"</cfif>>
												<a href="#" class="bcchf-btn js-bcchf-amount <cfif THIS.EVENT.gift_onetime_other_value EQ 50>bcchf-active</cfif>" data-val="50">$50</a>
											</li>
											<li>
												<input class="bcchf-amount-input" type="radio" name="js_bcchf_donation_amount" value="30" tabindex="-1" <cfif THIS.EVENT.gift_onetime_other_value EQ 30>checked="checked"</cfif>>
												<a href="#" class="bcchf-btn js-bcchf-amount <cfif THIS.EVENT.gift_onetime_other_value EQ 30>bcchf-active</cfif>" data-val="30">$30</a>
											</li>
											<li>
												<input class="bcchf-amount-input" type="radio" name="js_bcchf_donation_amount" value="18" tabindex="-1" <cfif THIS.EVENT.gift_onetime_other_value EQ 18>checked="checked"</cfif>>
												<a href="#" class="bcchf-btn js-bcchf-amount <cfif THIS.EVENT.gift_onetime_other_value EQ 18>bcchf-active</cfif>" data-val="18">$18</a>
											</li>
										</ul>
									</div>
                                    <cfelse>
                                    <div class="row js-bcchf-donate-amt js-bcchf-once-amts">
										<ul class="small-block-grid-2 large-block-grid-4">
											<li>
												<input class="bcchf-amount-input" type="radio" name="js_bcchf_donation_amount" value="250" tabindex="-1" <cfif THIS.EVENT.gift_onetime_other_value EQ 250>checked="checked"</cfif>>
												<a href="#" class="bcchf-btn js-bcchf-amount <cfif THIS.EVENT.gift_onetime_other_value EQ 250>bcchf-active</cfif>" data-val="250">$250</a>
											</li>
											<li>
												<input class="bcchf-amount-input" type="radio" name="js_bcchf_donation_amount" value="100" tabindex="-1" <cfif THIS.EVENT.gift_onetime_other_value EQ 100>checked="checked"</cfif>>
												<a href="#" class="bcchf-btn js-bcchf-amount <cfif THIS.EVENT.gift_onetime_other_value EQ 100>bcchf-active</cfif>" data-val="100">$100</a>
											</li>
											<li>
												<input class="bcchf-amount-input" type="radio" name="js_bcchf_donation_amount" value="50" tabindex="-1" <cfif THIS.EVENT.gift_onetime_other_value EQ 50>checked="checked"</cfif>>
												<a href="#" class="bcchf-btn js-bcchf-amount <cfif THIS.EVENT.gift_onetime_other_value EQ 50>bcchf-active</cfif>" data-val="50">$50</a>
											</li>
											<li>
												<input class="bcchf-amount-input" type="radio" name="js_bcchf_donation_amount" value="25" tabindex="-1" <cfif THIS.EVENT.gift_onetime_other_value EQ 25>checked="checked"</cfif>>
												<a href="#" class="bcchf-btn js-bcchf-amount <cfif THIS.EVENT.gift_onetime_other_value EQ 25>bcchf-active</cfif>" data-val="25">$25</a>
											</li>
										</ul>
									</div>
                                    </cfif>
								</div>
							</div>
							<div class="bcchf-row">
								<div class="row">
									
										<label id="js-bcchf-lb-other-amt" for="js-bcchf-other-amt" class="bcchf-label">Other amount: <span class="bcchf-star">*</span></label>
									
									<div class="small-6 columns bcchf-no-rpadding">
										<cfif THIS.EVENT.gift_onetime_other_value NEQ 250
											AND THIS.EVENT.gift_onetime_other_value NEQ 100
											AND THIS.EVENT.gift_onetime_other_value NEQ 50
											AND THIS.EVENT.gift_onetime_other_value NEQ 25>
                                        
                                        	<input disabled type="number" id="js-bcchf-other-amt" name="js_bcchf_other_amt" placeholder="" value="<cfoutput>#THIS.EVENT.gift_onetime_other_value#</cfoutput>" class="bcchf-other-amt js-bcchf-other-amt" tabindex="-1">
                                        <cfelse>
                                        <input disabled type="number" id="js-bcchf-other-amt" name="js_bcchf_other_amt" placeholder=""  class="bcchf-other-amt js-bcchf-other-amt" tabindex="-1">
                                        </cfif>
										<span class="bcchf-icon-other-amt">$</span>
									</div>
								</div>
							</div>
                            
                            <cfif THIS.EVENT.hiddenDonationType EQ 'monthly'>
							<div class="bcchf-row">
								<div class="bcchf-billcycle-row js-bcchf-billcycle-row">
									<label id="js-bcchf-lb-bill-cycle" for="js_bcchf_bill_cycle" class="bcchf-label">For my monthly  please bill me on: <span class="bcchf-star">*</span></label>
									<div class="row">
										<ul class="small-block-grid-2 large-block-grid-4">
											<li>
												<input class="bcchf-bill-cycle-input" type="radio" name="js_bcchf_bill_cycle" value="1" tabindex="-1">
												<a id="js-bcchf-bill-cycle-1st" href="#" class="bcchf-btn bcchf-lowercase bcchf-bill-cycle js-bcchf-bill-cycle bcchf-btn-disabled" data-val="0">1st <span> of every month</span></a>
											</li>
											<li>
												<input class="bcchf-bill-cycle-input" type="radio" name="js_bcchf_bill_cycle" value="15" tabindex="-1">
												<a id="js-bcchf-bill-cycle-15th" href="#" class="bcchf-btn bcchf-lowercase bcchf-bill-cycle js-bcchf-bill-cycle bcchf-btn-disabled" data-val="1">15th <span> of every month</span></a>
											</li>
										</ul>
									</div>
								</div>
							</div>
                            <cfelse>
                            <div class="bcchf-row">
								<div class="bcchf-billcycle-row js-bcchf-billcycle-row hide">
									<label id="js-bcchf-lb-bill-cycle" for="js_bcchf_bill_cycle" class="bcchf-label">For my monthly  please bill me on: <span class="bcchf-star">*</span></label>
									<div class="row">
										<ul class="small-block-grid-2 large-block-grid-4">
											<li>
												<input class="bcchf-bill-cycle-input" type="radio" name="js_bcchf_bill_cycle" value="1" tabindex="-1">
												<a id="js-bcchf-bill-cycle-1st" href="#" class="bcchf-btn bcchf-lowercase bcchf-bill-cycle js-bcchf-bill-cycle" data-val="0">1st <span> of every month</span></a>
											</li>
											<li>
												<input class="bcchf-bill-cycle-input" type="radio" name="js_bcchf_bill_cycle" value="15" tabindex="-1">
												<a id="js-bcchf-bill-cycle-15th" href="#" class="bcchf-btn bcchf-lowercase bcchf-bill-cycle js-bcchf-bill-cycle" data-val="1">15th <span> of every month</span></a>
											</li>
										</ul>
									</div>
								</div>
							</div>
                            </cfif>
                                   
                           <cfelse>
                           <!--- no ID in URL - blank form --------------------------------------- --->
                                    
                           <div class="bcchf-row">
								<div class="large-12">
									<label id="js-bcchf-lb-donation-frequency" for="js_bcchf_donation_frequency" class="bcchf-label">I would like to make a donation: <span class="bcchf-star">*</span></label>
                           
                           
                                    <div class="row">
										<ul class="small-block-grid-2 large-block-grid-4">
											<li>
												<input class="bcchf-frequency-input" type="radio" name="js_bcchf_donation_frequency" value="single" tabindex="-1">
												<a id="js-bcchf-frequency-once" href="#" class="bcchf-btn js-bcchf-frequency" data-val="once">Once</a>
											</li>
											<li>
												<input class="bcchf-frequency-input" type="radio" name="js_bcchf_donation_frequency" value="monthly" tabindex="-1">
												<a id="js-bcchf-frequency-monthly" href="#" class="bcchf-btn js-bcchf-frequency" data-val="monthly">Monthly</a>
											</li>
										</ul>
									</div>
                                    
                                 </div>
							</div>   
                        	
                            <div class="bcchf-row">
								<div class="large-12">
									<label id="js-bcchf-lb-donation-amount" for="js_bcchf_donation_amount" class="bcchf-label">For the following amount: <span class="bcchf-star">*</span></label>
                                    <div class="row js-bcchf-donate-amt js-bcchf-once-amts">
										<ul class="small-block-grid-2 large-block-grid-4">
											<li>
												<input class="bcchf-amount-input" type="radio" name="js_bcchf_donation_amount" value="250" tabindex="-1">
												<a href="#" class="bcchf-btn js-bcchf-amount bcchf-btn-disabled" data-val="250">$250</a>
											</li>
											<li>
												<input class="bcchf-amount-input" type="radio" name="js_bcchf_donation_amount" value="100" tabindex="-1">
												<a href="#" class="bcchf-btn js-bcchf-amount bcchf-btn-disabled" data-val="100">$100</a>
											</li>
											<li>
												<input class="bcchf-amount-input" type="radio" name="js_bcchf_donation_amount" value="50" tabindex="-1">
												<a href="#" class="bcchf-btn js-bcchf-amount bcchf-btn-disabled" data-val="50">$50</a>
											</li>
											<li>
												<input class="bcchf-amount-input" type="radio" name="js_bcchf_donation_amount" value="25" tabindex="-1">
												<a href="#" class="bcchf-btn js-bcchf-amount bcchf-btn-disabled" data-val="25">$25</a>
											</li>
										</ul>
									</div>

								</div>
							</div>
							<div class="bcchf-row">
								<div class="row">
									
										<label id="js-bcchf-lb-other-amt" for="js-bcchf-other-amt" class="bcchf-label">Other amount: <span class="bcchf-star">*</span></label>
									
									<div class="small-6 columns bcchf-no-rpadding">
                                        <input disabled type="number" id="js-bcchf-other-amt" name="js_bcchf_other_amt" placeholder=""  class="bcchf-other-amt js-bcchf-other-amt" tabindex="-1">
										<span class="bcchf-icon-other-amt">$</span>
									</div>
								</div>
							</div>
							<div class="bcchf-row">
								<div class="bcchf-billcycle-row js-bcchf-billcycle-row">
									<label id="js-bcchf-lb-bill-cycle" for="js_bcchf_bill_cycle" class="bcchf-label">For my monthly  please bill me on: <span class="bcchf-star">*</span></label>
									<div class="row">
										<ul class="small-block-grid-2 large-block-grid-4">
											<li>
												<input class="bcchf-bill-cycle-input" type="radio" name="js_bcchf_bill_cycle" value="1" tabindex="-1">
												<a id="js-bcchf-bill-cycle-1st" href="#" class="bcchf-btn bcchf-lowercase bcchf-bill-cycle js-bcchf-bill-cycle bcchf-btn-disabled" data-val="0">1st <span> of every month</span></a>
											</li>
											<li>
												<input class="bcchf-bill-cycle-input" type="radio" name="js_bcchf_bill_cycle" value="15" tabindex="-1">
												<a id="js-bcchf-bill-cycle-15th" href="#" class="bcchf-btn bcchf-lowercase bcchf-bill-cycle js-bcchf-bill-cycle bcchf-btn-disabled" data-val="1">15th <span> of every month</span></a>
											</li>
										</ul>
									</div>
								</div>
							</div>
                        
                        
                        
                            
                        </cfif>
									
								
							
						</div> <!-- end step2 -->

						<div class="bcchf-steps js-bcchf-steps js-bcchf-step3" id="bcchf-step3">
                        <cfoutput>
							<input type="hidden" name="form-fname" id="js-form-fname" value="#SUPPORTER.fName#"/>
							<input type="hidden" name="form-lname" id="js-form-lname" value="#SUPPORTER.lName#"/>
							<input type="hidden" name="form-email" id="js-form-receipt-email" value="#SUPPORTER.email#"/>
							<input type="hidden" name="form-allowemail" id="js-form-allowemail" value=""/>
						</cfoutput>
							<div class="bcchf-row">
								<p class="bcchf-step-counter"><cfif THIS.Event.token EQ 'HolidaySnowball'><cfelse>Step 3 of 5</cfif></p>
								<h1>Your information</h1>
							</div>
							<div class="bcchf-row">
								<div class="large-12">
									<label id="js-bcchf-lb-name" for="js-bcchf-lname" class="bcchf-label">Name: <span class="bcchf-star">*</span></label>
                                    <cfoutput>
									<div class="row">
										<div class="small-6 columns bcchf-no-lpadding">
											<input id="js-bcchf-fname" name="js_bcchf_firstname" type="text" placeholder="First Name" value="#SUPPORTER.fName#" tabindex="-1">
										</div>
										<div class="small-6 columns bcchf-no-rpadding">
											<input id="js-bcchf-lname" name="js_bcchf_lastname" type="text" placeholder="Last Name" value="#SUPPORTER.lName#" tabindex="-1">
										</div>
									</div>
                                    </cfoutput>
								</div>
							</div>
                            <cfoutput>
							<div class="bcchf-row">
								<div class="large-12">
									<label id="js-bcchf-lb-email" for="js-bcchf-email" class="bcchf-label">Email: <span class="bcchf-star">*</span></label>
									<input id="js-bcchf-email" name="js_bcchf_email" type="text" placeholder="Email" value="#SUPPORTER.email#" tabindex="-1">
									<p class="bcchf-note-input">Your receipt will be emailed here.</p>
								</div>
							</div>
							</cfoutput>
                            
                            
							<div class="bcchf-row">
								<div class="large-12">
									<div class="bcchf-note-info">
										<span class="bcchf-icon-info-black">Info icon</span>
										<p>Confirmation email contains the details of your donation and a tax receipt.</p>
									</div>
								</div>
							</div>
                            
                            <cfif IsDefined('sup_pge_UUID') AND sup_pge_UUID NEQ ''>
                            
                            <div class="bcchf-row">
								<div class="large-12">
									<label id="js-bcchf-lb-allow-email" for="js_bcchf_allow_email" class="bcchf-label">I allow BCCHF to contact me via email with information about my gift and how I can support BC Children's Hospital: <span class="bcchf-star">*</span></label>
									<div class="row">
										<div class="small-6 columns bcchf-no-lpadding">
											<input class="bcchf-allowemail-input" type="radio" name="js_bcchf_allow_email" value="yes" tabindex="-1" <cfif SUPPORTER.subscribe EQ 1>checked="checked"</cfif>>
											<a id="js-bcchf-allow-email-yes" href="#" class="bcchf-btn js-bcchf-btn-allow-email <cfif SUPPORTER.subscribe EQ 1>bcchf-active</cfif>" data-val="yes">Yes</a>
										</div>
										<div class="small-6 columns bcchf-no-rpadding">
											<input class="bcchf-allowemail-input" type="radio" name="js_bcchf_allow_email" value="no" tabindex="-1" <cfif SUPPORTER.subscribe NEQ 1>checked="checked"</cfif>>
											<a id="js-bcchf-allow-email-no" href="#" class="bcchf-btn js-bcchf-btn-allow-email <cfif SUPPORTER.subscribe NEQ 1>bcchf-active</cfif>" data-val="no">No</a>
										</div>
									</div>
								</div>
							</div>
                            
                            <cfelse>
							<div class="bcchf-row">
								<div class="large-12">
									<label id="js-bcchf-lb-allow-email" for="js_bcchf_allow_email" class="bcchf-label">I allow BCCHF to contact me via email with information about my gift and how I can support BC Children's Hospital: <span class="bcchf-star">*</span></label>
									<div class="row">
										<div class="small-6 columns bcchf-no-lpadding">
											<input class="bcchf-allowemail-input" type="radio" name="js_bcchf_allow_email" value="yes" tabindex="-1">
											<a id="js-bcchf-allow-email-yes" href="#" class="bcchf-btn js-bcchf-btn-allow-email" data-val="yes">Yes</a>
										</div>
										<div class="small-6 columns bcchf-no-rpadding">
											<input class="bcchf-allowemail-input" type="radio" name="js_bcchf_allow_email" value="no" tabindex="-1">
											<a id="js-bcchf-allow-email-no" href="#" class="bcchf-btn js-bcchf-btn-allow-email" data-val="no">No</a>
										</div>
									</div>
								</div>
							</div>
                            </cfif>
                            
						</div> <!-- end step3 -->
                        
						<cfoutput>
						<div class="bcchf-steps js-bcchf-steps <cfif sup_pge_UUID NEQ ''>js-bcchf-current-page</cfif> js-bcchf-step4" id="bcchf-step4">
							<input type="hidden" name="post_cardholdersname" id="js-form-cardholder" value=""/>
							<input type="hidden" name="post_card_number" id="js-form-cardnumber" value=""/>
							<input type="hidden" name="form-email" id="js-form-email" value="#SUPPORTER.email#" />
							<input type="hidden" name="post_expiry_month" id="js-form-expiration-month" value=""/>
							<input type="hidden" name="post_expiry_year" id="js-form-expiration-year" value=""/>
							<input type="hidden" name="post_CVV" id="js-form-cvv" value=""/>
							<input type="hidden" name="form-country" id="js-form-country" value="#SUPPORTER.country#"/>
							<input type="hidden" name="form-address" id="js-form-address" value="#SUPPORTER.address#"/>
							<input type="hidden" name="form-city" id="js-form-city" value="#SUPPORTER.city#"/>
							<input type="hidden" name="form-province" id="js-form-province" value="#SUPPORTER.prov#"/>
							<input type="hidden" name="form-postal" id="js-form-postal" value="#SUPPORTER.post#"/>
                            
                            <!--- pass some hidden vars --->
                            <input type="hidden" name="post_dollaramount" value="0">
                            <input type="hidden" name="post_card_type" value="">
                            
                            <input type="hidden" name="post_verficationstr1" value="">
                            <input type="hidden" name="post_verficationstr2" value="">
                            <input type="hidden" name="post_authorization_num" value="">
                            <input type="hidden" name="post_sequenceno" value="">
                                
                            <input type="hidden" name="post_transactiontype" value="Purchase">
                            <input type="hidden" name="post_reference_no" value="">
                            
                            <!--- 2011-06-13 Adding CVV2 verification Values --->  
                            <input type="hidden" name="post_CVD_Presence_Ind" value="1">

							<div class="bcchf-row">
								<p class="bcchf-step-counter"><cfif THIS.Event.token EQ 'HolidaySnowball'><cfelse>Step 4 of 5</cfif></p>
								<h1>address and payment details</h1>
							</div>
							
							
							<div class="bcchf-row">
								<div class="large-12">
									<label id="js-bcchf-lb-address" for="js-bcchf-address" class="bcchf-label">Address: <span class="bcchf-star">*</span></label>
									<input id="js-bcchf-address" name="js_bcchf_address" type="text" placeholder="" value="#SUPPORTER.address#" tabindex="-1">
								</div>
							</div>
							<div class="bcchf-row">
								<div class="large-12">
									<label id="js-bcchf-lb-city" for="js-bcchf-city" class="bcchf-label">City: <span class="bcchf-star">*</span></label>
									<input id="js-bcchf-city" name="js_bcchf_city" type="text" placeholder="" value="#SUPPORTER.city#" tabindex="-1">
								</div>
							</div>
							<div class="bcchf-row">
								<div class="large-12">
									<label id="js-bcchf-lb-province" for="js-bcchf-province" class="bcchf-label">Province / State: <span class="bcchf-star">*</span></label>
									<input id="js-bcchf-province" name="js_bcchf_province" type="text" placeholder="" value="#SUPPORTER.prov#" tabindex="-1">
								</div>
							</div>
							<div class="bcchf-row">
								<div class="small-8">
									<label id="js-bcchf-lb-postal" for="js-bcchf-postal" class="bcchf-label">Postal Code / Zip Code: <span class="bcchf-star">*</span></label>
									<input id="js-bcchf-postal" name="js_bcchf_postal" type="text" placeholder="" value="#SUPPORTER.post#" tabindex="-1">
								</div>
							</div>
                            
                            <div class="bcchf-row">
								<div class="large-12">
									<label id="js-bcchf-lb-country" for="js-bcchf-country" class="bcchf-label">Country: <span class="bcchf-star">*</span></label>
                                    <input id="js-bcchf-country" name="js_bcchf_country" type="text" placeholder="" value="#SUPPORTER.country#" tabindex="-1">
								</div>
							</div>

                            
                            <div class="bcchf-row">
								<div class="large-12">
									<label id="js-bcchf-lb-phone" for="js-bcchf-phone" class="bcchf-label">Phone: <span class="bcchf-star">*</span></label>
									<input id="js-bcchf-phone" name="js_bcchf_phone" type="text" placeholder="" value="#SUPPORTER.phone#" tabindex="-1">
								</div>
							</div>
                            <!--- <label class="bcchf-label"></label> --->
							<cfset DisplayPaymentOptionLine = '<span class="bcchf-label">Enter your credit card info below or <a href="" class="js-bcchf-paymentOption-PayPal"><img src="../images/donate/paypal.png" /></a></span>'>
                            
                            <cfif IsDefined('sup_pge_UUID') AND sup_pge_UUID NEQ ''>
                            <!--- if we have a URL here, there is a chance we need to display some paypal error details --->
                            <div class="bcchf-row">
								<div class="large-12" id="bcchf-PayPalMessage-container">
									<span style="color:##F00;">#payPalRSPMSG#</span>
									
								</div>
							</div>
                            </cfif>
                            
                            <!--- PayPal / CCrd options --->
                            <div class="bcchf-row">
								<div class="large-12 bcchf-CCpayPalOption-container" id="bcchf-CCpayPalOption-container">
									#DisplayPaymentOptionLine#
									
								</div>
							</div>
                            
                            
                            
                                              
                            <div id="cardPaymentOptions-container" class="bcchf-cardoptions-row js-bcchf-cardoptions-row">
                            <div class="bcchf-row">
								<div class="large-12">
									<label id="js-bcchf-lb-cardholder" for="js-bcchf-cardholder" class="bcchf-label">Cardholder's name: <span class="bcchf-star">*</span></label>
									<input id="js-bcchf-cardholder" name="js_bcchf_cardholder" type="text" placeholder="" tabindex="-1">
								</div>
							</div>
							<div class="bcchf-row">
								<div class="large-12">
									<label id="js-bcchf-lb-cardnumber" for="js-bcchf-cardnumber" class="bcchf-label">Card number: <span class="bcchf-star">*</span></label>
									<input id="js-bcchf-cardnumber" name="js_bcchf_cardnumber" type="text" placeholder="" tabindex="-1">
									<p class="bcchf-note-input"><i>Visa, Mastercard, and American Express only</i></p>
								</div>
							</div>
							<div class="bcchf-row">
								<div class="large-12">
									<label id="js-bcchf-lb-expiration-month" for="js-bcchf-expiration-month" class="bcchf-label">Expiration date: <span class="bcchf-star">*</span></label>
									<div class="row">
										<div class="small-6 columns bcchf-no-lpadding">
											<select id="js-bcchf-expiration-month" name="js_bcchf_expiration_month" tabindex="-1">
												<option selected="selected" value="">Select Month</option>
												<option value="01">01</option>
												<option value="02">02</option>
												<option value="03">03</option>
												<option value="04">04</option>
												<option value="05">05</option>
												<option value="06">06</option>
												<option value="07">07</option>
												<option value="08">08</option>
												<option value="09">09</option>
												<option value="10">10</option>
												<option value="11">11</option>
												<option value="12">12</option>
											</select>
										</div>
										<div class="small-6 columns bcchf-no-rpadding">
											<select id="js-bcchf-expiration-year" name="js_bcchf_expiration_year" tabindex="-1">
												<option selected="selected" value="">Select Year</option>
												<option value="16">16</option>
												<option value="17">17</option>
												<option value="18">18</option>
                                                <option value="19">19</option>
                                                <option value="20">20</option>
                                                <option value="21">21</option>
                                                <option value="22">22</option>
											</select>
										</div>
									</div>
								</div>
							</div>
							<div class="bcchf-row">
								<div class="large-12">
									<label id="js-bcchf-lb-cvv" for="js-bcchf-cvv" class="bcchf-label">CVV: <span class="bcchf-star">*</span></label>
									<div class="row">
										<div class="small-3 medium-4 columns bcchf-no-lpadding">
											<input id="js-bcchf-cvv" name="js_bcchf_cvv" type="text" placeholder="" maxlength="4" tabindex="-1">
										</div>
										<div class="small-9 medium-8 columns bcchf-no-rpadding">
											<!--- <div class="bcchf-note-info bcchf-note-cvv">
												<span class="bcchf-icon-info-black bcchf-icon-info-black-small">Info icon</span>
												<p>3 digit number found on the back of your credit card</p> 
											</div>--->
										</div>
									</div>	
								</div>
							</div>
                            
                            
                            
                            <div class="bcchf-row">
								<div class="large-12">
									<div class="bcchf-note-info">
										<span class="bcchf-icon-info-black">Info icon</span>
										<p>You will be able to review your information on the next step before your credit card is processed.</p>
									</div>
								</div>
							</div>
                            </div>
						</div> <!-- end step4 -->
						</cfoutput>
						<div class="bcchf-steps js-bcchf-steps js-bcchf-step5" id="bcchf-step5">
							<div class="bcchf-row">
								<p class="bcchf-step-counter"><cfif THIS.Event.token EQ 'HolidaySnowball'><cfelse>Step 5 of 5</cfif></p>
								<h1>just one more step...</h1>
							</div>
							<div class="bcchf-row">
								<div class="small-9">
									<h3>You're almost done!</h3>
									<p>Please review the information you've entered, then press the DONATE NOW  to finalize your donation.</p>
								</div>
							</div>
							<div class="bcchf-row">
								<div class="large-12 bcchf-review-box bcchf-review-box-bg">
									<div class="row">
										<div class="small-8 columns bcchf-no-lpadding bcchf-review-amt js-bcchf-review-amt">
											<label>Your donation amount:</label>
											<span class="bcchf-donation-amt js-bcchf-donation-amt-review">$0</span>
											<span class="bcchf-donation-duration js-bcchf-donation-duration-review">PER<br>MONTH</span>
										</div>
										<div class="small-4 columns bcchf-no-rpadding">
											<a href="#bcchf-step2" class="bcchf-btn bcchf-btn-edit bcchf-btn-edit-amt">Edit</a>
										</div>
									</div>
								</div>
							</div>
							<div class="bcchf-row">
								<div class="large-12 bcchf-review-box">
									<label class="bcchf-info-title">Payment Info</label>
									<div class="row">
										<div class="small-8 columns bcchf-no-lpadding bcchf-info-label js-bcchf-review-payment">
											<label>Credit Card ending in: <span class="js-bcchf-cc-end-review">xxxx</span></label>
											<label>Expiry: <span class="js-bcchf-exp-month-review"></span>/<span class="js-bcchf-exp-year-review"></span></label>
											<label class="bcchf-billing-cycle-confirmation">Billing cycle: <span class="js-bcchf-billcycle-review">15th</span></label>
										</div>
										<div class="small-4 columns bcchf-no-rpadding">
											<a href="#bcchf-step4" class="bcchf-btn bcchf-btn-edit">Edit</a>
										</div>
									</div>
								</div>
							</div>
							<hr>
							<div class="bcchf-row">
								<div class="large-12 bcchf-review-box">
									<label class="bcchf-info-title">Donor Information</label>
									<div class="row">
										<div class="small-8 columns bcchf-no-lpadding bcchf-info-label js-bcchf-review-donor">
											<label><span class="js-bcchf-fname-review"></span> <span class="js-bcchf-lname-review"></span></label>
											<label><span class="js-bcchf-email-review"></span></label>
										</div>
										<div class="small-4 columns bcchf-no-rpadding">
											<a href="#bcchf-step3" class="bcchf-btn bcchf-btn-edit">Edit</a>
										</div>
									</div>
								</div>
							</div>
							<hr>
							<div class="bcchf-row">
								<div class="large-12">
									<label class="bcchf-info-title">Is there anything else you would like to tell us about your gift?</label>
									<textarea class="bcchf-textarea" name="js_bcchf_gift_details" tabindex="-1"></textarea>
									<p class="bcchf-note-input"><i>(e.g. gift description)</i></p>
								</div>
							</div>
							<div class="bcchf-row">
								<div class="large-12">
									<button class="bcchf-btn bcchf-btn-donate-now js-bcchf-btn-donate-now" data-modal="bcchf-modal-2">DONATE NOW</button>
								</div>
							</div>
						</div> <!-- end step5 -->

						<div class="bcchf-steps js-bcchf-steps" id="bcchf-confirmation-box">
							<div class="bcchf-row">
								<h1>confirmation</h1>
								<p class="bcchf-confirmation-msg">Thank you! Your donation has been processed successfully.</p>
							</div>
							<div class="bcchf-row">
								<div class="large-12 bcchf-share-message">
									<p>We need your help to spread the word. Please consider sharing with your friends and followers.</p>
									<div class="share-box">
									    <div class="share-this">
									    	<span class='st_sharethis_custom' displayText='share this button' st_summary="Share this" st_image='images/logo_share.png'></span>
									    </div>
								    </div>
								    <div class="clearfix"></div>
								</div>
							</div>
							<div class="bcchf-row">
								<div class="large-12">
									<div class="row">
										<div class="small-3 columns">
											<img class="bcchf-logo-confirmation" src="images/secure/logo-bcchf-225x178.png" width="104" height="82" alt="BC Children's Hospital Foundation">
										</div>
										<div class="small-9 columns">
											<label>Your donation amount:</label>
											<span class="bcchf-donation-amt js-bcchf-donation-amt-confirmation">$xx</span>
											<span class="bcchf-donation-duration js-bcchf-donation-duration-confirmation">PER<br>MONTH</span>
										</div>
									</div>
								</div>
							</div>
							<hr>
							<div class="bcchf-row">
								<div class="large-12">
									<label class="bcchf-info-title">Billing Information</label>
									<label class="bcchf-info-label">VISA: <span class="bcchf-info-value js-bcchf-cc-end-confirmation">xxxx xxxx</span></label>
									<label class="bcchf-info-label">Total Charged: <span class="bcchf-info-value js-bcchf-total-charge-confirmation"></span></label>
									<label class="bcchf-info-label">Receipt issued to: <span class="bcchf-info-value js-bcchf-receipt-confirmation"></span></label>
								</div>
							</div>
							<div class="bcchf-row">
								<div class="large-12">
									<label class="bcchf-info-title">Your Information</label>
									<label class="bcchf-info-label"><span class="js-bcchf-fname-confirmation"></span> <span class="js-bcchf-lname-confirmation"></span></label>
									<label class="bcchf-info-value bcchf-address js-bcchf-address-confirmation"><br><br></label>
								</div>
							</div>
							<div class="row">
								<div class="large-12">
									<a href="http://www.bcchf.ca" class="bcchf-btn">back to home</a>
								</div>
							</div>
						</div>

						<div class="bcchf-step-button">
							<div class="row">
								<div class="small-6 columns bcchf-no-lpadding">
									<a href="https://secure.bcchf.ca/donate/donation.cfm" class="bcchf-btn-donate bcchf-btn-prev js-bcchf-btn-prev">BACK<span class="bcchf-btn-arrow bcchf-left-arrow"></span></a>
								</div>
								<div class="small-6 columns bcchf-no-rpadding">
									<button class="bcchf-btn-donate bcchf-btn-next bcchf-btn-disabled js-bcchf-btn-next">NEXT <span class="bcchf-btn-arrow bcchf-right-arrow"></span></button>
									<p class="bcchf-btn-desc"><i>&nbsp;</i></p>
								</div>
							</div>
						</div>

						<div class="row bcchf-note-info bcchf-warning bcchf-donate-warning js-bcchf-donate-warning">
							<div class="large-12">
								<span class="bcchf-icon-warning-black"></span>
								<p class="bcchf-text-warning">We just need a bit more information first.</p>
							</div>
						</div>
					</div>
                    
                    
				</form>
                
			</div> <!-- end secure donate -->
		</section>
		<section class="bcchf-popups-container">
        	<!---- onExit Warning --->
			<div class="bcchf-pop-up bcchf-rth-warning js-bcchf-rth-warning" id="bcchf-modal-1">
				<div class="js-bcchf-rth-container bcchf-pop-up-content">
					<div class="bcchf-row">
						<div class="bcchf-warning-icon"></div>
						<span class="bcchf-icon-warning-orange">Info icon</span>
					</div>
					<div class="bcchf-row">
						<p class="bcchf-popup-title">If you leave the donation page, the information you have entered will be lost.</p>
					</div>
					<div class="bcchf-row">
						<button class="bcchf-btn bcchf-continue-donation js-bcchf-continue-donation">continue your <br> donation</button>
					</div>
					<div class="bcchf-row">
						<p class="bcchf-popup-title-s">OR</p>
					</div>
					<div class="bcchf-row">
						<a href="http://www.bcchf.ca" class="bcchf-btn bcchf-return-to-home js-bcchf-rth">RETURN TO HOME</a>
					</div>
				</div>
			</div>
            
            <!--- Card Processing --->
			<div class="bcchf-pop-up bcchf-processing-box js-bcchf-processing-box" id="bcchf-modal-2">
				<div class="bcchf-pop-up-content">
					<div class="bcchf-row bcchf-popup-logo">
						<img  src="images/secure/logo-bcchf-225x178.png" width="104" height="82" alt="BC Children's Hospital Foundation">
					</div>
					<div class="bcchf-row">
						<p class="bcchf-popup-title">Thank you for your support!</p>
						<p class="bcchf-popup-subtitle">It will just be a moment while your credit card is processing...</p>
					</div>
					<div class="bcchf-row">
						<div class="bcchf-loading-icon"></div>
					</div>
					<div class="bcchf-row">
						<p class="bcchf-popup-subtitle">You will be redirected to a confirmation page.</p>
					</div>
					<button class="bcchf-close-process-popup js-bcchf-close-process-popup"></button>
				</div>
			</div>
            
            <!--- Successful Modal --->
            <div class="bcchf-pop-up bcchf-processing-box js-bcchf-processing-box" id="bcchf-modal-4">
				<div class="bcchf-pop-up-content">
					<div class="bcchf-row bcchf-popup-logo">
						<img  src="images/secure/logo-bcchf-225x178.png" width="104" height="82" alt="BC Children's Hospital Foundation">
					</div>
					<div class="bcchf-row">
						<p class="bcchf-popup-title">Thank you for your support!</p>
						<p class="bcchf-popup-subtitle">Donation Successful</p>
					</div>
					<div class="bcchf-row">
						<p class="bcchf-popup-subtitle">You will recieve a confirmation email.</p>
					</div>
					<button class="bcchf-close-process-popup js-bcchf-close-process-popup"></button>
				</div>
			</div>
            <!--- card error modal --->
			<div class="bcchf-pop-up bcchf-error-processing-box" id="bcchf-modal-3">
				<button class="bcchf-btn bcchf-btn-error js-bcchf-btn-error" data-modal="bcchf-modal-3">Error</button>
				<div class="bcchf-pop-up-content">
					<div class="bcchf-row">
						<img  src="images/secure/logo-bcchf-225x178.png" width="104" height="82" alt="BC Children's Hospital Foundation">
					</div>
					<div class="row">
						<p class="bcchf-popup-title">Whoops.</p>
						<p class="bcchf-popup-subtitle">We couldn't process your donation.</p>
                        <div id="exactResponseNegative"></div>
					</div>
                    
					<div class="row">
						<p class="bcchf-popup-subtitle">Please check the information you entered is correct.</p>
					</div>
					<button class="bcchf-close-process-popup bcchf-btn bcchf-return-to-payment js-bcchf-return-to-payment md-close">Click here to<br> return to payment information</button>
				</div>
			</div>
            
            <!--- PayPal Setup --->
			<div class="bcchf-pop-up bcchf-error-processing-box" id="bcchf-modal-5">
				<div class="bcchf-pop-up-content">
					<div class="bcchf-row bcchf-popup-logo">
						<img  src="images/secure/logo-bcchf-225x178.png" width="104" height="82" alt="BC Children's Hospital Foundation">
					</div>
					<div class="bcchf-row">
						<p class="bcchf-popup-title">Thank you for your support!</p>
						<p class="bcchf-popup-subtitle">It will just be a moment while we setup your PayPal payment...</p>
					</div>
					<div class="bcchf-row">
						<div class="bcchf-loading-icon"></div>
					</div>
					<div class="bcchf-row">
						<p class="bcchf-popup-subtitle">You will be directed to PayPal's checkout page.</p>
					</div>
					<button class="bcchf-close-process-popup js-bcchf-close-process-popup"></button>
				</div>
			</div>
            
            <!--- PayPal Complete --->
			<div class="bcchf-pop-up bcchf-error-processing-box" id="bcchf-modal-6">
				<div class="bcchf-pop-up-content">
					<div class="bcchf-row bcchf-popup-logo">
						<img  src="images/secure/logo-bcchf-225x178.png" width="104" height="82" alt="BC Children's Hospital Foundation">
					</div>
					<div class="bcchf-row">
						<p class="bcchf-popup-title">Thank you for your support!</p>
						<p class="bcchf-popup-subtitle">Just a moment while we direct you to PayPal's checkout page....</p>
					</div>
					<div class="bcchf-row">
						<div class="bcchf-loading-icon"></div>
					</div>
					<div class="bcchf-row">
						<p class="bcchf-popup-subtitle">You will be directed to PayPal's checkout page in a moment.</p>
					</div>
					<button class="bcchf-close-process-popup js-bcchf-close-process-popup"></button>
				</div>
			</div>
            
			<div class="bcchf-popup-bg js-bcchf-popup-bg"></div>
		</section>
	</div>
	
	
</body>
<!--- --->
<script type="text/javascript">
	<!--
	
	var cookDate = localStorage.getItem('BCCHF-adRoll');
	if(cookDate !== null){
		document.getElementById('ePhilanthropySource').value = 'Retargeting';
		//console.log('cookie picked up');
		//console.log(document.getElementById('ePhilanthropySource').value);
	}
	
	var cookItem = localStorage.getItem('BCCHF-ePhilSource');
	if(cookItem !== null){
		document.getElementById('ePhilanthropySource').value = cookItem;
		//console.log('cookie picked up');
		//console.log(document.getElementById('ePhilanthropySource').value);
	}
	
	<cfif THIS.EVENT.ePhilSource EQ 'Retargeting'>
	localStorage.setItem('BCCHF-adRoll', (new Date()).getDate());
	//console.log('cookie dropped');
	</cfif>

	<cfif THIS.EVENT.ePhilSource NEQ ''>
	<cfoutput>localStorage.setItem('BCCHF-ePhilSource', '#THIS.EVENT.ePhilSource#');</cfoutput>
	//console.log('cookie dropped');
	</cfif>

	var parser = new UAParser();
	<cfoutput>var uastring = "#CGI.HTTP_USER_AGENT#";</cfoutput>
	var result = UAParser(uastring);
	
	//console.log(result.browser);        // {name: "Chromium", major: "15", version: "15.0.874.106"}
	//console.log(result.device);         // {model: undefined, type: undefined, vendor: undefined}
	//console.log(result.os);             // {name: "Ubuntu", version: "11.10"}
	document.getElementById('uabrowsername').value = result.browser.name;
	document.getElementById('uabrowsermajor').value = result.browser.major;
	document.getElementById('uabrowserversion').value = result.browser.version;
	document.getElementById('uaosname').value = result.os.name;
	document.getElementById('uaosversion').value = result.os.version;
	document.getElementById('uadevicename').value = result.device.model;
	document.getElementById('uadevicetype').value = result.device.type;
	document.getElementById('uadevicevendor').value = result.device.vendor;
	-->	
</script>
</html>