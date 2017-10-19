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

<!--- 
	Donation Confirmation and Thank You
	used for completed donation transactions
	lookup transaction information and display for user
	donation has completed processing
	--->
    
	<!--- lookup donation information from the UUID provided in the URL --->
    <cfif IsDefined('URL.UUID') AND URL.UUID NEQ ''>
		<cfset sup_pge_UUID = HTMLeditFormat(URL.UUID)>
    <cfelse>
		<!--- UUID NOT provided - direct away from this page --->
        <cflocation url="#THIS.EVENT.SSserviceLink#" addtoken="no">
    </cfif>    


<!--- try and lookup donation --->
<cftry>

<cfquery name="selectTransaction" datasource="#THIS.EVENT.DSNsuperhero#">
SELECT * FROM tblGeneral WHERE pge_UUID = '#sup_pge_UUID#'
</cfquery>

<cfif selectTransaction.SupID NEQ 0 OR selectTransaction.TeamID NEQ 0>

	<!--- probably in support of someone, we can lookup this info --->
    <cfquery name="ThankYouScroll" datasource="#THIS.EVENT.DSNsuperhero#">
    SELECT Name, Amount, Show, Type, Message, NoScroll 
    FROM Hero_Donate
    WHERE pge_UUID = '#sup_pge_UUID#'
    </cfquery>

</cfif>

<!--- load some information about the donation to be used on this page --->

<!--- defaults --->
<cfset SupportingTitle = "Thank You for supporting">
<cfset SupportingName = "BC Children's Hospital Foundation">
<cfset SupportingSelect = "in Support of">
<cfset SupportersName = "BC Children's Hospital Foundation">
<cfset FBlinkbackURL = "http://www.bcchf.ca/donate/?utm_source=Facebook&utm_medium=ShareDonation&utm_campaign=ShareDonation">
<cfset sameDonationURL = "https://secure.bcchf.ca/donate/donation-NEW.cfm">
<cfset FBshareTitle = "They can&rsquo;t come to you for help but I can.">
<cfset FBshareSummary = "Please join me in support of BC Children&rsquo;s Hospital and make a donation today.">
<cfset FBshareImage = "https://secure.bcchf.ca/images/donate/BCCH_FACEBOOK_THUMB.PNG">



<cfcatch type="any">
	<!--- unable to load transaction details --->
	<cflocation addtoken="no" url="#THIS.EVENT.SHPserviceLink#/error/SHPerror.cfm?Error=03">
</cfcatch>
</cftry>


</cfsilent>

<!doctype html>
<!--- retrieving head information for page loading  --->
<html>
<cfoutput>
<head>
<!-- Google Tag Manager -->
<script>(function(w,d,s,l,i){w[l]=w[l]||[];w[l].push({'gtm.start':
new Date().getTime(),event:'gtm.js'});var f=d.getElementsByTagName(s)[0],
j=d.createElement(s),dl=l!='dataLayer'?'&l='+l:'';j.async=true;j.src=
'https://www.googletagmanager.com/gtm.js?id='+i+dl;f.parentNode.insertBefore(j,f);
})(window,document,'script','dataLayer','GTM-5B9CK54');</script>
<!-- End Google Tag Manager -->


<!-- Facebook Pixel Code -->
<script>
!function(f,b,e,v,n,t,s){if(f.fbq)return;n=f.fbq=function(){n.callMethod?
n.callMethod.apply(n,arguments):n.queue.push(arguments)};if(!f._fbq)f._fbq=n;
n.push=n;n.loaded=!0;n.version='2.0';n.queue=[];t=b.createElement(e);t.async=!0;
t.src=v;s=b.getElementsByTagName(e)[0];s.parentNode.insertBefore(t,s)}(window,
document,'script','https://connect.facebook.net/en_US/fbevents.js');

fbq('init', '511237559044138');
fbq('track', "PageView");
fbq('track', 'Purchase', {value: '#selectTransaction.gift#', currency: 'CAD'});</script>
<noscript><img height="1" width="1" style="display:none"
src="https://www.facebook.com/tr?id=511237559044138&ev=PageView&noscript=1"
/></noscript>
<!-- End Facebook Pixel Code -->

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

<script type="text/javascript">

	(function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
	(i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
	m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
	})(window,document,'script','//www.google-analytics.com/analytics.js','ga');
	ga('create', 'UA-9668481-2', 'auto');
	ga('send', 'pageview');
    	

</script>

<script type="text/javascript">
<!--


ga('require', 'ecommerce');

var transaction = {
  'id': '#sup_pge_UUID#',		// Transaction ID.
  'affiliation': 'Donation',	// Affiliation or store name.
  'revenue': '#selectTransaction.gift#',// Grand Total.
  'shipping': '0',				// Shipping.
  'tax': '0'                    // Tax.
};

ga('ecommerce:addTransaction', transaction);

var transItem = {
  'id': '#sup_pge_UUID#',		// Transaction ID. Required.
  'name': 'Donation',			// Product name. Required.
  'sku': '#selectTransaction.gift_type#', 		// SKU/code.
  'category': '#selectTransaction.gift_type#',  // Category or variation.
  'price': '#selectTransaction.gift#',          // Unit price.
  'quantity': '1' 				// Quantity.
};

ga('ecommerce:addItem', transItem);

ga('ecommerce:send');
// -->






</script>

	<meta charset="UTF-8">
    <title>BC Children's Hospital Foundation</title>
    <meta name="description" content="A description of the page.">
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />

    <!-- Sets whether a web application runs in full-screen mode. -->
    <meta name="apple-mobile-web-app-capable" content="yes">

    <!-- Use this to enable media queries -->
    <meta name="viewport" content="width=device-width, initial-scale=1">

    <!-- Enable search engine to index this page and follow links, replace with no-index or no-follow to disable -->
    <meta name="robots" content="no-index, no-follow">

    <!-- basic favicon -->
    <link rel="shortcut icon" href="https://www.bcchf.ca/themes/bcchf/favicon.ico" />

    <!-- For development -->
    <link rel="stylesheet" type="text/css" media="screen" href="../css/combined_secure.css?m=1445910939" />
    <link rel="stylesheet" href="css/donate.css" media="all">
    <link rel="stylesheet" href="css/slick.css" media="all">

    <!-- Typekit settings for Futura font 
    <script src="https://use.typekit.net/pcl4xdw.js"></script>
    <script>try{Typekit.load({ async: true });}catch(e){}</script>-->
    
    <script type="text/javascript" src="https://use.typekit.com/diz6qqm.js"></script>
	<script type="text/javascript">try{Typekit.load();}catch(e){}</script>


	<script type="text/javascript">
    <!--
    ga('create', 'UA-42478247-37', 'auto', {'name': 'blakely'});  // Blakely tracker.
    
    
    ga('require', 'ecommerce');
    ga('blakely.require', 'ecommerce');
    
    var transaction = {
      'id': '#sup_pge_UUID#',		// Transaction ID.
      'affiliation': 'Donation',	// Affiliation or store name.
      'revenue': '#selectTransaction.gift#',// Grand Total.
      'shipping': '0',				// Shipping.
      'tax': '0'                    // Tax.
    };
    
    ga('ecommerce:addTransaction', transaction);
    
    var transItem = {
      'id': '#sup_pge_UUID#',		// Transaction ID. Required.
      'name': 'Donation',			// Product name. Required.
      'sku': '#selectTransaction.gift_type#', 		// SKU/code.
      'category': '#selectTransaction.gift_type#',  // Category or variation.
      'price': '#selectTransaction.gift#',          // Unit price.
      'quantity': '1' 				// Quantity.
    };
    
    ga('ecommerce:addItem', transItem);
    
    ga('ecommerce:send');
    // -->
    
    
    <cfif selectTransaction.TeamID EQ 9870>
    
    ga('blakely.ecommerce:addTransaction', transaction);
    ga('blakely.ecommerce:addItem', transItem);
    ga('blakely.ecommerce:send');
    
    </cfif>
	
	function anotherDonation () {
		window.location.href = '#sameDonationURL#';
	}
    </script>

</head>
<body class="bcchf_donate">
    <div id="fb-root"></div>
    <!-- Google Tag Manager (noscript) -->
<noscript><iframe src="https://www.googletagmanager.com/ns.html?id=GTM-5B9CK54"
height="0" width="0" style="display:none;visibility:hidden"></iframe></noscript>
<!-- End Google Tag Manager (noscript) -->

    <header>
        <div class="center">
            <a href="http://bcchf.ca"><img src="images/decorations/bcchf-header-logo.png" alt=""></a>
        </div>
    </header>

    <div class="main center bcchf_thankyou_page">
        <h1>SUCCESS!</h1>

        <!-- Thank you content -->
        <section class="left bcchf_thankyou">

            <!-- Success thank you message -->
            <section>
                <p class="bcchf_thanks">#selectTransaction.pty_fname#, thank you for supporting <br />#SupportingName#.</p>
                
                <p class="bcchf_received_msg">Your donation has been successfully received. Your transaction record has been emailed to you.</p>
                
                <!--- sending the email / receipt from here in all scenarios --->
                <input type="hidden" name="UUID" id="UUID" value="#sup_pge_UUID#" />
                
                <cftry>
                
                <cfdiv id="taxMessage" style="display:block" bind="cfc:processDonation-Receipt.sendReceipt({UUID})" bindOnLoad="true"><p>Your confirmation email <cfif selectTransaction.pty_tax EQ 'yes' AND selectTransaction.gift_frequency NEQ 'Monthly' AND selectTransaction.gift_frequency NEQ 'Monthly - No Receipt'>and tax receipt </cfif>will be sent in a few moments. If you have any questions about your donation<cfif selectTransaction.pty_tax EQ 'yes' AND selectTransaction.gift_frequency NEQ 'Monthly' AND selectTransaction.gift_frequency NEQ 'Monthly - No Receipt'> or receipt</cfif>, please contact us at 604-875-2444 or call toll free 1-888-663-3033 if you're outside of Greater Vancouver.</p></cfdiv> 
                
                <cfcatch type="any">
                
                <p>Your confirmation email <cfif selectTransaction.pty_tax EQ 'yes' AND selectTransaction.gift_frequency NEQ 'Monthly' AND selectTransaction.gift_frequency NEQ 'Monthly - No Receipt'>and tax receipt </cfif>will be sent in a few moments. If you have any questions about your donation<cfif selectTransaction.pty_tax EQ 'yes' AND selectTransaction.gift_frequency NEQ 'Monthly' AND selectTransaction.gift_frequency NEQ 'Monthly - No Receipt'> or receipt</cfif>, please contact us at 604-875-2444 or call toll free 1-888-663-3033 if you're outside of Greater Vancouver.</p>
                
                <cfmail to="csweeting@bcchf.ca" from="error@bcchf.ca" subject="Error Loading Receipt CFC" type="html">
                <cfdump var="#cfcatch#">
                </cfmail>
                
                </cfcatch>
                </cftry>
                
                
            </section>
            
            
	<cfif selectTransaction.card_send EQ 'ask'>
        
			<!--- if tribute --->
			<cfset hideSurvey = ' js_bcchf_survey hide'>
            
            <cfif selectTransaction.trib_notes eq 'honour'>
            	<cfset AWKcardMSG = 'Honour'>
            <cfelseif selectTransaction.trib_notes eq 'memory'>
            	<cfset AWKcardMSG = 'Memory'>
            <cfelse>
            	<cfset AWKcardMSG = 'Honour'>
            </cfif>
            <div>&nbsp;</div>
            <cfinclude template="includes/tribCardInfo.cfm">
            
        
        <cfelse>
        
        	<cfset hideSurvey = ''>
        
		</cfif>
        
            <!-- Facebook box -->
            <section class="bcchf_fb">
                <p>Encourage your friends to donate by sharing this on Facebook.</p>
                <!-- placeholder for facebook share widget -->
                <div class="bcchf_fb_widget">
                    <div class="fb-like"
                        data-href="https://www.facebook.com/BCCHF"
                        data-layout="standard"
                        data-action="like"
                        data-show-faces="false"
                        data-share="true">
                    </div>
                </div>
        </section>

		

		<!-- Survey section -->
		<section class="bcchf_survey#hideSurvey#">
        
        <cfif selectTransaction.card_send EQ 'ask'>
        <p class="bcchf_survey_msg bcchf_thanks_acknowledgement">Thank you, your acknowledgement card has been sent.</p>
        </cfif>
        
        <!-- Survey thank you, after survey form is submitted -->
        <p class="bcchf_survey_msg hide">Thank you for completing our survey.<br>
		&nbsp;<br>
        <button class="bcchf_next" onClick="anotherDonation();">Make Another Donation</button></p>

				<!-- Survey form -->
				<p class="bcchf_survey_msg show">Please help us serve you better in the future.</p>

				<form action="" method="post" class="js_bcchf_survey show" name="js_bcchf_survey" id="js_bcchf_survey">
					<p>Check any that apply:</p>
                    <input type="hidden" name="sUUID" id="sUUID" value="#sup_pge_UUID#" />

					<div class="bcchf_checkbox_container">
						<div class="bcchf_checkbox">
							<input type="checkbox" id="bcchf_will" name="bcchf_will" value="1"/>
							<label for="bcchf_will"></label>
						</div>
						<p>I have made a gift in my will to BC Children's Hospital Foundation.</p>
					</div>

					<div class="bcchf_checkbox_container">
						<div class="bcchf_checkbox">
							<input type="checkbox" id="bcchf_send_info" name="bcchf_send_info" value="1"/>
							<label for="bcchf_send_info"></label>
						</div>
						<p>Send me info on making a gift in my will to BC Children's Hospital Foundation.</p>
					</div>
					<button class="bcchf_next">Submit Your Answers</button>
				</form>
		</section>

                
                
                                
                <!--- receipt --->
                <div class="clearfix" style="display:none;">
                <h3 style="margin-bottom:5px; margin-top:15px;">Below is your transaction record.</h3>
                <em>You will receive a copy of this confirmation via email.</em>
                
                <p>&nbsp;</p>
                <p>Received on: #DateFormat(Now(), "DDDD, MMMM DD, YYYY")#<br />
                Donor Name: #selectTransaction.pty_fname# #selectTransaction.pty_lname#<br />
                Email: #selectTransaction.ptc_email#<br />
                Address: #selectTransaction.ptc_address# #selectTransaction.ptc_add_Two#<br />
                City: #selectTransaction.ptc_city#<br />
                Province: #selectTransaction.ptc_prov#<br />
                Postal Code: #selectTransaction.ptc_post#<br />
                Phone: #selectTransaction.ptc_phone#<br />
                Gift Type: #selectTransaction.gift_frequency#<br />
                <cfif selectTransaction.gift_frequency EQ 'monthly'>
                For monthly donation, you may cancel your authorization at any time by notifying the Foundation at 604-875-2444.<br />
                </cfif><br />
                Donation: #DollarFormat(selectTransaction.gift)#<br />

                </p>
                <p>======Transaction Record======<br />
                BC Children&rsquo;s Hospital Foundation<br />
                938 West 28th Ave.<br />
                Vancouver, BC V5Z 4H4<br />
                Canada<br />
                <a href="http://www.bcchf.ca">www.bcchf.ca</a><br />
                TYPE: Purchase<br />
                DATE: #DateFormat(selectTransaction.pty_date, "DD MMM YYYY")# #TimeFormat(selectTransaction.pty_date, "h:mm:ss tt")#<br />
                AMOUNT: #DollarFormat(selectTransaction.gift)# CAD<br />
                AUTH: #selectTransaction.rqst_authorization_num#<br />
                REF: #selectTransaction.rqst_sequenceno#<br /><br />
                #SupportingTitle# #SupportingName#</p>
                </div>
                
		</section>
        
        
        <!-- Honour Roll -->
        <cfset HRlen = 5>
        <cfset HRloc = 'right'>
    	<cfinclude template="includes/honourRoll.cfm">
		
		<div class="clearfix"></div>
        
        
        <section class="bcchf_explore">
            <h2>Explore to find out more about BC Children's Hospital Foundation:</h2>
            <cfinclude template="includes/completeTiles.cfm">
			<div class="clearfix"></div>
		</section>
	</div>
    
    
    
    <cfinclude template="includes/footer.cfm">
    
	<script type="text/javascript" src="js/jquery-1.11.3.min.js"></script>
	<script type="text/javascript" src="js/slick.min.js"></script>
	<script type="text/javascript" src="js/jquery.validate.min.js"></script>
	<script type="text/javascript" src="js/default.jquery.js"></script>
	<script>(function(d, s, id) {
    var js, fjs = d.getElementsByTagName(s)[0];
    if (d.getElementById(id)) return;
    js = d.createElement(s); js.id = id;
    js.src = "//connect.facebook.net/en_GB/sdk.js##xfbml=1&version=v2.5";
    fjs.parentNode.insertBefore(js, fjs);
	}(document, 'script', 'facebook-jssdk'));
	</script>                

<script type="text/javascript">
  adroll_conversion_value = #selectTransaction.gift#;
  adroll_currency = "CAD"
  
  localStorage.removeItem('BCCHF-adRoll');
</script>

</body>



<cfinclude template="includes/conversionPixels.cfm">


</cfoutput>
</html>




