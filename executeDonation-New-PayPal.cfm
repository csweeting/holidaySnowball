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
	<!--- UUID NOT provided - direct away from this page 
	<cflocation url="#THIS.EVENT.SSserviceLink#" addtoken="no">--->
</cfif> 

<!--- event provided in URL --->
<cfif IsDefined('URL.Event') AND URL.Event NEQ ''>
	<cfset Event = URL.Event>
<cfelse>
	<cfset Event = 'General'>
</cfif> 
    
    
<!--- need to log into API to retrieve data --->

<!--- BCCHF sandbox 
<cfset ClientID = 'AU7JuxDyWHnqy5vngOapa6_ndHU-0NfJP37DZtG-x6E_KPjH9KiKetcSb9AY'>
<cfset clientPass = 'EGSdMhC9MagPgmY8QwOs_yzMFZ69QSNb4Y4ytGqv0HE0SB-QqOl9C7rTdCmJ'>
<cfset apiendPoint = 'https://api.sandbox.paypal.com/'>--->

<!--- BCCLF LIVE --->
<cfset ClientID = 'AUQ0kRD4EXX6hhe3nQ4Uu78Q18Ea2F2_hHTAL5LsrHgIRvk1xtYvsq-TvH8p'>
<cfset clientPass = 'ENnkbRA4zr4vQ84FJvB1WV-vV8CgAL-BpiF22pejC_m6C2AMudlH5RvbrtsD'>
<cfset apiendPoint = 'https://api.paypal.com/'>


<cfhttp 
result="result"
method="post"
url="#apiendPoint#v1/oauth2/token" 
username="#ClientID#"
password="#clientPass#"
>
<cfhttpparam type="header" name="Accept" value="application/json" />
<cfhttpparam type="header" name="Accept-Language" value="en_US" />
<cfhttpparam type="formfield" name="grant_type" value="client_credentials">
</cfhttp>

 
<cfif result.responseheader.status_code EQ 200>
 
    <cftry>
    <cfset SHPevent = DeserializeJSON(toString( result.fileContent ))>
    
    
    <!--- auth token --->
    <cfset requestToken='#SHPevent.token_type# #SHPevent.access_token#'>
    
    <!--- <cfdump var="#SHPevent#"> --->
    
    <cfcatch type="any">
    <cfset updateSafe = 0>
    
    <cfmail to="csweeting@bcchf.ca" from="task@bcchf.ca" subject="Grind For Kids - Lookup Connection Error" type="html">
    <cfdump var="#cfcatch#" label="error">
    </cfmail>
    
    </cfcatch>
    </cftry>
    

<cfelse>

<!--- error executing --->
<cfmail to="csweeting@bcchf.ca" from="paypalprocess@bcchf.ca" subject="PayPal Fail on Execute Login" type="html">
<p>Did not recieve 200 status code on login for execution.</p>
<cfdump var="#result#">
</cfmail>


</cfif>






<!--- execute payment --->

<cfset payDetail["payer_id"] = URL.PayerID>
<!--- 
<cfdump var="#serializeJSON(payDetail)#">
--->

</cfsilent>

<cfhttp 
result="result"
method="post"
url="#apiendPoint#v1/payments/payment/#URL.paymentId#/execute/" 
>
<cfhttpparam type="header" name="Content-Type" value="application/json" />
<cfhttpparam type="header" name="Authorization" value="#requestToken#" />
<cfhttpparam type="body" value="#serializeJSON(payDetail)#">
</cfhttp>

 
<cfif result.responseheader.status_code EQ 200>
 
    <cftry>
    <cfset SHPevent = DeserializeJSON(toString( result.fileContent ))>
    
    <cfset payPalAuth = SHPevent.transactions[1].related_resources[1].sale.id>
    
    <!--- 	1. update the payPal record as executed 
			2. add completed transaction data to database
				- add to Hero_Donate if necessary
				- activate ecard if necessary
			3. notification emails
			4. direct to confirmation page
		--->
    	<CFQUERY datasource="#APPLICATION.DSN.Superhero#" name="selectPayPal">
        SELECT dtnDate, exact_date, dtnAmt, dtnBenefit, dtnReceiptAmt, dtnReceiptType, dtnBatch, dtnSource, rqst_dollaramount, pge_UUID, dtnIP, dtnBrowser, payPalPaymentID, payPalEXE 
        FROM tblPayPal
        WHERE pge_UUID = '#sup_pge_UUID#'
        	AND payPalPaymentID = '#SHPevent.ID#'
        </CFQUERY>
        
        <!--- update attempt table with the auth numbers to use --->
        <cfquery name="updateAttempt" datasource="#APPLICATION.DSN.Superhero#">
        UPDATE tblAttempt
        SET rqst_authorization_num = '#payPalAuth#',
        POST_REFERENCE_NO = '#SHPevent.payer.payer_info.payer_id#',
        rqst_sequenceno = '#SHPevent.ID#'
        WHERE pge_UUID = '#sup_pge_UUID#';
        </cfquery>
        
        
        
        <!--- transaction information
        <CFQUERY datasource="#APPLICATION.DSN.Superhero#" name="insert_record">
        INSERT INTO tblDonation (dtnDate, exact_date, dtnAmt, dtnReceiptAmt, dtnReceiptType, dtnBatch, dtnSource, post_cardholdersname, post_card_type, rqst_sequenceno, rqst_authorization_num, rqst_dollaramount, pge_UUID, dtnIP, dtnBrowser) 
        VALUES (#CreateODBCDateTime(selectPayPal.dtnDate)#, #CreateODBCDateTime(selectPayPal.exact_date)#, '#selectPayPal.dtnAmt#', '#selectPayPal.dtnReceiptAmt#', '#selectPayPal.dtnReceiptType#', 'Online', '#selectPayPal.dtnSource#', '#SHPevent.payer.payer_info.first_name# #SHPevent.payer.payer_info.last_name#', 'PayPal', '#SHPevent.ID#', '#payPalAuth#', '#selectPayPal.rqst_dollaramount#', '#selectPayPal.pge_UUID#', '#selectPayPal.dtnIP#', '#selectPayPal.dtnBrowser#') 
        </CFQUERY>--->
    	
        <!--- DEPRECIATE OLD database --->
        <CFQUERY datasource="#APPLICATION.DSN.transaction#" name="insert_record" >
        INSERT INTO tblDonation (dtnDate, exact_date, dtnAmt, dtnReceiptAmt, dtnReceiptType, dtnBatch, dtnSource, post_cardholdersname, post_card_type, rqst_sequenceno, rqst_authorization_num, rqst_dollaramount, pge_UUID, dtnIP, dtnBrowser) 
        VALUES (#CreateODBCDateTime(selectPayPal.dtnDate)#, #CreateODBCDateTime(selectPayPal.exact_date)#, '#selectPayPal.dtnAmt#', '#selectPayPal.dtnReceiptAmt#', '#selectPayPal.dtnReceiptType#', 'Online', '#selectPayPal.dtnSource#', '#SHPevent.payer.payer_info.first_name# #SHPevent.payer.payer_info.last_name#', 'PayPal', '#SHPevent.ID#', '#payPalAuth#',  '#selectPayPal.rqst_dollaramount#', '#selectPayPal.pge_UUID#', '#selectPayPal.dtnIP#', '#selectPayPal.dtnBrowser#') 
        </CFQUERY> 
        
        <cfcatch type="any">
    
    <cfmail to="csweeting@bcchf.ca" from="task@bcchf.ca" subject="Pay Pal DB Connect Error" type="html">
    <cfdump var="#cfcatch#" label="error">
    </cfmail>
    
    </cfcatch>
    </cftry>
    
    <cftry>
        
        <!--- 
        <CFQUERY datasource="#APPLICATION.DSN.Superhero#" name="insertLiveData">
        INSERT INTO tblGeneral (tblGeneral.pty_date, tblGeneral.exact_date, tblGeneral.pty_title, tblGeneral.pty_fname, tblGeneral.pty_miname, tblGeneral.pty_lname, tblGeneral.pty_companyname, tblGeneral.ptc_address, tblGeneral.ptc_add_two, tblGeneral.ptc_city, tblGeneral.ptc_prov, tblGeneral.ptc_post, tblGeneral.ptc_country, tblGeneral.tax_address, tblGeneral.tax_city, tblGeneral.tax_prov, tblGeneral.tax_post, tblGeneral.tax_country, tblGeneral.ptc_email, tblGeneral.ptc_subscribe, tblGeneral.ptc_phone_area, tblGeneral.ptc_phone, tblGeneral.ptc_phone_area_two, tblGeneral.ptc_phone_two, tblGeneral.ptc_fax_area, tblGeneral.ptc_fax, tblGeneral.pty_tax_title, tblGeneral.pty_tax_fname, tblGeneral.pty_tax_lname, tblGeneral.pty_tax_companyname, tblGeneral.pty_tax, tblGeneral.pty_solicit, tblGeneral.receipt_type, tblGeneral.gift, tblGeneral.gift_Advantage, tblGeneral.gift_Eligible, tblGeneral.gift_type, tblGeneral.gift_frequency, tblGeneral.gift_day, tblGeneral.gift_pledge, tblGeneral.gift_pledge_det, tblGeneral.ISE_notes, tblGeneral.SupID, tblGeneral.TeamID, tblGeneral.ConstitID, tblGeneral.JD_Pin, tblGeneral.JD_Button, tblGeneral.gift_tribute, tblGeneral.trib_notes, tblGeneral.gift_notes, tblGeneral.trb_fname, tblGeneral.trb_lname, tblGeneral.srp_fname, tblGeneral.srp_lname, tblGeneral.srp_relation, tblGeneral.trb_address, tblGeneral.trb_add_two, tblGeneral.trb_email, tblGeneral.trb_city, tblGeneral.trb_prov, tblGeneral.trb_postal, tblGeneral.trb_cardfrom, tblGeneral.trb_msg, tblGeneral.card_send, tblGeneral.eCardID, tblGeneral.info_where, tblGeneral.donated_before, tblGeneral.info_will, tblGeneral.info_life, tblGeneral.info_trusts, tblGeneral.info_securities, tblGeneral.info_RRSP, tblGeneral.info_willinclude, tblGeneral.info_lifeinclude, tblGeneral.info_RSPinclude, tblGeneral.SOC_subscribe, tblGeneral.SOC_mail, tblGeneral.AR_subscribe, tblGeneral.AR_mail, tblGeneral.post_cardholdersname, tblGeneral.post_cardholdersemail, tblGeneral.post_card_number, tblGeneral.post_expiry_year, tblGeneral.post_expiry_month, tblGeneral.rqst_authorization_num, tblGeneral.POST_REFERENCE_NO, tblGeneral.int_research, tblGeneral.int_child, tblGeneral.int_help, tblGeneral.int_mental, tblGeneral.rqst_sequenceno, tblGeneral.NoOfRegistrations, tblGeneral.spOne_Amt, tblGeneral.spOne_Fund, tblGeneral.spOne_Appeal, tblGeneral.spOne_Campaign, tblGeneral.spTwo_Amt, tblGeneral.spTwo_Fund, tblGeneral.spTwo_Appeal, tblGeneral.spTwo_Campaign, tblGeneral.EventCode, tblGeneral.tribImportID, tblGeneral.tribImportIDtwo, tblGeneral.LexusImportID, tblGeneral.scOne, tblGeneral.scTwo, tblGeneral.scThree, tblGeneral.pge_UUID, tblGeneral.dnrBrowser, tblGeneral.dnrOS, tblGeneral.dnrBrowserVersion, tblGeneral.dnrEmailRef)
        SELECT  pty_date, exact_date, pty_title, pty_fname, pty_miname, pty_lname, pty_companyname, ptc_address, ptc_add_two, ptc_city, ptc_prov, ptc_post, ptc_country, tax_address, tax_city, tax_prov, tax_post, tax_country, ptc_email, ptc_subscribe, ptc_phone_area, ptc_phone, ptc_phone_area_two, ptc_phone_two, ptc_fax_area, ptc_fax, pty_tax_title, pty_tax_fname, pty_tax_lname, pty_tax_companyname, pty_tax, pty_solicit, receipt_type, gift, gift_Advantage, gift_Eligible, gift_type, gift_frequency, gift_day, gift_pledge, gift_pledge_det, ISE_notes, SupID, TeamID, ConstitID, JD_Pin, JD_Button, gift_tribute, trib_notes, gift_notes, trb_fname, trb_lname, srp_fname, srp_lname, srp_relation, trb_address, trb_add_two, trb_email, trb_city, trb_prov, trb_postal, trb_cardfrom, trb_msg, card_send, eCardID, info_where, donated_before, info_will, info_life, info_trusts, info_securities, info_RRSP, info_willinclude, info_lifeinclude, info_RSPinclude, SOC_subscribe, SOC_mail, AR_subscribe, AR_mail, post_cardholdersname, post_cardholdersemail, post_card_number, post_expiry_year, post_expiry_month, rqst_authorization_num, POST_REFERENCE_NO, int_research, int_child, int_help, int_mental, rqst_sequenceno, NoOfRegistrations, spOne_Amt, spOne_Fund, spOne_Appeal, spOne_Campaign, spTwo_Amt, spTwo_Fund, spTwo_Appeal, spTwo_Campaign, EventCode, tribImportID, tribImportIDtwo, LexusImportID, scOne, scTwo, scThree, pge_UUID, dnrBrowser, dnrOS, dnrBrowserVersion, dnrEmailRef
        FROM tblAttempt
        WHERE pge_UUID = '#sup_pge_UUID#';
        </CFQUERY> --->
        
        <!--- DEPRECIATE OLD database --->
        <cfquery name="selectDonor" datasource="#APPLICATION.DSN.Superhero#">
        SELECT  pty_date, exact_date, pty_title, pty_fname, pty_miname, pty_lname, pty_companyname, ptc_address, ptc_add_two, ptc_city, ptc_prov, ptc_post, ptc_country, tax_address, tax_city, tax_prov, tax_post, tax_country, ptc_email, ptc_subscribe, ptc_phone_area, ptc_phone, ptc_phone_area_two, ptc_phone_two, ptc_fax_area, ptc_fax, pty_tax_title, pty_tax_fname, pty_tax_lname, pty_tax_companyname, pty_tax, pty_solicit, receipt_type, gift, gift_Advantage, gift_Eligible, gift_type, gift_frequency, gift_day, gift_pledge, gift_pledge_det, ISE_notes, SupID, TeamID, ConstitID, JD_Pin, JD_Button, gift_tribute, trib_notes, gift_notes, trb_fname, trb_lname, srp_fname, srp_lname, srp_relation, trb_address, trb_add_two, trb_email, trb_city, trb_prov, trb_postal, trb_cardfrom, trb_msg, card_send, eCardID, info_where, donated_before, info_will, info_life, info_trusts, info_securities, info_RRSP, info_willinclude, info_lifeinclude, info_RSPinclude, SOC_subscribe, SOC_mail, AR_subscribe, AR_mail, post_cardholdersname, post_cardholdersemail, post_card_number, post_expiry_year, post_expiry_month, rqst_authorization_num, POST_REFERENCE_NO, int_research, int_child, int_help, int_mental, rqst_sequenceno, NoOfRegistrations, spOne_Amt, spOne_Fund, spOne_Appeal, spOne_Campaign, spTwo_Amt, spTwo_Fund, spTwo_Appeal, spTwo_Campaign, EventCode, tribImportID, tribImportIDtwo, LexusImportID, scOne, scTwo, scThree, pge_UUID, dnrBrowser, dnrOS, dnrBrowserVersion, dnrEmailRef
        FROM tblAttempt
        WHERE pge_UUID = '#sup_pge_UUID#';
        </cfquery>
        
        <cfif selectDonor.eCardID EQ ''>
        	<cfset eCardID = 0>
        <cfelse>
        	<cfset eCardID = selectDonor.eCardID>
        </cfif>
        
        
        <CFQUERY datasource="#APPLICATION.DSN.general#" name="insertLiveData">
        INSERT INTO tblGeneral (pty_date, exact_date, pty_title, pty_fname, pty_miname, pty_lname, pty_companyname, ptc_address, ptc_add_two, ptc_city, ptc_prov, ptc_post, ptc_country, tax_address, tax_city, tax_prov, tax_post, tax_country, ptc_email, ptc_subscribe, ptc_phone_area, ptc_phone, pty_tax_title, pty_tax_fname, pty_tax_lname, pty_tax_companyname, pty_tax, pty_solicit, receipt_type, gift, gift_Advantage, gift_Eligible, gift_type, gift_frequency, gift_day, gift_pledge, gift_pledge_det, ISE_notes, SupID, TeamID, ConstitID, JD_Pin, JD_Button, gift_tribute, trib_notes, gift_notes, trb_fname, trb_lname, srp_fname, srp_lname, srp_relation, trb_address, trb_add_two, trb_email, trb_city, trb_prov, trb_postal, trb_cardfrom, trb_msg, card_send, eCardID, info_where, donated_before, info_will, info_life, info_trusts, info_securities, info_RRSP, info_willinclude, info_lifeinclude, info_RSPinclude, SOC_subscribe, SOC_mail, AR_subscribe, AR_mail, post_cardholdersname, post_cardholdersemail, post_card_number, post_expiry_year, post_expiry_month, rqst_authorization_num, POST_REFERENCE_NO, int_research, int_child, int_help, int_mental, rqst_sequenceno, NoOfRegistrations, pge_UUID, dnrEmailRef)
        VALUES (#CreateODBCDateTime(selectDonor.pty_date)#, #CreateODBCDateTime(selectPayPal.exact_date)#, '#selectDonor.pty_title#', '#selectDonor.pty_fname#', '#selectDonor.pty_miname#', '#selectDonor.pty_lname#', '#selectDonor.pty_companyname#', '#selectDonor.ptc_address#', '#selectDonor.ptc_add_two#', '#selectDonor.ptc_city#', '#selectDonor.ptc_prov#', '#selectDonor.ptc_post#', '#selectDonor.ptc_country#', '#selectDonor.tax_address#', '#selectDonor.tax_city#', '#selectDonor.tax_prov#', '#selectDonor.tax_post#', '#selectDonor.tax_country#', '#selectDonor.ptc_email#', '#selectDonor.ptc_subscribe#', '#selectDonor.ptc_phone_area#', '#selectDonor.ptc_phone#', '#selectDonor.pty_tax_title#', '#selectDonor.pty_tax_fname#', '#selectDonor.pty_tax_lname#', '#selectDonor.pty_tax_companyname#', '#selectDonor.pty_tax#', '#selectDonor.pty_solicit#', '#selectDonor.receipt_type#', '#selectDonor.gift#', '#selectDonor.gift_Advantage#', '#selectDonor.gift_Eligible#', '#selectDonor.gift_type#', '#selectDonor.gift_frequency#', '#selectDonor.gift_day#', '#selectDonor.gift_pledge#', '#selectDonor.gift_pledge_det#', '#selectDonor.ISE_notes#', '#selectDonor.SupID#', '#selectDonor.TeamID#', '#selectDonor.ConstitID#', '#selectDonor.JD_Pin#', '#selectDonor.JD_Button#', '#selectDonor.gift_tribute#', '#selectDonor.trib_notes#', '#selectDonor.gift_notes#', '#selectDonor.trb_fname#', '#selectDonor.trb_lname#', '#selectDonor.srp_fname#', '#selectDonor.srp_lname#', '#selectDonor.srp_relation#', '#selectDonor.trb_address#', '#selectDonor.trb_add_two#', '#selectDonor.trb_email#', '#selectDonor.trb_city#', '#selectDonor.trb_prov#', '#selectDonor.trb_postal#', '#selectDonor.trb_cardfrom#', '#selectDonor.trb_msg#', '#selectDonor.card_send#', #eCardID#, '#selectDonor.info_where#', '#selectDonor.donated_before#', '#selectDonor.info_will#', '#selectDonor.info_life#', '#selectDonor.info_trusts#', '#selectDonor.info_securities#', '#selectDonor.info_RRSP#', '#selectDonor.info_willinclude#', '#selectDonor.info_lifeinclude#', '#selectDonor.info_RSPinclude#', '#selectDonor.SOC_subscribe#', '#selectDonor.SOC_mail#', '#selectDonor.AR_subscribe#', '#selectDonor.AR_mail#', '#selectDonor.post_cardholdersname#', '#selectDonor.post_cardholdersemail#', '#selectDonor.post_card_number#', '#selectDonor.post_expiry_year#', '#selectDonor.post_expiry_month#', '#selectDonor.rqst_authorization_num#', '#selectDonor.POST_REFERENCE_NO#', '#selectDonor.int_research#', '#selectDonor.int_child#', '#selectDonor.int_help#', '#selectDonor.int_mental#', '#selectDonor.rqst_sequenceno#', '#selectDonor.NoOfRegistrations#', '#selectDonor.pge_UUID#', '#selectDonor.dnrEmailRef#')
        </CFQUERY>
        
        
        
         <cfcatch type="any">
    
    <cfmail to="csweeting@bcchf.ca" from="task@bcchf.ca" subject="Pay Pal DB Connect Error" type="html">
    <cfdump var="#cfcatch#" label="error">
    </cfmail>
    
    </cfcatch>
    </cftry>
    
    <cftry>
        
        
        <CFQUERY datasource="#APPLICATION.DSN.Superhero#" name="selectGDetail">
        SELECT dnrPageSource, pty_title, pty_fname, pty_lname, pty_companyname, ptc_email, pty_date, JD_pin, JD_Button
        FROM tblAttempt
        WHERE pge_UUID = '#sup_pge_UUID#'
        </CFQUERY>
        
        
        
        <cfif selectGDetail.dnrPageSource NEQ ''>
        <!--- we have the struct to add to hero_donate --->
        
        	
        
        
			<cfif NOT IsDefined("add_date")><cfset add_date= "#Now()#"></cfif>
            
            <cfset gDetail = DeSerializeJSON(selectGDetail.dnrPageSource)>
            
            <cfif gDetail.tToken NEQ ''>
            
            <cfset Event = gDetail.tToken>
            <!--- #gDetail.tMsg# --->
            
            <cfelse>
            
            <cfset Event = 'General'>
            
            </cfif>
            
            <!--- insert into hero_donate if necessary --->
            <cfquery name="insertHeroDonation" datasource="#APPLICATION.DSN.Superhero#">
            INSERT INTO Hero_Donate (Event, Campaign, TeamID, Name, Type, Message, Show, DonTitle, DonFName, DonLName, DonCompany, Email, don_date, rqst_authorization_num, Amount, SupID, JDPins, JDButtons, pge_UUID, AddDate, UserAdd, LastChange, LastUser) 
            VALUES ('#Event#', #gDetail.tCampaign#, #gDetail.tTeamID#, '#gDetail.tDName#', '#gDetail.tstype#', '', #gDetail.tsShow#, '#selectGDetail.pty_title#', '#selectGDetail.pty_fname#', '#selectGDetail.pty_lname#', '#selectGDetail.pty_companyname#', '#selectGDetail.ptc_email#', #CreateODBCDateTime(selectGDetail.pty_Date)#, '#SHPevent.ID#', #gDetail.Hero_Donate_Amount#, #gDetail.tSupID#, #selectGDetail.JD_pin#, #selectGDetail.JD_Button#, '#selectPayPal.pge_UUID#', #add_date#, 'Online', #add_date#, 'Online')
            </cfquery>
        
        
        	
        
        
        
        
        </cfif>
        
    	<!--- activate eCard if necesary --->    
    	<cfif gDetail.tToken EQ 'eCard'>
        	<cfquery name="activateEcard" datasource="#APPLICATION.DSN.Superhero#">
            UPDATE eCard
            SET sendActive = 1
            WHERE pge_UUID = '#selectPayPal.pge_UUID#'
            </cfquery>
        </cfif>
        
    
    <cfcatch type="any">
    
    <cfmail to="csweeting@bcchf.ca" from="task@bcchf.ca" subject="Pay Pal DB Connect Error" type="html">
    <cfdump var="#cfcatch#" label="error">
    </cfmail>
    
    </cfcatch>
    </cftry>
    
    
    
    
    
    
    
    <!--- email notifications --->
    <!--- Hook to processor --->
    <cftry>
	<cfset ProcessObj = createObject("component","processDonation") />
	<cfset Notify = ProcessObj.FDNnotifyEmail('#sup_pge_UUID#') />
    
    
    <!---- 2. donation confirmation message 
		message being triggered from completed donation page ---------
		<cfset DonorEmailThanks = DonorEmailThanks(variables.newUUID)> --->
        
		<!--- 3. if Tribute - Tribute Notification email 
        <cfif hiddenAWKtype EQ 'email' 
			AND (hiddenTributeType EQ 'hon' OR hiddenTributeType EQ 'mem')>
        
        	<cfset TribAwkEmail = TribAwkEmail(variables.newUUID)>
        
        </cfif>--->
    
    
		<!--- Event notifications --->
        <cfif Event EQ 'ICE'>
        
        	<cfset ICEnotifyEmail = ProcessObj.ICEnotifyEmail('#sup_pge_UUID#')>
        
        <cfelseif Event EQ 'WOT'>
        
        	<!--- 				 
			<cfif (hiddenTributeType EQ 'hon-WOT' OR hiddenTributeType EQ 'mem-WOT')>
			
				<cfset WOTnotifyEmail = WOTnotifyEmail(variables.newUUID)>
			
			</cfif>--->
		
		<cfelseif Event EQ 'JeansDay'>
        
        	<cfset JeansDayNotifyEmail = ProcessObj.JeansDayNotifyEmail('#sup_pge_UUID#')>
        
        <cfelse>
        
        	<cfset supNotifyEmail = ProcessObj.SHPnotifyEmail('#sup_pge_UUID#')>
            
        </cfif>
    
    
    
    <cfcatch type="any">
    
    <cfmail to="csweeting@bcchf.ca" from="task@bcchf.ca" subject="Pay Pal Execute Notifiy Error" type="html">
    <cfdump var="#cfcatch#" label="error">
    </cfmail>
    
    </cfcatch>
    </cftry>
    
    
    <!--- direct to confirmation page --->
    
    <cftry>
    
    <cfif Event EQ 'HolidaySnowball'>
    
    	<cflocation url="completeDonation-Snowball.cfm?UUID=#sup_pge_UUID#&Event=#Event#" addtoken="no">
    
    <cfelse>
    
    	<cflocation url="completeDonation-New.cfm?UUID=#sup_pge_UUID#&Event=#Event#" addtoken="no">
    
    </cfif>
    
    <cfcatch type="any">
    
    <cfmail to="csweeting@bcchf.ca" from="task@bcchf.ca" subject="Pay Pal DB Connect Error" type="html">
    <cfdump var="#cfcatch#" label="error">
    </cfmail>
    
    </cfcatch>
    </cftry>
    
    
    
    
    
<cfelseif result.responseheader.status_code EQ 400>    
<!--- 400 status code recieved ---
	--- pass back to donation form with message
	--- this will allow another attempt with CCrd details --->
    
    <cfif Event EQ 'HolidaySnowball'>
    	<cflocation url="donation-snowball.cfm?DtnID=#sup_pge_UUID#&PayPalCancel=Decline&#CGI.QUERY_STRING#" addtoken="no">
    <cfelse>
    	<cflocation url="donation-new.cfm?DtnID=#sup_pge_UUID#&PayPalCancel=Decline&#CGI.QUERY_STRING#" addtoken="no">
    </cfif>
    
    
    
<cfelse>

<!--- error executing --->
<cfmail to="csweeting@bcchf.ca" from="paypalprocess@bcchf.ca" subject="PayPal Fail on Execute" type="html">
<p>Did not recieve 200 status code on execution.</p>
<cfdump var="#result#">
</cfmail>



</cfif>

