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


<!--- lookup donation information from the UUID provided in the URL --->
<cfif IsDefined('URL.UUID') AND URL.UUID NEQ ''>
	<cfset sup_pge_UUID = HTMLeditFormat(URL.UUID)>
<cfelse>
	<!--- UUID NOT provided - direct away from this page --->
	<cflocation url="#THIS.EVENT.SSserviceLink#" addtoken="no">
</cfif> 

<!--- event provided in URL --->
<cfif IsDefined('URL.Event') AND URL.Event NEQ ''>
	<cfset Event = URL.Event>
<cfelse>
	<cfset Event = 'General'>
</cfif> 




<!--- lookup payment on paypal to ensure it has not already been executed --->
<!--- pass on to execute page to complete transaction --->

<cfset payDetail["payer_id"] = URL.PayerID>

<cfset sup_pge_UUID = HTMLeditFormat(URL.UUID)>
        
        
        <cfquery name="attemptRecord" datasource="bcchf_Superhero">
        SELECT  pty_date, exact_date, pty_title, pty_fname, pty_miname, pty_lname, pty_companyname, ptc_address, ptc_add_two, ptc_city, ptc_prov, ptc_post, ptc_country, tax_address, tax_city, tax_prov, tax_post, tax_country, ptc_email, ptc_subscribe, ptc_phone_area, ptc_phone, ptc_phone_area_two, ptc_phone_two, ptc_fax_area, ptc_fax, pty_tax_title, pty_tax_fname, pty_tax_lname, pty_tax_companyname, pty_tax, pty_solicit, receipt_type, gift, gift_Advantage, gift_Eligible, gift_type, gift_frequency, gift_day, gift_pledge, gift_pledge_det, ISE_notes, SupID, TeamID, ConstitID, JD_Pin, JD_Button, gift_tribute, trib_notes, gift_notes, trb_fname, trb_lname, srp_fname, srp_lname, srp_relation, trb_address, trb_add_two, trb_email, trb_city, trb_prov, trb_postal, trb_cardfrom, trb_msg, card_send, eCardID, info_where, donated_before, info_will, info_life, info_trusts, info_securities, info_RRSP, info_willinclude, info_lifeinclude, info_RSPinclude, SOC_subscribe, SOC_mail, AR_subscribe, AR_mail, post_cardholdersname, post_cardholdersemail, post_card_number, post_expiry_year, post_expiry_month, rqst_authorization_num, POST_REFERENCE_NO, int_research, int_child, int_help, int_mental, rqst_sequenceno, NoOfRegistrations, spOne_Amt, spOne_Fund, spOne_Appeal, spOne_Campaign, spTwo_Amt, spTwo_Fund, spTwo_Appeal, spTwo_Campaign, EventCode, tribImportID, tribImportIDtwo, LexusImportID, scOne, scTwo, scThree, pge_UUID, dnrBrowser, dnrOS, dnrBrowserVersion, dnrEmailRef
        FROM tblAttempt
        WHERE pge_UUID = '#sup_pge_UUID#';
        </cfquery>
        
        <!--- create supporter struct for donation form  --->
        <cfset SUPPORTER = StructNew() />
        <cfset SUPPORTER.title = attemptRecord.pty_title>
        <cfset SUPPORTER.fName = attemptRecord.pty_fname>
        <cfset SUPPORTER.mName = attemptRecord.pty_miname>
        <cfset SUPPORTER.lName = attemptRecord.pty_lname>
        <cfset SUPPORTER.cName = attemptRecord.pty_companyname>
        <cfset SUPPORTER.TAXtitle = attemptRecord.pty_tax_title>
        <cfset SUPPORTER.TAXfName = attemptRecord.pty_tax_fname>	
        <cfset SUPPORTER.TAXmName = attemptRecord.pty_miname>
        <cfset SUPPORTER.TAXlName = attemptRecord.pty_tax_lname>
        <cfset SUPPORTER.TAXcName = attemptRecord.pty_tax_companyname>
        
        <cfset SUPPORTER.email = attemptRecord.ptc_email>
        <cfset SUPPORTER.cnf_email = attemptRecord.ptc_email>
        <cfset SUPPORTER.subscribe = attemptRecord.ptc_subscribe>
        
        <cfset SUPPORTER.address = attemptRecord.ptc_address>
        <cfset SUPPORTER.addtwo = attemptRecord.ptc_add_two>
        <cfset SUPPORTER.city = attemptRecord.ptc_city>
        <cfset SUPPORTER.prov = attemptRecord.ptc_prov>
        <cfset SUPPORTER.post = attemptRecord.ptc_post>
        <cfset SUPPORTER.country = attemptRecord.ptc_country>
        
        <cfset SUPPORTER.phone = attemptRecord.ptc_phone>
        
        <cfset SUPPORTER.trbfname = attemptRecord.trb_fname>
        <cfset SUPPORTER.trblname = attemptRecord.trb_lname>
        
        <cfset SUPPORTER.srpfname = attemptRecord.srp_fname>
        <cfset SUPPORTER.srplname = attemptRecord.srp_lname>
        
        <cfset SUPPORTER.trbAddress = attemptRecord.trb_address>
        <cfset SUPPORTER.trbAddtwo = attemptRecord.trb_add_two>
        <cfset SUPPORTER.trbCity = attemptRecord.trb_city>
        <cfset SUPPORTER.trbProv = attemptRecord.trb_prov>
        <cfset SUPPORTER.trbPost = attemptRecord.trb_postal>
        <cfset SUPPORTER.trbCountry = "Canada">
        <cfset SUPPORTER.trbEmail = attemptRecord.trb_email>
        
        <cfset SUPPORTER.gender = "">
        
        <!--- gift details for form --->
        <cfset THIS.EVENT.gift_type = attemptRecord.gift_type>
        <cfset THIS.EVENT.emailReferral = attemptRecord.dnrEmailRef>
        
        <cfset THIS.EVENT.DonationPCType = "personal">
        
        <cfset THIS.EVENT.corporate_gift_container_display = 'none'>
        <cfset THIS.EVENT.personal_gift_container_display = 'block'>
        
        <cfset THIS.EVENT.hiddenDonationType = attemptRecord.gift_frequency>
        <cfset THIS.EVENT.hiddenDonationFrequDay = attemptRecord.gift_day>
        
        <cfif THIS.EVENT.hiddenDonationType EQ 'monthly'>
        
			<cfset THIS.EVENT.gift_frequency_monthlyCHKstatus = 'yes'>
            <cfset THIS.EVENT.gift_frequency_singleCHKstatus = 'no'>
            <cfset THIS.EVENT.gift_frequency = 'Monthly'>
            
            
            <cfset THIS.EVENT.gift_onetime_other_text_display = "InLine">
            <cfset THIS.EVENT.monthly_donations_display = "block">
            
            <cfset THIS.EVENT.monthly_donations_amount_display = "block">
            <cfset THIS.EVENT.single_donations_amount_display = "none">
            <cfset THIS.EVENT.monthly_donations_tax_display = "block">
            <cfset THIS.EVENT.single_donations_tax_display = "none">
            
            <cfset THIS.EVENT.DonationInfoReview = 'I am making a #DollarFormat(attemptRecord.gift)# monthly personal donation.'> 
            
            
            
        <cfelse>
        
			<cfset THIS.EVENT.gift_frequency_monthlyCHKstatus = 'no'>
            <cfset THIS.EVENT.gift_frequency_singleCHKstatus = 'yes'>
            <cfset THIS.EVENT.gift_frequency = 'Single'>
            
            
            <!--- set single div containers --->
            <cfset THIS.EVENT.gift_onetime_other_text_display = "none">          
            <cfset THIS.EVENT.monthly_donations_display = "none">
            
            <cfset THIS.EVENT.monthly_donations_amount_display = "none">
            <cfset THIS.EVENT.single_donations_amount_display = "block">
            <cfset THIS.EVENT.monthly_donations_tax_display = "none">
            <cfset THIS.EVENT.single_donations_tax_display = "block">  
            
            <cfset THIS.EVENT.DonationInfoReview = 'I am making a #DollarFormat(attemptRecord.gift)# one time personal donation.'>           
            
            
            
        </cfif>
        
        <cfset THIS.EVENT.gift_onetime_other_value = attemptRecord.gift>
        
        
        <cfset donationInfo_container_display = 'none'>
        <cfset THIS.EVENT.review_display = 'block'>
        
        <cfif SUPPORTER.subscribe EQ 1>
        	<cfset subMSG = "Yes, I allow BC Children&rsquo;s Hospital Foundation to contact me via email with information about my gift, ways to support, and how donor support is benefiting BC Children&rsquo;s Hospital.">
        <cfelse>
        	<cfset subMSG = "&nbsp;">
        </cfif>
		
		
        
        <cfset THIS.EVENT.DonorInfoReview = '<table cellpadding="5" cellspacing="3" border="0" style="text-align:left;"><tr><td width="150">Donor</td><td>#SUPPORTER.title# #SUPPORTER.fName# #SUPPORTER.lname#</td><td>&nbsp;</td></tr><tr><td valign="top">Address</td><td>#SUPPORTER.address# #SUPPORTER.addtwo#<br />#SUPPORTER.city#, #SUPPORTER.prov# #SUPPORTER.post#</td><td>&nbsp;</td></tr><tr><td>Phone Number</td><td>#SUPPORTER.phone#</td><td>&nbsp;</td></tr><tr><td>Email Address</td><td>#SUPPORTER.email#</td><td>&nbsp;</td></tr><tr><td colspan="3">#subMSG#</td></tr></table>'>
        
        
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
<link rel="stylesheet" href="css/secure-complete.css" media="all">
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

<!---  --->
<script type="text/javascript" src="js/secure-complete.js"></script>

<script type="text/javascript">
//<![CDATA[

				<!--- var _gaq = _gaq || [];
				_gaq.push(['_setAccount', 'UA-9668481-2']);
				_gaq.push(['_setDomainName', 'bcchf.ca']);
				_gaq.push(['_trackPageview']);
				(function(){
					var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
					ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
					var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);
				})(); --->
				
				(function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
						(i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
						m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
						})(window,document,'script','//www.google-analytics.com/analytics.js','ga');
						ga('create', 'UA-9668481-2', 'auto');
						ga('send', 'pageview', 'completeDonation-mobile-PayPal.cfm'+window.location.search);
			

//]]>
</script>
</head>

<cfoutput>
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
				<a href="##" class="bcchf-icon-close js-bcchf-icon-close">
					<span class="rtl"></span>
					<span class="ltr"></span>
				</a>
				<cfinclude template="../includes/mobileMenu.cfm">
			</aside>
		</header>
		<section class="main-section bcchf-content bcchf-secure-content">
			<div class="bcchf-donate">
            <form id="js-bcchf-donate-form" name="js-bcchf-donate-form" action="" method="post">
            <input type="hidden" name="PayerID" value="#URL.PayerID#"> 
            <input type="hidden" name="PaymentID" value="#URL.PaymentID#"> 
            <input type="hidden" name="UUID" value="#URL.UUID#"> 
            <input type="hidden" name="Event" value="#URL.Event#"> 
            <input type="hidden" name="qString" id="qString" value="#CGI.QUERY_STRING#"> 
            <div class="bcchf-steps-container js-bcchf-steps-container">
            <div class="bcchf-steps js-bcchf-steps js-bcchf-step1" id="bcchf-step1">
            </div>
            <div class="bcchf-steps js-bcchf-steps js-bcchf-step2" id="bcchf-step2">
            </div>
            <div class="bcchf-steps js-bcchf-steps js-bcchf-step3" id="bcchf-step3">
            </div>
            <div class="bcchf-steps js-bcchf-steps js-bcchf-step4" id="bcchf-step4">
            </div>
            
            <div class="bcchf-steps js-bcchf-steps js-bcchf-current-page js-bcchf-step5" id="bcchf-step5">
            <div class="bcchf-row">
            	<cfif Event EQ 'HolidaySnowball'>
                
                <h1>Review your donation</h1>
                <cfelse>
                <p class="bcchf-step-counter">Step 5 of 5</p>
                <h1>just one more step...</h1>
                </cfif>
            </div>
            <div class="bcchf-row">
                <div class="small-9">
                    <h3>You're almost done!</h3>
                    <p>Please review the information you've entered, then press the DONATE NOW to finalize your donation.</p>
                </div>
            </div>
            <div class="bcchf-row">
                <div class="large-12 bcchf-review-box bcchf-review-box-bg">
                    <div class="row">
                        <div class="small-8 columns bcchf-no-lpadding bcchf-review-amt js-bcchf-review-amt">
                            <label>Your donation amount:</label>
                            <span class="bcchf-donation-amt js-bcchf-donation-amt-review">#DollarFormat(attemptRecord.gift)#</span>
                            <cfif THIS.EVENT.hiddenDonationType EQ 'monthly'> 
                            <span class="bcchf-donation-duration js-bcchf-donation-duration-review">PER<br>MONTH</span>
                            </cfif>
                        </div>
                        
                    </div>
                </div>
            </div>
            <div class="bcchf-row">
                <div class="large-12 bcchf-review-box">
                    <label class="bcchf-info-title">Payment Info</label>
                    <div class="row">
                        <div class="small-8 columns bcchf-no-lpadding bcchf-info-label js-bcchf-review-payment">
                            <label>PayPal Donation</label>
                            
                        </div>
                        
                    </div>
                </div>
            </div>
            <hr>
            <div class="bcchf-row">
                <div class="large-12 bcchf-review-box">
                    <label class="bcchf-info-title">Donor Information</label>
                    <div class="row">
                        
                        <!--- --->
						<div class="small-8 columns bcchf-no-lpadding bcchf-info-label js-bcchf-review-donor">
						#THIS.EVENT.DonorInfoReview# 
						</div>
                        
                        
                    </div>
                </div>
            </div>
            <cfif attemptRecord.gift_tribute EQ'Yes'>
            	<!--- tribute options --->
				<cfif attemptRecord.trib_notes EQ 'hon'>
                <cfelseif attemptRecord.trib_notes EQ 'mem'>
                <cfelse>
                </cfif>
                
                <cfif attemptRecord.card_send EQ 'email'>
                <cfelse>
                </cfif>
            </cfif>
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
                	
                    
                    <!--- <input type="submit" value="DONATE NOW" id="button-submit-donation" class="bcchf-btn bcchf-btn-donate-now js-bcchf-btn-donate-now"  />--->
                    
                    <button class="bcchf-btn bcchf-btn-donate-now js-bcchf-btn-donate-now" data-modal="bcchf-modal-2">DONATE NOW</button> 
                </div>
            </div>
        </div> <!-- end step5 -->
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
						<p class="bcchf-popup-title">Your donation is not yet complete.</p>
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
						<p class="bcchf-popup-subtitle">It will just be a moment while your donation is being completed...</p>
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
            
        </section>
</div>
</body>
</cfoutput>
</html>
      
            
