<cfsilent>



<!---- Read in error code --->
<cfif IsDefined('URL.Err')>
<cfset Err='#HTMLEditFormat(URL.Err)#'>
<cfelse>
<cfset Err='unknown'>
</cfif>

<!--- set error message --->

<cfif Err EQ 'Unknown'>
<cfset Err_msg = '<p>An unknown error has occurred.<br />
BCCHF IS has been notified, and is working to resolve the issue ASAP.<br />
Please check back soon or phone 604-875-2444 to make your donation during business hours (8am - 5pm, Monday - Friday).<br />
Thank you for your patience while we resolve this issue.</p>'> 
<cfelseif Err EQ '01'>
<!--- Connecting to database at page load --->
<cfset Err_msg = '<p>An error has occurred loading this page, your transaction has NOT been processed.<br />
BCCHF IS has been notified, and is working to resolve the issue ASAP.<br />
Please check back soon or phone 604-875-2444 to make your donation during business hours (8am - 5pm, Monday - Friday).<br />
Thank you for your patience while we resolve this issue.</p>'> 
<cfelseif Err EQ '02'>
<!--- attempting charge --->
<cfset Err_msg = '<p>A system error has occurred, your transaction has NOT been processed.<br />
BCCHF IS has been notified, and is working to resolve the issue ASAP.<br />
Please check back soon or phone 604-875-2444 to make your donation during business hours (8am - 5pm, Monday - Friday).<br />
Thank you for your patience while we resolve this issue.</p>'> 
<cfelseif Err EQ '03'>
<!--- post charge on transaction record --->
<!--- try to get transaction record ??? --->
<cfset Err_msg = '<p>Thank You, your transaction has been processed, however, your information was not recorded properly. <br />
A receipt confirmation of your transaction has already been sent. <br />
Your transaction has been flagged for investigation. You will be contacted if necessary for further follow up about your donation. <br />
BCCHF IS is working to resolve the issue ASAP.</p>
<p>Thank you for your patience while we resolve this issue, if you have any questions or concerns about your donation, please email, <a href="mailto:donations@bcchf.ca">donations@bcchf.ca</a>. </p>'>
<cfelseif Err EQ '04'>
<!--- error recording into SHP DB --->
<!--- we can get transaction detail and try again ?? --->
<cfset Err_msg = '<p>Thank You, your transaction has been processed, however, your transaction has not been properly credited to the person / team that you are supporting.<br />
BCCHF IS is working to resolve the issue ASAP.</p>
<p>A receipt confirmation of your transaction has already been sent, a seperate email will follow with your receipt, if requested, within 10 minutes. <br />
Thank you for your patience while we resolve this issue, if you have any questions or concerns about your donation, please email, <a href="mailto:donations@bcchf.ca">donations@bcchf.ca</a>. </p>'>
<cfelseif Err EQ '05'>
<!--- sending the emails --->
<cfset Err_msg = '<p>Thank You, your transaction has been processed, however, an error occurred sending your email confirmation. <br />
Your transaction has been flagged for investigation. You will be contacted if necessary for further follow up about your donation. <br />
BCCHF IS is working to resolve the issue ASAP.</p>
<p>Thank you for your patience while we resolve this issue, if you have any questions or concerns about your donation, please email, <a href="mailto:donations@bcchf.ca">donations@bcchf.ca</a>. </p>'>
<cfelseif Err EQ '06'>
<!--- getting member info --->
<cfset Err_msg = '<p>A system error has occurred, your transaction has NOT been processed.<br />
BCCHF IS has been notified, and is working to resolve the issue ASAP.<br />
Please check back soon or phone 604-875-2444 to make your donation during business hours (8am - 5pm, Monday - Friday).<br />
Thank you for your patience while we resolve this issue.</p>'> 
<cfelseif Err EQ '07'>
<!--- SHP Tribute Information --->
<cfset Err_msg = '<p>Thank You, your transaction has been processed, however, your transaction has not been properly credited to the person / team that you are supporting.<br />
BCCHF IS is working to resolve the issue ASAP.</p>
<p>A receipt confirmation of your transaction has already been sent, a seperate email will follow with your receipt, if requested, within 10 minutes. <br />
Thank you for your patience while we resolve this issue, if you have any questions or concerns about your donation, please email, <a href="mailto:donations@bcchf.ca">donations@bcchf.ca</a>. </p>'> 
<cfelseif Err EQ '08'>
<!--- BFD Calenar Purchase --->
<cfset Err_msg = '<p>Thank You, your transaction has been processed, however, your information was not recorded properly. <br />
A receipt confirmation of your transaction has already been sent. <br />
Your transaction has been flagged for investigation. You will be contacted if necessary for further follow up about your donation. <br />
BCCHF IS is working to resolve the issue ASAP.</p>
<p>Thank you for your patience while we resolve this issue, if you have any questions or concerns about your donation, please email, <a href="mailto:donations@bcchf.ca">donations@bcchf.ca</a>. </p>'> 
<cfelseif Err EQ '09'>
<!--- Participant not registered in current years campaign --->

<!--- need a little event info in this case, if another error happens, throw the unknown message --->
<cftry>
<!--- Get Event information --->
<cfquery name="EventInfo" datasource="bcchf_SuperHero">
SELECT * FROM Hero_Event WHERE Event = '#URL.Event#'
</cfquery>

	<cfcatch type="Any">
	<cflocation url="https://secure.bcchf.ca/donate/error_DonationError.cfm?Err=01" addtoken="no">
	</cfcatch>
</cftry> 


<cfset Err_msg = '<p>You appear to be attempting to support a participant that has not yet registered for the #EventInfo.EventCurrentYear# #EventInfo.Event_Name# campaign.<br />
Please return to the #EventInfo.Event_Name# <a href="../#URL.Event#/">home page</a> and search for a current participant to support, or, you may make a <a href="SuperheroPages.cfm?Event=#URL.Event#">general #EventInfo.Event_Name# donation</a>.</p>
<p>If you have any questions or concerns about your donation, please email, <a href="mailto:donations@bcchf.ca">donations@bcchf.ca</a>. </p>'> 

<cfelseif Err EQ '10'>
<!--- BLOCKED IP ADDRESS --->
<cfset Err_msg = '<p>An unknown error has occurred.<br />
BCCHF IS has been notified, and is working to resolve the issue ASAP.<br />
Please check back soon or phone 604-875-2444 to make your donation during business hours (8am - 5pm, Monday - Friday).<br />
Thank you for your patience while we resolve this issue.</p>'> 
<cfelseif Err EQ '11'>
<!--- SITE IS CLOSED FOR MAINTAIENCE --->
<cfset Err_msg = '<p>Our apologies, we are currently performing site maintenance.<br />
Full service will be restored shortly.<br />
Please check back soon or phone 604-875-2444 to make your donation during business hours (8am - 5pm, Monday - Friday).<br />
Thank you for your patience.</p>'>
<!--- Grind for kids pledge lookup ---> 
<cfelseif Err EQ '12'>
<cfset Err_msg = '<p>An error has occurred loading your pledge information.<br />
BCCHF IS has been notified, and is working to resolve the issue ASAP.<br />
Please check back soon or phone 604-875-2444 to make your donation during business hours (8am - 5pm, Monday - Friday).<br />
Thank you for your patience while we resolve this issue.</p>'> 
<!--- error on registration page --->
<cfelseif Err EQ '13'>
<cfset Err_msg = '<p>An error has occurred processing your registration information.<br />
BCCHF IS has been notified, and is working to resolve the issue ASAP.<br />
Please check back soon or phone 604-875-2444 to register during business hours (8am - 5pm, Monday - Friday).<br />
Thank you for your patience while we resolve this issue.</p>'> 
<cfelseif Err EQ '14'>
<!--- sending the emails REGISTRATION --->
<cfset Err_msg = '<p>An error has occurred processing your registration information.<br />Your registration is complete, however there was an error sending your email confirmation.<br />You may login to your headquarters with the username and password you created when you registered.<br /> 
Your registration has been flagged for investigation. You will be contacted if necessary for further follow up about your registration. <br />
BCCHF IS is working to resolve the issue ASAP.</p>
<p>Thank you for your patience while we resolve this issue, if you have any questions or concerns about your registration, please email, <a href="mailto:donations@bcchf.ca">donations@bcchf.ca</a>. </p>'>
</cfif>



<!--- send email to IS that error is received --->
<cfif Err EQ '10'></cfif>
<!--- 
<cfmail to="isbcchf@bcchf.ca" cc="csweeting@bcchf.ca" from="donations@bcchf.ca" subject="Online Donation Error">
An error has been caught on the online donation page.
#Err#

01 Connectiong to database at page load 
02 attempting charge
03 post charge on transaction record 
04 error recording into SHP DB 
05 sending the emails 
06 getting member info
07 SHP Tribute Information
08 BFD Calenar Purchase
09 Participant not registered in current years campaign
10 IP Address is BLOCKED
11 site maintenance
12 Grind For kids Pledge Payment
13 SHP Registration Page Error
14 SHP Registration Page Error - Login Step
</cfmail>
--->

</cfsilent>


<!doctype html>
<!--- retrieving head information for page loading  --->
<cfoutput>
#THIS.EVENT.correctedpreHead#
<!--- --->
<head>
#THIS.EVENT.correctedHeadHead#
<script src="../js/browserDetect.js" type="text/javascript"></script>
<script src="../js/generic-form.js" type="text/javascript"></script>
</head>

<body class="section-donate">

<div id="main-container">


	<div id="thisistheheadercontainer" style="display:block;">
    #THIS.EVENT.correctedHeader#
    </div>

	<div id="main-container-inner" class="cont-center clearfix">

		<div id="breadcrumb-container">
        
			#THIS.EVENT.topBreadCrumb#<span class="last">Error</span>
            
		</div><!-- breadcrumb-container -->
		
        <div id="sidebar-left">
        	<!--- how are we doing this with the new feed ?? --->
        	
			<!--- <a href="#THIS.EVENT.DonationLink#" class="button button-survey-left">Donate Now</a> --->
            
			<cfinclude template="../includes/leftSideBar.cfm">
        </div><!-- sidebar-left -->

		<div id="main-content-container" class="clearfix">
        
        <cfif THIS.EVENT.secureSiteWideMessage NEQ ''>
        <div style="padding-left:30px;">#THIS.EVENT.secureSiteWideMessage#</div>
        </cfif>

			<div id="main-content-inner" class="clearfix">
			
				<div id="main-content-header">
					<h2>Error</h2>
				</div><!-- main-content-header -->

				<div id="main-content" class="clearfix">
                <cfif IsDefined('Err_msg')>
					<cfoutput>#Err_msg#</cfoutput>
				<cfelse>
					<p>An unknown error has occurred.</p>
				</cfif>
					<p>Continue to browse on <a href="http://www.bcchf.ca">www.bcchf.ca</a> </p>
				</div><!-- main-content -->

				<div id="sidebar-right">
                    <cfinclude template="../includes/rightSideBar.cfm">
				</div><!-- sidebar-right -->
			</div><!-- main-content-inner -->
            
		</div><!-- main-content-container -->

	</div><!-- main-container-inner -->

	<div id="thisisthefootercontainer" style="display:block;">
	#THIS.EVENT.correctedFooter#
    </div>
</div><!-- main-container -->
<cfinclude template="../js/BrowserDetect.cfm">  


    
</body></cfoutput>
</html>