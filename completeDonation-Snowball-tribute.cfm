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

<!--- lookup event details --->
<CFQUERY name="selectDonation" datasource="#APPLICATION.DSN.Superhero#">
SELECT Sum(Hero_Donate.Amount) AS sumAmount, Count(Hero_Donate.ID) AS countAmount FROM Hero_Donate 
WHERE Campaign = 2017
AND Event = 'HolidaySnowball' 
</CFQUERY>

<cfif selectDonation.sumAmount EQ ''>
	<cfset totalDonations = 0>
<cfelse>
	<cfset totalDonations = selectDonation.sumAmount>
</cfif>

<cfif selectDonation.countAmount EQ ''>
	<cfset countDonations = 0>
<cfelse>
	<cfset countDonations = selectDonation.countAmount>
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

    <link href="css/vaccine.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css?family=Roboto:400,400i,500,700" rel="stylesheet">

    <!-- basic favicon -->
    <link rel="shortcut icon" href="https://www.bcchf.ca/themes/bcchf/favicon.ico" />

    <!-- For development -->
    <!--- <link rel="stylesheet" type="text/css" media="screen" href="../css/combined_secure.css?m=1445910939" /> --->
    <link rel="stylesheet" href="css/footer.css" media="all">
    <link rel="stylesheet" href="css/donate-snowball.css" media="all">
    <link rel="stylesheet" href="css/slick.css" media="all">
    <link rel="stylesheet" href="css/style.css?v=5.0" media="all">

    <!-- Typekit settings for Futura font 
    <script src="https://use.typekit.net/pcl4xdw.js"></script>
    <script>try{Typekit.load({ async: true });}catch(e){}</script>

    
    <script type="text/javascript" src="https://use.typekit.com/diz6qqm.js"></script>
	<script type="text/javascript">try{Typekit.load();}catch(e){}</script>
    -->

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
<body class="bcchf_donate bcchf_thankyou">
    <div id="fb-root"></div>
    <script>
        window.fbAsyncInit = function() {
        FB.init({
          appId      : '132100647417767',
          xfbml      : true,
          version    : 'v2.11'
        });
        FB.AppEvents.logPageView();
        };

        (function(d, s, id){
         var js, fjs = d.getElementsByTagName(s)[0];
         if (d.getElementById(id)) {return;}
         js = d.createElement(s); js.id = id;
         js.src = "https://connect.facebook.net/en_US/sdk.js";
         fjs.parentNode.insertBefore(js, fjs);
        }(document, 'script', 'facebook-jssdk'));
    </script>
    <!-- Google Tag Manager (noscript) -->
<noscript><iframe src="https://www.googletagmanager.com/ns.html?id=GTM-5B9CK54"
height="0" width="0" style="display:none;visibility:hidden"></iframe></noscript>
<!-- End Google Tag Manager (noscript) -->

    <header class="site-header">
        <div class="row">
            <div class="small-12 columns">
                <a href="http://bcchf.ca" target="_blank"><img src="images/snowtheme/logo-tag.png" width="175" height="166" alt=""></a>
            </div>
        </div>
    </header>

    <main class="site-content bcchf_thankyou_page">
        <div class="row">
            <article class="small-12 columns bcchf_thankyou">

                <!-- Success thank you message -->
                <section id="thanks-top" class="panel">
                    <div class="row align-middle">
                        <div class="small-12 medium-8 columns">
                            
                            <h2 class="bcchf_thanks">Thank you for donating, #selectTransaction.pty_fname#!</h2>
                    
                            <!--- sending the email / receipt from here in all scenarios --->
                            <input type="hidden" name="UUID" id="UUID" value="#sup_pge_UUID#" />
                            
                            <cftry>
                            
                            <cfdiv id="taxMessage" style="display:block" bind="cfc:processDonation-Receipt.sendReceipt({UUID})" bindOnLoad="true"><p>A confirmation email <cfif selectTransaction.pty_tax EQ 'yes' AND selectTransaction.gift_frequency NEQ 'Monthly' AND selectTransaction.gift_frequency NEQ 'Monthly - No Receipt'>with your tax receipt </cfif>has been sent to you. If you have any questions about your donation<cfif selectTransaction.pty_tax EQ 'yes' AND selectTransaction.gift_frequency NEQ 'Monthly' AND selectTransaction.gift_frequency NEQ 'Monthly - No Receipt'> or receipt</cfif>, please contact us at 604-875-2444 or call toll free 1-888-663-3033 if you're outside of Greater Vancouver.</p></cfdiv> 
                            
                            <cfcatch type="any">
                            
                            <p>A confirmation email <cfif selectTransaction.pty_tax EQ 'yes' AND selectTransaction.gift_frequency NEQ 'Monthly' AND selectTransaction.gift_frequency NEQ 'Monthly - No Receipt'>with your tax receipt </cfif>has been sent to you. If you have any questions about your donation<cfif selectTransaction.pty_tax EQ 'yes' AND selectTransaction.gift_frequency NEQ 'Monthly' AND selectTransaction.gift_frequency NEQ 'Monthly - No Receipt'> or receipt</cfif>, please contact us at 604-875-2444 or call toll free 1-888-663-3033 if you're outside of Greater Vancouver.</p>
                            
                            <cfmail to="csweeting@bcchf.ca" from="error@bcchf.ca" subject="Error Loading Receipt CFC" type="html">
                            <cfdump var="#cfcatch#">
                            </cfmail>
                            
                            </cfcatch>
                            </cftry>
                    
                    
                        </div>
                        <div class="small-12 medium-4 columns">

                            <h5>Snowball Stats</h5>
                            <dl>
                                <dt>#DollarFormat(selectTransaction.gift)#</dt>
                                <dd>Your donation</dd>
                                <dt>#DollarFormat(totalDonations)#</dt>
                                <dd>Raised so far</dd>
                                <dt>#CountDonations#</dt>
                                <dd>Snowballs thrown</dd>
                            </dl>

                        </div>
                    </div>
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
					<section id="tribute" class="main panel">
                    <div id="formContainer">
					
					<cfinclude template="includes/tribCardInfo.cfm">
					
					</div>
					</section>

				<cfelse>

					<cfset hideSurvey = ''>

				</cfif>

                <section id="thanks-step2" class="panel">
                    <div class="row">
                        <div class="small-12 columns">
                            <h2>Step 2</h2>
                            <h1>You've earned a snowball, now choose how you want to throw it:</h1>
                        </div>
                    </div>
                    <div class="row snowball-throw-styles">
                        <div class="small-12 medium-4 columns">
                            <a href="javascript:void(0)" id="the-corkscrew" data-share="https://www.facebook.com/BCCHF/videos/10155306942110805/" class="selected">
                                <div class="preview">
                                    <video muted playsinline loop poster="images/snowtheme/snowball-preview-1-thumb.jpg">
                                        <source src="videos/BCCH_throw_cork.mov" type="video/mp4">
                                    </video>
                                </div>
                                <h6>The Corkscrew</h6>
                                <div class="indicator"><span></span></div>
                            </a>
                        </div>
                        <div class="small-12 medium-4 columns">
                            <a href="javascript:void(0)" id="the-triple-whammy" data-share="https://www.facebook.com/BCCHF/videos/10155306946090805/">
                                <div class="preview">
                                    <video muted playsinline loop poster="images/snowtheme/snowball-preview-2-thumb.jpg">
                                        <source src="videos/BCCH_throw_triple.mov" type="video/mp4">
                                    </video>
                                </div>
                                <h6>The Triple Whammy</h6>
                                <div class="indicator"><span></span></div>
                            </a>
                        </div>
                        <div class="small-12 medium-4 columns">
                            <a href="javascript:void(0)" id="the-just-chuck-it" data-share="https://www.facebook.com/BCCHF/videos/10155306934990805/">
                                <div class="preview">
                                    <video muted playsinline loop poster="images/snowtheme/snowball-preview-3-thumb.jpg">
                                        <source src="videos/BCCH_throw_straight.mov" type="video/mp4">
                                    </video>
                                </div>
                                <h6>The Just-Chuck-It</h6>
                                <div class="indicator"><span></span></div>
                            </a>
                        </div>
                    </div>
                </section>

                <section id="thanks-step3" class="panel">
                    <div class="row">
                        <div class="small-12 columns">
                            <h2>Step 3</h2>
                            <h1>Share and don't forget to tag the friends you want to hit with your snowball.</h1>
                            <button id="facebook-share"><svg xmlns="http://www.w3.org/2000/svg" width="23.24" height="50" viewBox="0 0 23.24 50"><defs><style>.cls-1{fill:##ffffff;}</style></defs><path class="cls-1" d="M-28.64,712.14h-7v25H-46v-25H-51v-8.83H-46V697.6c0-4.08,1.94-10.48,10.48-10.48l7.69,0v8.57h-5.58a2.12,2.12,0,0,0-2.2,2.41v5.19h7.92Z" transform="translate(50.96 -687.12)"/></svg> Share</button>
                            <p>If you don't have a Facebook account or would prefer not to participate in the snowball fight, that's okay. We've received your donation and appreciate your support over the holiday season.</p>
                        </div>
                    </div>
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
                
		    </article>
        </div>
    </main>
    
    
    <cfinclude template="includes/footer-snowball.cfm">
    
	<script type="text/javascript" src="js/jquery-1.11.3.min.js"></script>
	<script type="text/javascript" src="js/slick.min.js"></script>
	<script type="text/javascript" src="js/jquery.validate.min.js"></script>
	<script type="text/javascript" src="js/default.jquery.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/gsap/1.20.3/TweenMax.min.js"></script>
    <script type="text/javascript" src="js/foundation.min.js"></script>
    <script type="text/javascript" src="js/scripts.min.js?v=4.3"></script>

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
