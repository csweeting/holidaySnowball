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

<cfsetting requesttimeout="70">

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
    <cfset hiddenDonationPCTypeDef = 'personal'>
    
    <!--- <cfif IsDefined('URL.utm_source') AND utm_source EQ 'BCCHwebsite'>
    	<cflocation url="donation-Snowball.cfm?Event=HolidaySnowball&Donation=Gen&SHP=Yes&Monthly=Yes&#CGI.QUERY_STRING#" addtoken="no">
    </cfif> --->
    
    <cfif Now() GT '5/30/2018' AND Now() LT '6/4/2018'>
    	<cfif THIS.EVENT.token EQ 'MW'>
        	<cfif IsDefined('URL.Monthly')>
            <cfelse>
            <!--- no monthly token - we can default to monthly ---->
            <cflocation url="https://secure.bcchf.ca/donate/donation-NEW.cfm?Monthly=Yes&#CGI.QUERY_STRING#" addtoken="no">
            </cfif>
        </cfif>
    </cfif>
    
<cfcatch type="any">
</cfcatch>
</cftry>

</cfsilent>

<!DOCTYPE html>
<html>
<head>
<!--- --->
<!-- Google Tag Manager -->
<script>(function(w,d,s,l,i){w[l]=w[l]||[];w[l].push({'gtm.start':
new Date().getTime(),event:'gtm.js'});var f=d.getElementsByTagName(s)[0],
j=d.createElement(s),dl=l!='dataLayer'?'&l='+l:'';j.async=true;j.src=
'https://www.googletagmanager.com/gtm.js?id='+i+dl;f.parentNode.insertBefore(j,f);
})(window,document,'script','dataLayer','GTM-5B9CK54');</script>
<!-- End Google Tag Manager -->


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
(function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
(i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
})(window,document,'script','//www.google-analytics.com/analytics.js','ga');
ga('create', 'UA-9668481-2', 'auto');
ga('send', 'pageview');
</script>


<meta charset="UTF-8">
<title>BC Children's Hospital Foundation</title>
<meta name="description" content="Support child health with a donation to BC Children's Hospital today.">
<meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />

<!-- Sets whether a web application runs in full-screen mode. -->
<meta name="apple-mobile-web-app-capable" content="yes">

<!-- Use this to enable media queries -->
<meta name="viewport" content="width=device-width, initial-scale=1">

<!-- Enable search engine to index this page and follow links, replace with no-index or no-follow to disable -->
<meta name="robots" content="index, follow">

<!-- basic favicon -->
<link rel="shortcut icon" href="https://www.bcchf.ca/themes/bcchf/favicon.ico" />

<!-- For development -->
<link rel="stylesheet" type="text/css" media="screen" href="../css/combined_secure.css?m=1445910939" />
<cfif THIS.EVENT.token EQ 'HolidaySnowball'>
<link rel="stylesheet" href="css/donate-snowball.css" media="all">
<cfelse>
<link rel="stylesheet" href="css/donate.css" media="all">
</cfif>
<link rel="stylesheet" href="css/slick.css" media="all">

<!-- Typekit settings for Futura font 
<script src="https://use.typekit.net/pcl4xdw.js"></script>
<script>try{Typekit.load({ async: true });}catch(e){}</script>-->

<script type="text/javascript" src="https://use.typekit.com/diz6qqm.js"></script>
<script type="text/javascript">try{Typekit.load();}catch(e){}</script>

</head>

<body class="bcchf_donate"><!--- --->
<!-- Google Tag Manager (noscript) -->
<noscript><iframe src="https://www.googletagmanager.com/ns.html?id=GTM-5B9CK54"
height="0" width="0" style="display:none;visibility:hidden"></iframe></noscript>
<!-- End Google Tag Manager (noscript) --> 

	<header>
		<div class="center">
			<a href="http://bcchf.ca" target="_blank"><img src="images/decorations/bcchf-header-logo.png" alt=""></a>
		</div>
	</header>
	<div class="main center">
        <cfinclude template="includes/topHeadline.cfm">
		<section>
			<!-- Progress bar -->
			<div class="bcchf_progress bcchf_progress_step1 js_bcchf_progress">
				<div>
					<p>Step <span class="js_bcchf_step_num">1</span> of 4</p>
					<div class="bcchf_progress_check"></div>
				</div>
				<div>
					<div class="bcchf_progress_check"></div>
				</div>
				<div>
					<div class="bcchf_progress_check"></div>
				</div>
				<div>
					<div class="bcchf_progress_check"></div>
				</div>
			</div>

			<div id="formContainer">
				
                <cfinclude template="includes/generalForm.cfm">
			
            </div><!--- end of form container ---->
            
           <!--- PW Container ---->
           <div id="mainDonationFormWaitMessageContainer" style="display:none; font-family: 'Calibri', Verdana, Arial, sans-serif; line-height:1.3;" align="center"  >
           Please wait a moment while we process your transaction...<br />
           <img src="../images/ajax-progress.gif" width="220" height="19" alt="Please Wait" />
           </div>
            
		</section>
	</div>
	<cfinclude template="includes/footer.cfm">

	<script type="text/javascript" src="//ajax.googleapis.com/ajax/libs/jquery/3.3.1/jquery.min.js"></script>
	<!--- ---><script type="text/javascript" src="js/slick.min.js"></script> 
	<script type="text/javascript" src="js/jquery.validate.min.js"></script>
	<script type="text/javascript" src="js/additional-methods.min.js"></script>
    <script type="text/javascript" src="../js/exactResponseMessages.js"></script>
	<script type="text/javascript" src="js/default.jquery.js?v=20180511"></script>
    <script type="text/javascript" src="../js/ua-parser.js"></script>
    
    <script type="text/javascript">
	<!--
	var parser = new UAParser();
	var uastring = <cfoutput>"#CGI.HTTP_USER_AGENT#"</cfoutput>;
	var result = UAParser(uastring);

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
    
</body>
</html>
