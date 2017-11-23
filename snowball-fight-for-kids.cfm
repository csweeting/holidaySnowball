<cfsilent>

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
   
	<script type="text/javascript">

	(function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
	(i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
	m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
	})(window,document,'script','//www.google-analytics.com/analytics.js','ga');
	ga('create', 'UA-9668481-2', 'auto');
	ga('send', 'pageview');
    	

	</script>
      
    <meta charset="UTF-8">
    <title>BC Children's Hospital Foundation | The Big Snowball Fight for Kids</title>
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />

    <meta name="apple-mobile-web-app-capable" content="yes">

    <meta name="viewport" content="width=device-width, initial-scale=1">

    <link href="css/vaccine.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css?family=Roboto:400,400i,500,700" rel="stylesheet">

    <link rel="shortcut icon" href="https://www.bcchf.ca/themes/bcchf/favicon.ico" />

    <meta property="fb:app_id" content="132100647417767"/>
    <meta property="og:type" content="article"/>
    <meta property="og:title" content="Join the Big BC Snowball Fight for Kids"/>
    <meta property="og:site_name" content="BC Children's Hospital Foundation"/>
    <meta property="og:description" content="Show your support for BC Children's Hospital by participating in BC's biggest digital snowball fight." />
    <meta property="og:url" content="https://secure.bcchf.ca/donate/snowball-fight-for-kids.cfm"/>
    <meta property="og:image" content="https://secure.bcchf.ca/donate/images/snowtheme/the-big-snowball-fight-for-kids.png"/>
    <meta property="og:image:width" content="1200"/>
    <meta property="og:image:height" content="630"/>
    
    <link rel="stylesheet" href="css/style.css?v=4.0" media="all">

</head>
<body class="bcchf_snowball">
<!-- Google Tag Manager (noscript) -->
<noscript><iframe src="https://www.googletagmanager.com/ns.html?id=GTM-5B9CK54"
height="0" width="0" style="display:none;visibility:hidden"></iframe></noscript>
<!-- End Google Tag Manager (noscript) -->   
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

    <header class="site-header">
        <div class="row">
            <div class="small-12 medium-6 columns">
                <a href="http://bcchf.ca" target="_blank"><img src="images/snowtheme/logo-tag.png" width="175" height="166" alt=""></a>
            </div>
            <div class="small-12 medium-6 columns">
                <div id="counter">
                    <h4>Snowballs Thrown:</h4>
                    <cfoutput>
                    <div class="throwCount odometer" data-value="#countDonations#"></div>
                    </cfoutput>
                </div>
            </div>
        </div>
    </header>

    <main id="snowball-container" class="site-content bcchf_snowball_page">

        <section id="slides">
            <div style="background-image: url(images/snowtheme/slides-compressed/BCCH_landingpage_deliverable_00000.jpg);"></div>
            <div style="background-image: url(images/snowtheme/slides-compressed/BCCH_landingpage_deliverable_00001.jpg);"></div>
            <div style="background-image: url(images/snowtheme/slides-compressed/BCCH_landingpage_deliverable_00002.jpg);"></div>
            <div style="background-image: url(images/snowtheme/slides-compressed/BCCH_landingpage_deliverable_00003.jpg);"></div>
            <div style="background-image: url(images/snowtheme/slides-compressed/BCCH_landingpage_deliverable_00004.jpg);"></div>
            <div style="background-image: url(images/snowtheme/slides-compressed/BCCH_landingpage_deliverable_00005.jpg);"></div>
            <div style="background-image: url(images/snowtheme/slides-compressed/BCCH_landingpage_deliverable_00006.jpg);"></div>
            <div style="background-image: url(images/snowtheme/slides-compressed/BCCH_landingpage_deliverable_00007.jpg);"></div>
            <div style="background-image: url(images/snowtheme/slides-compressed/BCCH_landingpage_deliverable_00008.jpg);"></div>
            <div style="background-image: url(images/snowtheme/slides-compressed/BCCH_landingpage_deliverable_00009.jpg);"></div>
            <div style="background-image: url(images/snowtheme/slides-compressed/BCCH_landingpage_deliverable_00010.jpg);"></div>
            <div style="background-image: url(images/snowtheme/slides-compressed/BCCH_landingpage_deliverable_00011.jpg);"></div>
            <div style="background-image: url(images/snowtheme/slides-compressed/BCCH_landingpage_deliverable_00012.jpg);"></div>
            <div style="background-image: url(images/snowtheme/slides-compressed/BCCH_landingpage_deliverable_00013.jpg);"></div>
            <div style="background-image: url(images/snowtheme/slides-compressed/BCCH_landingpage_deliverable_00014.jpg);"></div>
            <div style="background-image: url(images/snowtheme/slides-compressed/BCCH_landingpage_deliverable_00015.jpg);"></div>
            <div style="background-image: url(images/snowtheme/slides-compressed/BCCH_landingpage_deliverable_00016.jpg);"></div>
            <div style="background-image: url(images/snowtheme/slides-compressed/BCCH_landingpage_deliverable_00017.jpg);"></div>
            <div style="background-image: url(images/snowtheme/slides-compressed/BCCH_landingpage_deliverable_00018.jpg);"></div>
            <div style="background-image: url(images/snowtheme/slides-compressed/BCCH_landingpage_deliverable_00019.jpg);"></div>
            <div style="background-image: url(images/snowtheme/slides-compressed/BCCH_landingpage_deliverable_00020.jpg);"></div>
            <div style="background-image: url(images/snowtheme/slides-compressed/BCCH_landingpage_deliverable_00021.jpg);"></div>
            <div style="background-image: url(images/snowtheme/slides-compressed/BCCH_landingpage_deliverable_00022.jpg);"></div>
            <div style="background-image: url(images/snowtheme/slides-compressed/BCCH_landingpage_deliverable_00023.jpg);"></div>
            <div style="background-image: url(images/snowtheme/slides-compressed/BCCH_landingpage_deliverable_00024.jpg);"></div>
            <div style="background-image: url(images/snowtheme/slides-compressed/BCCH_landingpage_deliverable_00025.jpg);"></div>
            <div style="background-image: url(images/snowtheme/slides-compressed/BCCH_landingpage_deliverable_00026.jpg);"></div>
            <div style="background-image: url(images/snowtheme/slides-compressed/BCCH_landingpage_deliverable_00027.jpg);"></div>
            <div style="background-image: url(images/snowtheme/slides-compressed/BCCH_landingpage_deliverable_00028.jpg);"></div>
            <div style="background-image: url(images/snowtheme/slides-compressed/BCCH_landingpage_deliverable_00029.jpg);"></div>
            <div style="background-image: url(images/snowtheme/slides-compressed/BCCH_landingpage_deliverable_00030.jpg);"></div>
            <div style="background-image: url(images/snowtheme/slides-compressed/BCCH_landingpage_deliverable_00031.jpg);"></div>
            <div style="background-image: url(images/snowtheme/slides-compressed/BCCH_landingpage_deliverable_00032.jpg);"></div>
            <div style="background-image: url(images/snowtheme/slides-compressed/BCCH_landingpage_deliverable_00033.jpg);"></div>
            <div style="background-image: url(images/snowtheme/slides-compressed/BCCH_landingpage_deliverable_00034.jpg);"></div>
            <div style="background-image: url(images/snowtheme/slides-compressed/BCCH_landingpage_deliverable_00035.jpg);"></div>
            <div style="background-image: url(images/snowtheme/slides-compressed/BCCH_landingpage_deliverable_00036.jpg);"></div>
            <div style="background-image: url(images/snowtheme/slides-compressed/BCCH_landingpage_deliverable_00037.jpg);"></div>
            <div style="background-image: url(images/snowtheme/slides-compressed/BCCH_landingpage_deliverable_00038.jpg);"></div>
            <div style="background-image: url(images/snowtheme/slides-compressed/BCCH_landingpage_deliverable_00039.jpg);"></div>
            <div style="background-image: url(images/snowtheme/slides-compressed/BCCH_landingpage_deliverable_00040.jpg);"></div>
            <div style="background-image: url(images/snowtheme/slides-compressed/BCCH_landingpage_deliverable_00041.jpg);"></div>
            <div style="background-image: url(images/snowtheme/slides-compressed/BCCH_landingpage_deliverable_00042.jpg);"></div>
            <div style="background-image: url(images/snowtheme/slides-compressed/BCCH_landingpage_deliverable_00043.jpg);"></div>
            <div style="background-image: url(images/snowtheme/slides-compressed/BCCH_landingpage_deliverable_00044.jpg);"></div>
            <div style="background-image: url(images/snowtheme/slides-compressed/BCCH_landingpage_deliverable_00045.jpg);"></div>
            <div style="background-image: url(images/snowtheme/slides-compressed/BCCH_landingpage_deliverable_00046.jpg);"></div>
            <div style="background-image: url(images/snowtheme/slides-compressed/BCCH_landingpage_deliverable_00047.jpg);"></div>
            <div style="background-image: url(images/snowtheme/slides-compressed/BCCH_landingpage_deliverable_00048.jpg);"></div>
            <div style="background-image: url(images/snowtheme/slides-compressed/BCCH_landingpage_deliverable_00049.jpg);"></div>
            <div style="background-image: url(images/snowtheme/slides-compressed/BCCH_landingpage_deliverable_00050.jpg);"></div>
            <div style="background-image: url(images/snowtheme/slides-compressed/BCCH_landingpage_deliverable_00051.jpg);"></div>
            <div style="background-image: url(images/snowtheme/slides-compressed/BCCH_landingpage_deliverable_00052.jpg);"></div>
            <div style="background-image: url(images/snowtheme/slides-compressed/BCCH_landingpage_deliverable_00053.jpg);"></div>
            <div style="background-image: url(images/snowtheme/slides-compressed/BCCH_landingpage_deliverable_00054.jpg);"></div>
            <div style="background-image: url(images/snowtheme/slides-compressed/BCCH_landingpage_deliverable_00055.jpg);"></div>
            <div style="background-image: url(images/snowtheme/slides-compressed/BCCH_landingpage_deliverable_00056.jpg);"></div>
            <div style="background-image: url(images/snowtheme/slides-compressed/BCCH_landingpage_deliverable_00057.jpg);"></div>
            <div style="background-image: url(images/snowtheme/slides-compressed/BCCH_landingpage_deliverable_00058.jpg);"></div>
            <div style="background-image: url(images/snowtheme/slides-compressed/BCCH_landingpage_deliverable_00059.jpg);"></div>
            <div style="background-image: url(images/snowtheme/slides-compressed/BCCH_landingpage_deliverable_00060.jpg);"></div>
            <div style="background-image: url(images/snowtheme/slides-compressed/BCCH_landingpage_deliverable_00061.jpg);"></div>
            <div style="background-image: url(images/snowtheme/slides-compressed/BCCH_landingpage_deliverable_00062.jpg);"></div>
            <div style="background-image: url(images/snowtheme/slides-compressed/BCCH_landingpage_deliverable_00063.jpg);"></div>
            <div style="background-image: url(images/snowtheme/slides-compressed/BCCH_landingpage_deliverable_00064.jpg);"></div>
            <div style="background-image: url(images/snowtheme/slides-compressed/BCCH_landingpage_deliverable_00065.jpg);"></div>
            <div style="background-image: url(images/snowtheme/slides-compressed/BCCH_landingpage_deliverable_00066.jpg);"></div>
            <div style="background-image: url(images/snowtheme/slides-compressed/BCCH_landingpage_deliverable_00067.jpg);"></div>
            <div style="background-image: url(images/snowtheme/slides-compressed/BCCH_landingpage_deliverable_00068.jpg);"></div>
            <div style="background-image: url(images/snowtheme/slides-compressed/BCCH_landingpage_deliverable_00069.jpg);"></div>
            <div style="background-image: url(images/snowtheme/slides-compressed/BCCH_landingpage_deliverable_00070.jpg);"></div>
            <div style="background-image: url(images/snowtheme/slides-compressed/BCCH_landingpage_deliverable_00071.jpg);"></div>
            <div style="background-image: url(images/snowtheme/slides-compressed/BCCH_landingpage_deliverable_00072.jpg);"></div>
            <div style="background-image: url(images/snowtheme/slides-compressed/BCCH_landingpage_deliverable_00073.jpg);"></div>
            <div style="background-image: url(images/snowtheme/slides-compressed/BCCH_landingpage_deliverable_00074.jpg);"></div>
            <div style="background-image: url(images/snowtheme/slides-compressed/BCCH_landingpage_deliverable_00075.jpg);"></div>
            <div style="background-image: url(images/snowtheme/slides-compressed/BCCH_landingpage_deliverable_00076.jpg);"></div>
            <div style="background-image: url(images/snowtheme/slides-compressed/BCCH_landingpage_deliverable_00077.jpg);"></div>
            <div style="background-image: url(images/snowtheme/slides-compressed/BCCH_landingpage_deliverable_00078.jpg);"></div>
            <div style="background-image: url(images/snowtheme/slides-compressed/BCCH_landingpage_deliverable_00079.jpg);"></div>
            <div style="background-image: url(images/snowtheme/slides-compressed/BCCH_landingpage_deliverable_00080.jpg);"></div>
            <div style="background-image: url(images/snowtheme/slides-compressed/BCCH_landingpage_deliverable_00081.jpg);"></div>
            <div style="background-image: url(images/snowtheme/slides-compressed/BCCH_landingpage_deliverable_00082.jpg);"></div>
            <div style="background-image: url(images/snowtheme/slides-compressed/BCCH_landingpage_deliverable_00083.jpg);"></div>
            <div style="background-image: url(images/snowtheme/slides-compressed/BCCH_landingpage_deliverable_00084.jpg);"></div>
            <div style="background-image: url(images/snowtheme/slides-compressed/BCCH_landingpage_deliverable_00085.jpg);"></div>
            <div style="background-image: url(images/snowtheme/slides-compressed/BCCH_landingpage_deliverable_00086.jpg);"></div>
            <div style="background-image: url(images/snowtheme/slides-compressed/BCCH_landingpage_deliverable_00087.jpg);"></div>
            <div style="background-image: url(images/snowtheme/slides-compressed/BCCH_landingpage_deliverable_00088.jpg);"></div>
            <div style="background-image: url(images/snowtheme/slides-compressed/BCCH_landingpage_deliverable_00089.jpg);"></div>
            <div style="background-image: url(images/snowtheme/slides-compressed/BCCH_landingpage_deliverable_00090.jpg);"></div>
            <div style="background-image: url(images/snowtheme/slides-compressed/BCCH_landingpage_deliverable_00091.jpg);"></div>
            <div style="background-image: url(images/snowtheme/slides-compressed/BCCH_landingpage_deliverable_00092.jpg);"></div>
            <div style="background-image: url(images/snowtheme/slides-compressed/BCCH_landingpage_deliverable_00093.jpg);"></div>
            <div style="background-image: url(images/snowtheme/slides-compressed/BCCH_landingpage_deliverable_00094.jpg);"></div>
            <div style="background-image: url(images/snowtheme/slides-compressed/BCCH_landingpage_deliverable_00095.jpg);"></div>
            <div style="background-image: url(images/snowtheme/slides-compressed/BCCH_landingpage_deliverable_00096.jpg);"></div>
            <div style="background-image: url(images/snowtheme/slides-compressed/BCCH_landingpage_deliverable_00097.jpg);"></div>
            <div style="background-image: url(images/snowtheme/slides-compressed/BCCH_landingpage_deliverable_00098.jpg);"></div>
            <div style="background-image: url(images/snowtheme/slides-compressed/BCCH_landingpage_deliverable_00099.jpg);"></div>
            <div style="background-image: url(images/snowtheme/slides-compressed/BCCH_landingpage_deliverable_00100.jpg);"></div>
            <div style="background-image: url(images/snowtheme/slides-compressed/BCCH_landingpage_deliverable_00101.jpg);"></div>
            <div style="background-image: url(images/snowtheme/slides-compressed/BCCH_landingpage_deliverable_00102.jpg);"></div>
            <div style="background-image: url(images/snowtheme/slides-compressed/BCCH_landingpage_deliverable_00103.jpg);"></div>
            <div style="background-image: url(images/snowtheme/slides-compressed/BCCH_landingpage_deliverable_00104.jpg);"></div>
            <div style="background-image: url(images/snowtheme/slides-compressed/BCCH_landingpage_deliverable_00105.jpg);"></div>
            <div style="background-image: url(images/snowtheme/slides-compressed/BCCH_landingpage_deliverable_00106.jpg);"></div>
            <div style="background-image: url(images/snowtheme/slides-compressed/BCCH_landingpage_deliverable_00107.jpg);"></div>
            <div style="background-image: url(images/snowtheme/slides-compressed/BCCH_landingpage_deliverable_00108.jpg);"></div>
            <div style="background-image: url(images/snowtheme/slides-compressed/BCCH_landingpage_deliverable_00109.jpg);"></div>
            <div style="background-image: url(images/snowtheme/slides-compressed/BCCH_landingpage_deliverable_00110.jpg);"></div>
            <div style="background-image: url(images/snowtheme/slides-compressed/BCCH_landingpage_deliverable_00111.jpg);"></div>
            <div style="background-image: url(images/snowtheme/slides-compressed/BCCH_landingpage_deliverable_00112.jpg);"></div>
            <div style="background-image: url(images/snowtheme/slides-compressed/BCCH_landingpage_deliverable_00113.jpg);"></div>
            <div style="background-image: url(images/snowtheme/slides-compressed/BCCH_landingpage_deliverable_00114.jpg);"></div>
            <div style="background-image: url(images/snowtheme/slides-compressed/BCCH_landingpage_deliverable_00115.jpg);"></div>
            <div style="background-image: url(images/snowtheme/slides-compressed/BCCH_landingpage_deliverable_00116.jpg);"></div>
            <div style="background-image: url(images/snowtheme/slides-compressed/BCCH_landingpage_deliverable_00117.jpg);"></div>
            <div style="background-image: url(images/snowtheme/slides-compressed/BCCH_landingpage_deliverable_00118.jpg);"></div>
            <div style="background-image: url(images/snowtheme/slides-compressed/BCCH_landingpage_deliverable_00119.jpg);"></div>
            <div style="background-image: url(images/snowtheme/slides-compressed/BCCH_landingpage_deliverable_00120.jpg);"></div>
            <div style="background-image: url(images/snowtheme/slides-compressed/BCCH_landingpage_deliverable_00121.jpg);"></div>
            <div style="background-image: url(images/snowtheme/slides-compressed/BCCH_landingpage_deliverable_00122.jpg);"></div>
            <div style="background-image: url(images/snowtheme/slides-compressed/BCCH_landingpage_deliverable_00123.jpg);"></div>
            <div style="background-image: url(images/snowtheme/slides-compressed/BCCH_landingpage_deliverable_00124.jpg);"></div>
            <div style="background-image: url(images/snowtheme/slides-compressed/BCCH_landingpage_deliverable_00125.jpg);"></div>
            <div style="background-image: url(images/snowtheme/slides-compressed/BCCH_landingpage_deliverable_00126.jpg);"></div>
            <div style="background-image: url(images/snowtheme/slides-compressed/BCCH_landingpage_deliverable_00127.jpg);"></div>
            <div style="background-image: url(images/snowtheme/slides-compressed/BCCH_landingpage_deliverable_00128.jpg);"></div>
            <div style="background-image: url(images/snowtheme/slides-compressed/BCCH_landingpage_deliverable_00129.jpg);"></div>
            <div style="background-image: url(images/snowtheme/slides-compressed/BCCH_landingpage_deliverable_00130.jpg);"></div>
            <div style="background-image: url(images/snowtheme/slides-compressed/BCCH_landingpage_deliverable_00131.jpg);"></div>
            <div style="background-image: url(images/snowtheme/slides-compressed/BCCH_landingpage_deliverable_00132.jpg);"></div>
            <div style="background-image: url(images/snowtheme/slides-compressed/BCCH_landingpage_deliverable_00133.jpg);"></div>
            <div style="background-image: url(images/snowtheme/slides-compressed/BCCH_landingpage_deliverable_00134.jpg);"></div>
            <div style="background-image: url(images/snowtheme/slides-compressed/BCCH_landingpage_deliverable_00135.jpg);"></div>
            <div style="background-image: url(images/snowtheme/slides-compressed/BCCH_landingpage_deliverable_00136.jpg);"></div>
            <div style="background-image: url(images/snowtheme/slides-compressed/BCCH_landingpage_deliverable_00137.jpg);"></div>
            <div style="background-image: url(images/snowtheme/slides-compressed/BCCH_landingpage_deliverable_00138.jpg);"></div>
            <div style="background-image: url(images/snowtheme/slides-compressed/BCCH_landingpage_deliverable_00139.jpg);"></div>
            <div style="background-image: url(images/snowtheme/slides-compressed/BCCH_landingpage_deliverable_00140.jpg);"></div>
            <div style="background-image: url(images/snowtheme/slides-compressed/BCCH_landingpage_deliverable_00141.jpg);"></div>
            <div style="background-image: url(images/snowtheme/slides-compressed/BCCH_landingpage_deliverable_00142.jpg);"></div>
            <div style="background-image: url(images/snowtheme/slides-compressed/BCCH_landingpage_deliverable_00143.jpg);"></div>
        </section>

        <section id="screen_h">
            <article id="screen-1" class="screen">
                <div class="row align-middle">
                    <div class="small-12 columns">
                        <h1>
                            <small>Join the</small>
                            <br />Big BC <br />Snowball <br />Fight <br />for Kids
                        </h1>
                    </div>
                </div>
            </article>

            <article id="screen-2" class="screen">
                <div class="row align-middle">
                    <div class="small-12 columns">
                        <p>This season, show kids <br />you care by making a <br />donation to participate <br />in BC’s biggest digital <br />snowball fight. Supporting <br />kids is easy as 1-2-3.</p>
                    </div>
                </div>
            </article>

            <article id="screen-3" class="screen">
                <div class="row align-middle">
                    <div class="small-12 columns">
                        <h2>
                             <small>Step 1</small>
                             <br />Donate <br />to get a <br />snowball.
                        </h2>
                    </div>
                </div>
            </article>

            <article id="screen-4" class="screen">
                <div class="row align-middle">
                    <div class="small-12 columns">
                        <h2>
                             <small>Step 2</small>
                             <br />Choose <br />how you <br />want to <br />throw it.
                        </h2>
                    </div>
                </div>
            </article>

            <article id="screen-5" class="screen">
                <div class="row align-middle">
                    <div class="small-12 columns">
                        <h2>
                             <small>Step 3</small>
                             <br />Tag <br />friends <br />you want <br />to hit.
                        </h2>
                        <p><a href="donation.cfm?Event=HolidaySnowball&amp;Donation=Gen&amp;SHP=Yes&amp;Monthly=Yes" class="button">Let's get started</a></p>
                    </div>
                </div>
            </article>
        </section>

        <nav id="screen-nav">
            <a href="#snowball-container" class="selected"></a>
            <a href="#screen-1-trigger-out"></a>
            <a href="#screen-2-trigger-out"></a>
            <a href="#screen-3-trigger-out"></a>
            <a href="#screen-4-trigger-out"></a>
        </nav>

        <div id="screen-1-trigger-out" class="screen-trigger"></div>
        <div id="screen-2-trigger-out" class="screen-trigger"></div>
        <div id="screen-3-trigger-out" class="screen-trigger"></div>
        <div id="screen-4-trigger-out" class="screen-trigger"></div>

        <div class="spinner"><div class="bounce1"></div><div class="bounce2"></div><div class="bounce3"></div></div>
        <button id="cta"><svg xmlns="http://www.w3.org/2000/svg" width="72" height="72" viewBox="0 0 72 72"><defs><style>.cta-1{fill:#19bfd3;}</style></defs><path class="cta-1 cta-circle" d="M100.67,851.47a36,36,0,1,1,36-36A36,36,0,0,1,100.67,851.47Zm0-63.65a27.65,27.65,0,1,0,27.65,27.65A27.68,27.68,0,0,0,100.67,787.81Z" transform="translate(-64.67 -779.47)"/><path class="cta-1 cta-arrow" d="M100.67,827a4.16,4.16,0,0,1-3-1.22l-12-12a4.17,4.17,0,1,1,5.9-5.9l9.09,9.09,9.09-9.09a4.17,4.17,0,1,1,5.9,5.9l-12,12A4.16,4.16,0,0,1,100.67,827Z" transform="translate(-64.67 -779.47)"/></svg></button>
    </main>
    
    <script type="text/javascript" src="js/jquery-1.11.3.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/gsap/1.20.3/TweenMax.min.js"></script>
    <script type="text/javascript" src="js/foundation.min.js"></script>
    <script type="text/javascript" src="js/scripts.min.js?v=4.0"></script>
</body>
</html>