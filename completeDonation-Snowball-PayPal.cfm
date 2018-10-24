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
		
		
        
        <cfset THIS.EVENT.DonorInfoReview = 'Donor:&nbsp;#SUPPORTER.title# #SUPPORTER.fName# #SUPPORTER.lname#<br />&nbsp;<br />Address:&nbsp;#SUPPORTER.address# #SUPPORTER.addtwo#<br />&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;#SUPPORTER.city#, #SUPPORTER.prov# #SUPPORTER.post#<br />&nbsp;<br />Phone Number:&nbsp;#SUPPORTER.phone#<br />&nbsp;<br />Email Address:&nbsp;#SUPPORTER.email#<br />&nbsp;<br />#subMSG#'>
        
        
</cfsilent>  


<!doctype html>
<!--- retrieving head information for page loading  --->
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
        
        <!--- <cfinclude template="includes/topHeadline.cfm"> --->
        <h1>Review Your Donation</h1>
        <p>After this step your donation will be completed.</p>
		
		<section>
			<!-- Progress bar -->
			<div class="bcchf_progress bcchf_progress_step4 js_bcchf_progress">
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
				<cfoutput>
                <!--- <cfinclude template="includes/generalForm.cfm"> --->
                <form action="executeDonation-New-PayPal.cfm?#CGI.QUERY_STRING#" method="post" class="bcchf-form clearfix">
            <div class="form-section" id="cc-section">
            
            <!--- <h3>Review Your Donation</h3>
            <p class="bcchf_message"><em>After this step your donation will be completed.</em></p> --->
    
            
            <div>&nbsp;</div>
            <section>
        	<h3>Donation Information</h3>
        	<div>&nbsp;</div>
            <div>#THIS.EVENT.DonationInfoReview#</div>
            
            
            <cfif attemptRecord.gift_tribute EQ'Yes'>
        	<h4 style="margin-bottom:5px; margin-top:5px;">Tribute Information</h4>
            <cfif attemptRecord.trib_notes EQ 'hon'>
            	<div>My gift is in honour of #SUPPORTER.trbfname# #SUPPORTER.trblname#.</div>
            <cfelseif attemptRecord.trib_notes EQ 'mem'>
            	<div>My gift is in memory of  #SUPPORTER.trbfname# #SUPPORTER.trblname#.</div>
            <cfelse>
            </cfif>
            <cfif attemptRecord.card_send EQ 'mail'>
            <div>Please send an acknowledgement by mail to #SUPPORTER.srpfname# #SUPPORTER.srplname#<br /><table cellpadding="5" cellspacing="3" border="0"><tr><td valign="top">Address</td><td>#SUPPORTER.trbAddress# #SUPPORTER.trbAddtwo#<br />#SUPPORTER.trbCity# #SUPPORTER.trbProv#<br />#SUPPORTER.trbPost# </td></tr></table></div>
            <cfelseif attemptRecord.card_send EQ 'email'>
            <div>Please send an acknowledgement by email to "#SUPPORTER.srpfname# #SUPPORTER.srplname#" &lt;#SUPPORTER.trbEmail#&gt;.</div>
            <cfelseif attemptRecord.card_send EQ 'ask'>
            <div>Details for your acknowledgement message will be entered on the next page.</div>
            <cfelse>
            <div>Please do not send an acknowledgement message.</div>
            </cfif>
            
            
            </cfif>
            </section>
            <div>&nbsp;</div><div>&nbsp;</div>
            <section>
            <h3>Your Information</h3>
        	<div>&nbsp;</div>
            <div>#THIS.EVENT.DonorInfoReview#</div>
			</section>
            
            <div>&nbsp;</div>  
            <section>
        	<h3>Your Payment Details</h3>
			<div>&nbsp;</div>
            <div><img src="../images/donate/PPcheckoutSM.png" width="69" height="33" /></div>
            </section>
            
            <div>&nbsp;</div>
            	<div>&nbsp;<br />Almost done, click to submit your donation.<br />&nbsp;<br /></div>
                
				<input type="hidden" name="PayerID" value="#URL.PayerID#">                
                <!--- <input type="submit" value=" Complete Transaction " name="submit"> --->
                <!--- <input type="submit" value=" Complete Transaction " class="bcchf_next js_bcchf_submit" id="button-submit-donation" /> --->
                <button type="submit" class="bcchf_next js_bcchf_submit" id="button-submit-donation">Complete Transaction</button>
                
            </div>
            </form>
            </cfoutput>
			
            </div><!--- end of form container ---->
            
           <!--- PW Container ---->
           <div id="mainDonationFormWaitMessageContainer" style="display:none; font-family: 'Calibri', Verdana, Arial, sans-serif; line-height:1.3;" align="center"  >
           Please wait a moment while we process your transaction...<br />
           <img src="../images/ajax-progress.gif" width="220" height="19" alt="Please Wait" />
           </div>
            
		</section>
	</div>
	<cfinclude template="includes/footer-snowball.cfm">

	
	<script type="text/javascript" src="//ajax.googleapis.com/ajax/libs/jquery/3.3.1/jquery.min.js"></script>
	<script type="text/javascript" src="js/slick.min.js"></script>
	<script type="text/javascript" src="js/jquery.validate.min.js"></script>
	<script type="text/javascript" src="js/default.jquery.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/gsap/1.20.3/TweenMax.min.js"></script>
    <script type="text/javascript" src="js/foundation.min.js"></script>
    <script type="text/javascript" src="js/scripts.min.js?v=4.4"></script>
    
	<script type="text/javascript" src="js/additional-methods.min.js"></script>
    <script type="text/javascript" src="../js/exactResponseMessages.js"></script>
    
</body>
</html>
      
            
