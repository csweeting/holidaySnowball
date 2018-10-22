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
    
<cfcatch type="any">
</cfcatch>
</cftry>

</cfsilent>

<!DOCTYPE html>
<html>
<head>

<!-- Google Tag Manager -->
<script>(function(w,d,s,l,i){w[l]=w[l]||[];w[l].push({'gtm.start':
new Date().getTime(),event:'gtm.js'});var f=d.getElementsByTagName(s)[0],
j=d.createElement(s),dl=l!='dataLayer'?'&l='+l:'';j.async=true;j.src=
'https://www.googletagmanager.com/gtm.js?id='+i+dl;f.parentNode.insertBefore(j,f);
})(window,document,'script','dataLayer','GTM-5B9CK54');</script>
<!-- End Google Tag Manager -->

<!-- GA pageview -->
<script type="text/javascript">
	(function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
	(i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
	m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
	})(window,document,'script','//www.google-analytics.com/analytics.js','ga');
	ga('create', 'UA-9668481-2', 'auto');
	ga('send', 'pageview');
</script>
<!-- end of GA pageview -->




<meta charset="UTF-8">
<title>BC Children's Hospital Foundation</title>
<meta name="description" content="A description of the page.">
<meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />

<!-- Sets whether a web application runs in full-screen mode. -->
<meta name="apple-mobile-web-app-capable" content="yes">

<!-- Use this to enable media queries -->
<meta name="viewport" content="width=device-width, initial-scale=1">

<!-- Enable search engine to index this page and follow links, replace with no-index or no-follow to disable -->
<meta name="robots" content="noindex">

<link href="css/vaccine.css" rel="stylesheet">
<link href="https://fonts.googleapis.com/css?family=Roboto:400,400i,500,700" rel="stylesheet">

<!-- basic favicon -->
<link rel="shortcut icon" href="https://www.bcchf.ca/themes/bcchf/favicon.ico" />

<!-- For development 
<link rel="stylesheet" type="text/css" media="screen" href="../css/combined_secure.css?m=1445910939" />-->
<link rel="stylesheet" href="css/footer.css" media="all">
<link rel="stylesheet" href="css/donate-snowball.css?v=4.6" media="all">
<link rel="stylesheet" href="css/slick.css" media="all">
<link rel="stylesheet" href="css/style.css?v=4.5" media="all">

<!-- Typekit settings for Futura font 
<script src="https://use.typekit.net/pcl4xdw.js"></script>
<script>try{Typekit.load({ async: true });}catch(e){}</script>


<script type="text/javascript" src="https://use.typekit.com/diz6qqm.js"></script>
<script type="text/javascript">try{Typekit.load();}catch(e){}</script>
-->

</head>

<body class="bcchf_donate">
<!-- Google Tag Manager (noscript) -->
<noscript><iframe src="https://www.googletagmanager.com/ns.html?id=GTM-5B9CK54"
height="0" width="0" style="display:none;visibility:hidden"></iframe></noscript>
<!-- End Google Tag Manager (noscript) -->

	<header>
		<div class="center">
			<a href="http://bcchf.ca" target="_blank"><img src="images/snowtheme/logo-tag.png" width="175" height="166" alt=""></a>
		</div>
	</header>
	<div class="main center">
		<!--- <h2>Step 1</h2> --->
        <cfinclude template="includes/topHeadline-snowball.cfm">
		<section>
			<!-- Progress bar -->
			<div class="bcchf_progress bcchf_progress_step1 js_bcchf_progress">
				<div>
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
				
                <cfinclude template="includes/snowballForm.cfm">
			
            </div><!--- end of form container ---->
            
           <!--- PW Container ---->
           <div id="mainDonationFormWaitMessageContainer" style="display:none; font-family: 'Calibri', Verdana, Arial, sans-serif; line-height:1.3;" align="center"  >
           Please wait a moment while we process your transaction...<br />
           <img src="../images/ajax-progress.gif" width="220" height="19" alt="Please Wait" />
           </div>
            
		</section>
	</div>

	<script type="text/javascript" src="//ajax.googleapis.com/ajax/libs/jquery/3.3.1/jquery.min.js"></script>
	<!--- ---><script type="text/javascript" src="js/slick.min.js"></script> 
	<script type="text/javascript" src="js/jquery.validate.min.js"></script>
	<script type="text/javascript" src="js/additional-methods.min.js"></script>
    <script type="text/javascript" src="../js/exactResponseMessages.js"></script>
	<script type="text/javascript" src="js/snowball.jquery.js?v=4.0"></script>
    <script type="text/javascript" src="../js/ua-parser.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/gsap/1.20.3/TweenMax.min.js"></script>
    <script type="text/javascript" src="js/foundation.min.js"></script>
    <script type="text/javascript" src="js/scripts.min.js?v=4.4"></script>
    
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
    
    <!--- TEST IDLE CODE --->
	<script type="text/javascript">
    var idleTime = 0;
	( function($) {
    $(document).ready(function () {
        //Increment the idle time counter every minute.
        var idleInterval = setInterval(timerIncrement, 60000); // 60000 = 1 minute
    
        //Zero the idle timer on mouse movement.
        $(this).mousemove(function (e) {
            idleTime = 0;
        });
		$(this).scroll(function (e) {
            idleTime = 0;
        });
		/* $(this).tap(function (e) {
            idleTime = 0;
            console.log('reset timer (tap)');
        }); */
        $(this).keypress(function (e) {
            idleTime = 0;
        });
    });
	} ) ( jQuery );
    
    function timerIncrement() {
        idleTime = idleTime + 1;
        if (idleTime > 1) { // 19 = 20 minutes
            window.location.reload();
        }
    }
    </script>   
    
</body>
</html>
