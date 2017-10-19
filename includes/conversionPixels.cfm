<cfoutput>
<cfif Trim(selectTransaction.gift_type) EQ 'DM'>

	<cfif selectTransaction.TeamID EQ 11657 
        OR selectTransaction.TeamID EQ 11658>
    
    <!--- 2017 Acq 1 Google Conversion tracking --->
    <!-- Google Code -->
    <script type="text/javascript">
	/* <![CDATA[ */
	var google_conversion_id = 855917578;
	var google_conversion_language = "en";
	var google_conversion_format = "3";
	var google_conversion_color = "ffffff";
	var google_conversion_label = "l3pDCIGutnAQioiRmAM";
    var google_conversion_value = #selectTransaction.gift#;
    var google_conversion_currency = "CAD";
    var google_remarketing_only = false;
    /* ]]> */
    </script>
    <script type="text/javascript" src="//www.googleadservices.com/pagead/conversion.js">
    </script>
    <noscript>
    <div style="display:inline;">
    <img height="1" width="1" style="border-style:none;" alt="" src="//www.googleadservices.com/pagead/conversion/855917578/?value=#selectTransaction.gift#&amp;currency_code=CAD&amp;label=l3pDCIGutnAQioiRmAM&amp;guid=ON&amp;script=0"/>
    </div>
    </noscript>
    
    </cfif>

	<!---- 2017 Acq1 Facebook Conversion Tracking --->
    <cfif selectTransaction.TeamID EQ 11659>
    
    <script>
    !function(f,b,e,v,n,t,s){if(f.fbq)return;n=f.fbq=function(){n.callMethod?
    n.callMethod.apply(n,arguments):n.queue.push(arguments)};if(!f._fbq)f._fbq=n;
    n.push=n;n.loaded=!0;n.version='2.0';n.queue=[];t=b.createElement(e);t.async=!0;
    t.src=v;s=b.getElementsByTagName(e)[0];s.parentNode.insertBefore(t,s)}(window,
    document,'script','https://connect.facebook.net/en_US/fbevents.js');
    fbq('init', '1763865263874667'); // Insert your pixel ID here.
    fbq('track', 'PageView');
	fbq('track', 'Purchase',{value: #NumberFormat(selectTransaction.gift, 9.99)#,currency: 'CAD'});
    </script>
    <noscript><img height="1" width="1" style="display:none"
    src="https://www.facebook.com/tr?id=1763865263874667&ev=PageView&noscript=1"
    /></noscript>
    
    
    </cfif>

	<!--- 2016 CCHF Campaign Conversion Code --->
    <cfif selectTransaction.TeamID EQ 11086>
    
    <!--
    Start of DoubleClick Floodlight Tag: Please do not remove
    Activity name of this tag: CCHF - BC Childrens Hospital Foundation - Confirmation
    URL of the webpage where the tag is expected to be placed: http://CCHF - BC Childrens Hospital Foundation - Confirmation
    This tag must be placed between the <body> and </body> tags, as close as possible to the opening tag.
    Creation Date: 09/13/2016
    -->
    <script type="text/javascript">
    var axel = Math.random() + "";
    var a = axel * 10000000000000;
    document.write('<iframe src="https://5627812.fls.doubleclick.net/activityi;src=5627812;type=cchfg0;cat=cchf-00;dc_lat=;dc_rdid=;tag_for_child_directed_treatment=;ord=#selectTransaction.generalID#;num=' + a + '?" width="1" height="1" frameborder="0" style="display:none"></iframe>');
    </script>
    <noscript>
    <iframe src="https://5627812.fls.doubleclick.net/activityi;src=5627812;type=cchfg0;cat=cchf-00;dc_lat=;dc_rdid=;tag_for_child_directed_treatment=;ord=#selectTransaction.generalID#;num=1?" width="1" height="1" frameborder="0" style="display:none"></iframe>
    </noscript>
    <!-- End of DoubleClick Floodlight Tag: Please do not remove -->
    
    
    </cfif>

	<!--- 2016 Renewal 2 Conversion Code --->
    <cfif selectTransaction.TeamID EQ 11086>
    
    <!-- Facebook Pixel Code -->
    <script>
    !function(f,b,e,v,n,t,s){if(f.fbq)return;n=f.fbq=function(){n.callMethod?
    n.callMethod.apply(n,arguments):n.queue.push(arguments)};if(!f._fbq)f._fbq=n;
    n.push=n;n.loaded=!0;n.version='2.0';n.queue=[];t=b.createElement(e);t.async=!0;
    t.src=v;s=b.getElementsByTagName(e)[0];s.parentNode.insertBefore(t,s)}(window,
    document,'script','https://connect.facebook.net/en_US/fbevents.js');
    
    fbq('init', '1763865263874667');
    fbq('track', "PageView");
    fbq('track', 'Purchase', {value: '#selectTransaction.gift#', currency: 'CAD'});</script>
    <noscript><img height="1" width="1" style="display:none"
    src="https://www.facebook.com/tr?id=1763865263874667&ev=PageView&noscript=1"
    /></noscript>
    <!-- End Facebook Pixel Code -->
    
    <!-- Google Code for BC Hospital Campaign Sept 2016 Conversion Page -->
    <script type="text/javascript">
    /* <![CDATA[ */
    var google_conversion_id = 873682659;
    var google_conversion_language = "en";
    var google_conversion_format = "3";
    var google_conversion_color = "ffffff";
    var google_conversion_label = "WsTgCPiik2oQ463NoAM";
    var google_remarketing_only = false;
    /* ]]> */
    </script>
    <script type="text/javascript"  
    src="//www.googleadservices.com/pagead/conversion.js">
    </script>
    <noscript>
    <div style="display:inline;">
    <img height="1" width="1" style="border-style:none;" alt=""  
    src="//www.googleadservices.com/pagead/conversion/873682659/?label=WsTgCPiik2oQ463NoAM&amp;guid=ON&amp;script=0"/>
    </div>
    </noscript>
    
	</cfif>

	<cfif selectTransaction.TeamID EQ 11085>

	<!-- Google Code for BC Hospital Campaign Sept 2016 Conversion Page -->
    <script type="text/javascript">
    /* <![CDATA[ */
    var google_conversion_id = 873682659;
    var google_conversion_language = "en";
    var google_conversion_format = "3";
    var google_conversion_color = "ffffff";
    var google_conversion_label = "WsTgCPiik2oQ463NoAM";
    var google_remarketing_only = false;
    /* ]]> */
    </script>
    <script type="text/javascript"  
    src="//www.googleadservices.com/pagead/conversion.js">
    </script>
    <noscript>
    <div style="display:inline;">
    <img height="1" width="1" style="border-style:none;" alt=""  
    src="//www.googleadservices.com/pagead/conversion/873682659/?label=WsTgCPiik2oQ463NoAM&amp;guid=ON&amp;script=0"/>
    </div>
    </noscript>

    
	</cfif>

	<!--- 2016 Renewal 2 Conversion Code --->
    <cfif selectTransaction.TeamID EQ 10456
        OR selectTransaction.TeamID EQ 10457>
    
    
    <!-- Google Code for Conversions for Renewal 2 Conversion Page --> 
    <script type="text/javascript">
    /* <![CDATA[ */
    var google_conversion_id = 960854899;
    var google_conversion_language = "en";
    var google_conversion_format = "3";
    var google_conversion_color = "ffffff";
    var google_conversion_label = "CfP7COPYrWUQ8_aVygM"; 
    var google_conversion_value = #selectTransaction.gift#; 
    var google_conversion_currency = "CAD"; var google_remarketing_only = false;
    /* ]]> */
    </script>
    <script type="text/javascript"  
    src="//www.googleadservices.com/pagead/conversion.js">
    </script>
    <noscript>
    <div style="display:inline;">
    <img height="1" width="1" style="border-style:none;" alt=""  
    src="//www.googleadservices.com/pagead/conversion/960854899/?value=#selectTransaction.gift#&amp;currency_code=CAD&amp;label=CfP7COPYrWUQ8_aVygM&amp;guid=ON&amp;script=0"/>
    </div>
    </noscript>
    
    
    </cfif>


	<!--- 2016 Acq 1 Conversion Code --->
    <cfif selectTransaction.TeamID EQ 10566
        OR selectTransaction.TeamID EQ 10567
        OR selectTransaction.TeamID EQ 10568
        OR selectTransaction.TeamID EQ 10569
        OR selectTransaction.TeamID EQ 10570
        OR selectTransaction.TeamID EQ 10571>
    
    <script type="text/javascript">
    /* <![CDATA[ */
    var google_conversion_id = 960854899;
    var google_conversion_language = "en";
    var google_conversion_format = "3";
    var google_conversion_color = "ffffff";
    var google_conversion_label = "5e8HCNvIr2UQ8_aVygM"; 
    var google_conversion_value = #selectTransaction.gift#; 
    var google_conversion_currency = "CAD"; 
    var google_remarketing_only = false;
    /* ]]> */
    </script>
    <script type="text/javascript" src="//www.googleadservices.com/pagead/conversion.js">
    </script>
    <noscript>
    <div style="display:inline;">
    <img height="1" width="1" style="border-style:none;" alt="" src="//www.googleadservices.com/pagead/conversion/960854899/?value=#selectTransaction.gift#&amp;currency_code=CAD&amp;label=5e8HCNvIr2UQ8_aVygM&amp;guid=ON&amp;script=0"/>
    </div>
    </noscript>
    
    </cfif>


<cfelseif Trim(selectTransaction.gift_type) EQ 'MW'>
<cfelseif Trim(selectTransaction.gift_type) EQ 'JeansDay'>
<cfelseif Trim(selectTransaction.gift_type) EQ 'ICE'>
<cfelse>
</cfif>


<!-- BCCHF's Facebook Pixel Code -->
<script>
!function(f,b,e,v,n,t,s){if(f.fbq)return;n=f.fbq=function(){n.callMethod?
n.callMethod.apply(n,arguments):n.queue.push(arguments)};if(!f._fbq)f._fbq=n;
n.push=n;n.loaded=!0;n.version='2.0';n.queue=[];t=b.createElement(e);t.async=!0;
t.src=v;s=b.getElementsByTagName(e)[0];s.parentNode.insertBefore(t,s)}(window,
document,'script','https://connect.facebook.net/en_US/fbevents.js');
fbq('init', '511237559044138'); // Insert your pixel ID here.
fbq('track', 'PageView');
fbq('track', 'Purchase', {value: '#selectTransaction.gift#' ,currency: 'CAD'});
</script>
<noscript><img height="1" width="1" style="display:none"
src="https://www.facebook.com/tr?id=511237559044138&ev=PageView&noscript=1"
/></noscript>
<!-- DO NOT MODIFY -->
<!-- End Facebook Pixel Code -->

<!--- Google Code for Grant Account - AdWords Donation Tracking Conversion Page --->
<script type="text/javascript">
/* <![CDATA[ */
var google_conversion_id = 978521268;
var google_conversion_language = "en";
var google_conversion_format = "3";
var google_conversion_color = "ffffff";
var google_conversion_label = "yKBCCOrv8GsQtJnM0gM";
var google_conversion_value = #selectTransaction.gift#;
var google_conversion_currency = "CAD";
var google_remarketing_only = false;
/* ]]> */
</script>
<script type="text/javascript" src="//www.googleadservices.com/pagead/conversion.js">
</script>
<noscript>
<div style="display:inline;">
<img height="1" width="1" style="border-style:none;" alt="" src="//www.googleadservices.com/pagead/conversion/978521268/?value=#selectTransaction.gift#&amp;currency_code=CAD&amp;label=yKBCCOrv8GsQtJnM0gM&amp;guid=ON&amp;script=0"/>
</div>
</noscript>


<!--- Google Code for New Paid Account - AdWords Donation Tracking Conversion Page --->
<script type="text/javascript">
/* <![CDATA[ */
var google_conversion_id = 867189927;
var google_conversion_language = "en";
var google_conversion_format = "3";
var google_conversion_color = "ffffff";
var google_conversion_label = "jDgtCIS3pmwQp4nBnQM";
var google_conversion_value = #selectTransaction.gift#;
var google_conversion_currency = "CAD";
var google_remarketing_only = false;
/* ]]> */
</script>
<script type="text/javascript" src="//www.googleadservices.com/pagead/conversion.js">
</script>
<noscript>
<div style="display:inline;">
<img height="1" width="1" style="border-style:none;" alt="" src="//www.googleadservices.com/pagead/conversion/867189927/?value=#selectTransaction.gift#&amp;currency_code=CAD&amp;label=jDgtCIS3pmwQp4nBnQM&amp;guid=ON&amp;script=0"/>
</div>
</noscript>

</cfoutput>