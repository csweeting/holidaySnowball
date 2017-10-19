<!--- gathering data about the donation in order to CREATE the receipt ... --->
<cfcomponent output="false">
<cffunction name="createReceipt" access="remote" returntype="string">

<!--- we recieve the UUID of the donation 
	1. lookup info about the donation
		- eligible for receipt?
			-check legacy gift_frequency for 'No Receipt' legacy indicator
		- receipt requested?
		
		- lookup event related information for email and receipt
		
	2. determine receipt type 
		- determined by the donor on the donation form
		- awk ? tax ?
		
	3. construct receipt
		- WOT / ICE / SHP options
	
	--->

	<!--- recieved from requesting page --->
	<cfargument name="pge_UUID" type="string" required="yes">
    
    <!--- return and action variables --->
    <cfset confirmationMSG = ''>
    <cfset sendConfirmEmail = 0>
    
    <!--- 1. selecting information 
		
			donor information
			transaction information
			receipt information
			event information
			
			email text information
			
			team information
			supporter information
			
			
			--->
    
	<!--- donor information --->
    <cfquery name="selectTransaction" datasource="#APPLICATION.DSN.general#">
    SELECT * FROM tblGeneral 
    WHERE pge_UUID = '#pge_UUID#'
    </cfquery>
    
    <!--- transatction information --->
    <cfquery name="lookupSource" datasource="#APPLICATION.DSN.transaction#">
    SELECT dtnSource, dtnID, rqst_CTR, dtnID, dtnReceiptType, dtnExtra1, dtnExtra2, pge_UUID, post_card_type
    FROM tblDonation 
    WHERE pge_UUID = '#pge_UUID#'
    </cfquery>
    
    
    <!--- ensure that the receipt has not been sent already --->
	<!--- if the receipt email has been sent, we do not need to re-send --->
    <cfquery name="lookupReceipt" datasource="#APPLICATION.DSN.transaction#">
    SELECT * FROM DonationReceiptStatusTable 
    WHERE dtnID = #lookupSource.dtnID#
    </cfquery>
    
    <!--- we want to select some info from Hero_Event ---
			Every known gift type has a corresponding entry in Hero_Event
			If not found - use defaults --->
    <cfquery name="selectReceiptInfo" datasource="#APPLICATION.DSN.Superhero#">
    SELECT SponsorEvent, SponsorCampaign, SponsorLexus 
    FROM Hero_Event 
    WHERE Event = '#selectTransaction.gift_type#'
    </cfquery>
	
	
	<!--- 
    SponsorEvent -> GIFT.RECEIPT.imageAlt 
    SponsorCampaign -> GIFT.RECEIPT.image 
    SponsorLexus  -> GIFT.RECEIPT.reSubject (subject on the receipt)
    
	--->
    <cfif selectReceiptInfo.recordCount EQ 0>
		<cfset cusImage = ''>
        <cfset cusImageAlt = ''>
        <cfset cusREsub = ''>
    <cfelse>
		<cfset cusImage = selectReceiptInfo.SponsorCampaign>
        <cfset cusImageAlt = selectReceiptInfo.SponsorEvent>
        <cfset cusREsub = selectReceiptInfo.SponsorLexus>
    </cfif>
    
    <!--- custom DM receipt by Team ID --->
    <cfif selectTransaction.gift_type EQ 'DM'
		AND selectTransaction.TeamID NEQ 0>
    
        <cfquery name="selectTeamReceiptInfo" datasource="#APPLICATION.DSN.Superhero#">
        SELECT Com_Flickr, Com_Face, Com_Twat
        FROM Hero_Team
        WHERE TeamID = #selectTransaction.TeamID#
        </cfquery>
    
    	<cfif selectTeamReceiptInfo.Com_Flickr NEQ ''>
        
        	<cfset cusImage = selectTeamReceiptInfo.Com_Flickr>
			<cfset cusImageAlt = selectTeamReceiptInfo.Com_Face>
       
       </cfif>
       
       <cfif selectTeamReceiptInfo.Com_Twat NEQ ''>
       
            <cfset cusREsub = selectTeamReceiptInfo.Com_Twat>
        
        </cfif>
    
    
    </cfif>
    
    
    
    
    <cfset HospitalVisit = 0>
    <cfif selectTransaction.info_where EQ 'Hospital Visit'>
    	<cfset HospitalVisit = 1>
    </cfif>
    
    
    <!--- WOT Donation Email Customization --->
    <!--- it may be that we have some custom thank you text --->
    <cfif selectTransaction.gift_type EQ 'WOT'>
    
        <cfquery name="ConstructEventDonText" datasource="#APPLICATION.DSN.Superhero#">
        SELECT TextApprovedBody FROM Hero_EventText 
        WHERE Event = 'WOT' AND TextName = 'DonEmail-#selectTransaction.SupID#'
        </cfquery>
        
        <cfif ConstructEventDonText.recordCount EQ 0
			OR ConstructEventDonText.TextApprovedBody EQ '<p></p>'
            OR ConstructEventDonText.TextApprovedBody EQ ''
			OR ConstructEventDonText.TextApprovedBody EQ '<p>DonEmail-#selectTransaction.SupID#</p>'>
    
    
            <!--- we have event information -- query for donation confirmation text --->
            <cfquery name="ConstructEventDonText" datasource="#APPLICATION.DSN.Superhero#">
            SELECT TextApprovedBody FROM Hero_EventText 
            WHERE Event = '#selectTransaction.gift_type#' AND TextName = 'DonEmail'
            </cfquery>
        
        <cfelse>        
        </cfif>

	<cfelse>
    
        <!--- donation confirmation text for this event --->
        <cfquery name="ConstructEventDonText" datasource="#APPLICATION.DSN.Superhero#">
        SELECT TextApprovedBody FROM Hero_EventText 
        WHERE Event = '#selectTransaction.gift_type#' AND TextName = 'DonEmail'
        </cfquery>
    
    </cfif>
    
    <!--- team information, if any --->
    
    
    <!--- supporter information, if any ---->
    
    
    
    
    
    <!--- there is a status code in the receipts table 
		- this receipt email has been attempted by the legacy receipt generator --->
    <cfif lookupReceipt.recordCount EQ 1>
    
        <cfquery name="lookupReceiptStatus" datasource="#APPLICATION.DSN.transaction#">
        SELECT * FROM ReceiptStatusCodes 
        WHERE emailReceiptStatusID = '#lookupReceipt.emailReceiptStatusID#'
        </cfquery>
        
        <cfif lookupReceipt.emailReceiptStatusID EQ 'A'>
        	<cfset sendConfirmEmail = 1>
            <cfset receiptMSG = 'Initiated - This donation will be processed with a donation receipt'>
        <cfelseif lookupReceipt.emailReceiptStatusID EQ 'D'>
            <cfset receiptMSG = 'Processing - Creating Receipt'>
        <cfelseif lookupReceipt.emailReceiptStatusID EQ 'H'>
            <cfset receiptMSG = 'Completed - Receipt created and emailed'>
        <cfelseif lookupReceipt.emailReceiptStatusID EQ 'L'>
            <cfset receiptMSG = 'Error - General Error.'>
        <cfelseif lookupReceipt.emailReceiptStatusID EQ 'N'>
            <cfset receiptMSG = 'URL Connect error'>
        <cfelseif lookupReceipt.emailReceiptStatusID EQ 'O'>
            <cfset receiptMSG = 'No donator info'>
        <cfelseif lookupReceipt.emailReceiptStatusID EQ 'P'>
            <cfset receiptMSG = 'Error Email - No email address given.'>
        <cfelseif lookupReceipt.emailReceiptStatusID EQ 'R'>
            <cfset receiptMSG = 'PDF Creation Error'>
        <cfelseif lookupReceipt.emailReceiptStatusID EQ 'T'>
            <cfset receiptMSG = 'PDF Encryption error'>
        <cfelseif lookupReceipt.emailReceiptStatusID EQ 'V'>
            <cfset receiptMSG = 'Send email error'>
        <cfelseif lookupReceipt.emailReceiptStatusID EQ 'W'>
            <cfset receiptMSG = 'Recurring donation. No receipt will be generated.'>
        <cfelseif lookupReceipt.emailReceiptStatusID EQ 'Z'>
            <cfset receiptMSG = 'Suppress Logging (Permanent Error)'>
        <cfelse>
            <cfset receiptMSG = 'Unknown Status'>
        </cfif>
              
        
        <cfset confirmationMSG = "#confirmationMSG# <p>Receipt emailed #DateFormat(lookupReceipt.lastUpdated, 'MM/DD/YYYY')# #TimeFormat(lookupReceipt.lastUpdated, 'HH:mm:SS')#. If you have any questions about this donation receipt, or need to request a duplicate copy, please contact us at 604-875-2444 or call toll free 1-888-663-3033 if you're outside of Greater Vancouver.</p>">
    
    
    
    <cfelse>
		<!--- no status code - we are safe to send the receipt email --->
        <!--- create the status code (D) for Processing --->
        <cfquery name="addReceiptStatus" datasource="#APPLICATION.DSN.transaction#">
        INSERT INTO DonationReceiptStatusTable (dtnID, emailReceiptStatusID, lastUpdated, retries, lastStatus)
        VALUES (#lookupSource.dtnID#, 'D', #now()#, 0, 'D')
        </cfquery>
    
    	<!--- we will want to check for the new receipt generator as well --->
    
    	<cfset sendConfirmEmail = 1>
    
    
    </cfif>
    
    <!--- end section 1. lookup info --->
    
    
    
    	<!--- we are confirmed to send the confirmation email
			generate the pdf receipt if necessary
			attach receipt to email if necessary
			link receipt in email if necessary
			 --->
             
        <!--- do we want to save the PDF: YES!! --->
        
        
        <!--- save some variables for the pdf --->
		<cfset GIFT.RECEIPT = StructNew() />
        <!--- variables for the email message --->
    	<cfset GIFT.EMAIL = StructNew() />
        
        
        
        
        <!--- 2. determining receipt type --->
		<!--- receipt Type: lookupSource.dtnReceiptType --->
        <!--- receipt types
			TAX = TAX RECEIPT
			AWK = AWKNOWLEDGMENT RECEIPT
			TAX-HK = Hong Kong 
			TAX-IF = Ink Friendly
			TAX-ANNUAL = Annual Receipt for monthly gift
			TAX-HK-ANNUAL = Annual Receipt for monthly gift on HK page
			NONE-Donor = None - donor requested
			NONE-Rst = None - ineligible / restricted
			--->
            
        <cfset GIFT.RECEIPT.type = lookupSource.dtnReceiptType>  
          
        <!--- check for legacy 'Single - No Receipt' in gift_frequency
			on legacy transactions    --->
        <cfif GIFT.RECEIPT.type EQ ''>
        
			<cfif selectTransaction.gift_frequency EQ 'Single'>
                
            <cfelse>    
                <cfset GIFT.RECEIPT.type = 'NONE'>
            </cfif>
        </cfif>
        
        <!--- ink friendly tax receipt does not show the graphic --->
        <cfif GIFT.RECEIPT.type EQ 'TAX-IF'>
        	<cfset GIFT.RECEIPT.inkFriendly = 'Yes'>
        <cfelse>
        	<cfset GIFT.RECEIPT.inkFriendly = 'No'>
        </cfif>
        
        <!--- determine if we should generate and send the receipt --->
        <cfif GIFT.RECEIPT.type EQ 'TAX-ANNUAL' 
			OR GIFT.RECEIPT.type EQ 'TAX-HK-ANNUAL' 
			OR GIFT.RECEIPT.type EQ 'NONE'>   
        	<cfset GIFT.RECEIPT.generate = 0>
            <cfset GIFT.RECEIPT.attach = 0>
            <cfset GIFT.RECEIPT.link = 0> 
    	<cfelse>
        	<cfset GIFT.RECEIPT.generate = 1>
            <cfset GIFT.RECEIPT.attach = 1>
            <cfset GIFT.RECEIPT.link = 1>
        </cfif>
        
        
        <cfif GIFT.RECEIPT.type EQ 'TAX-HK'>
        	<cfset GIFT.RECEIPT.issuer = 'HK'>
        <cfelse>
			<cfset GIFT.RECEIPT.issuer = 'BCCHF'>
        </cfif>
        
        <cfif selectTransaction.gift_type EQ 'MentalHealth'
			OR selectTransaction.gift_type EQ 'MentalHealthA'>
            
            <cfset GIFT.RECEIPT.issuer = 'BCMHF'>            
            
		</cfif>
        
     
        
        <!--- receipt number --->
        <cfif lookupSource.dtnID GTE 200000>
        	<cfset GIFT.RECEIPT.number = lookupSource.dtnID + 1100000>
        <cfelse>
			<cfset GIFT.RECEIPT.number = lookupSource.dtnID + 800000>
        </cfif>
        <cfset GIFT.RECEIPT.recDate = Now()>
        
        
		
        <!--- amounts --->
		<cfset GIFT.RECEIPT.totalAmount = selectTransaction.gift>
        <cfset GIFT.RECEIPT.advAmount = selectTransaction.gift_Advantage>
        <cfset GIFT.RECEIPT.taxAmount = selectTransaction.gift_Eligible>
        
        
        
        <!--- donor name --->
        <cfif selectTransaction.pty_tax_companyname EQ ''
			OR selectTransaction.pty_tax_companyname EQ ' '>
        	<cfset GIFT.RECEIPT.donorType = 'Personal'>
            
            <cfif selectTransaction.pty_tax_fname EQ '' 
				AND selectTransaction.pty_tax_lname EQ ''>
                
                <cfif selectTransaction.pty_title EQ 'None'
					OR selectTransaction.pty_title EQ 'Select'>
                    <cfset GIFT.RECEIPT.donorName = "#selectTransaction.pty_fname# #selectTransaction.pty_lname#">
            	<cfelse>
            		<cfset GIFT.RECEIPT.donorName = "#selectTransaction.pty_title# #selectTransaction.pty_fname# #selectTransaction.pty_lname#">
            	</cfif>
                
            <cfelse>
            
            	<cfif selectTransaction.pty_tax_title EQ 'None'
					OR selectTransaction.pty_tax_title EQ 'Select'>
                
                	<cfset GIFT.RECEIPT.donorName = "#selectTransaction.pty_tax_fname# #selectTransaction.pty_tax_lname#">
                
                <cfelse>
                
            		<cfset GIFT.RECEIPT.donorName = "#selectTransaction.pty_tax_title# #selectTransaction.pty_tax_fname# #selectTransaction.pty_tax_lname#">
            	
                </cfif>
                
            </cfif>
            
        <cfelseif Trim(selectTransaction.pty_tax_companyname) NEQ ''>
        	<cfset GIFT.RECEIPT.donorType = 'Corporate'>
            <cfset GIFT.RECEIPT.donorName = "#selectTransaction.pty_tax_companyname#">
        <cfelse>
        	<cfset GIFT.RECEIPT.donorType = 'Unknown'>
            
			<cfif selectTransaction.pty_tax_title EQ 'None'
				OR selectTransaction.pty_tax_title EQ 'Select'>
                
				<cfset GIFT.RECEIPT.donorName = "#selectTransaction.pty_tax_fname# #selectTransaction.pty_tax_lname#">
            
            <cfelse>
            
                <cfset GIFT.RECEIPT.donorName = "#selectTransaction.pty_tax_title# #selectTransaction.pty_tax_fname# #selectTransaction.pty_tax_lname#">
            
            </cfif>
                
        </cfif>
        
        <!--- address --->
   		<cfset GIFT.RECEIPT.donorAddress = "#selectTransaction.ptc_address# #selectTransaction.ptc_add_Two#<br />
		#selectTransaction.ptc_city# #selectTransaction.ptc_prov# #selectTransaction.ptc_post#">
        
        
        <!--- default settings --->
		<cfset GIFT.RECEIPT.image = "GC5.jpg">
        <cfset GIFT.RECEIPT.imageAlt = "Grayson Christopher">

        
        <!--- TAX message --->
        
        <cfif GIFT.RECEIPT.type EQ 'AWK'>
        <!--- AWK Options --->
        
        	<!--- AWK Receipt in these cases --->
            <cfset GIFT.RECEIPT.taxMessage = "ACKNOWLEDGEMENT RECEIPT ONLY<br />
				NOT FOR TAX PURPOSES">
            
            <cfset GIFT.RECEIPT.fileName = "#GIFT.RECEIPT.issuer#-#GIFT.RECEIPT.number#-AcknowledgementReceipt">
            <cfset specificReceiptFolder = Left(GIFT.RECEIPT.number, 4)>
            
            <cfset GIFT.RECEIPT.fileLocation = "#APPLICATION.WEBLINKS.File.service#/taxReceiptProcessor/#specificReceiptFolder#/#GIFT.RECEIPT.fileName#.pdf">
            <cfset GIFT.RECEIPT.urlLink = "#APPLICATION.WEBLINKS.SHPservice#/taxReceiptProcessor/#specificReceiptFolder#/#GIFT.RECEIPT.fileName#.pdf">
            <cfset GIFT.RECEIPT.urlLinkVIRTUAL = "#APPLICATION.WEBLINKS.SHPservice#/donate/receipts/?#selectTransaction.pge_UUID#">
            
            <cfset GIFT.RECEIPT.reSubject = "Online Donation">
            
            <cfset GIFT.EMAIL.subject = "#GIFT.RECEIPT.issuer# Acknowledgement Receipt #GIFT.RECEIPT.number#">
            
            <cfset confirmationMSG = "<p>Your confirmation e-mail with acknowledgement receipt attached has been sent to #selectTransaction.ptc_email#. <br />If you have any questions about this acknowledgement receipt, please contact us at 604-875-2444 or call toll free 1-888-663-3033 if you're outside of Greater Vancouver.</p>">
            <!--- scrub taxable amount --->
            <cfif GIFT.RECEIPT.taxAmount NEQ 0>
				<cfset GIFT.RECEIPT.advAmount = GIFT.RECEIPT.totalAmount>
            	<cfset GIFT.RECEIPT.taxAmount = 0>
            </cfif>
        
        <cfelseif GIFT.RECEIPT.type EQ 'NONE' OR GIFT.RECEIPT.type EQ 'TAX-ANNUAL'>
        <!--- No receipt / Annual receipt options --->
        
        	<cfset GIFT.EMAIL.subject = "Thank you for your donation to BC Children's Hospital">
            
            <cfset GIFT.RECEIPT.fileName = "None">
            
            <cfif selectTransaction.gift_type EQ 'SloPitch'
					AND selectTransaction.TeamID EQ 8503>
                    
                    
                <cfset confirmationMSG = "<p>Your confirmation e-mail has been sent to #selectTransaction.ptc_email#. <br />If you have any questions about your purchase, please contact us at 604-875-2444 or call toll free 1-888-663-3033 if you're outside of Greater Vancouver.</p>">
                    
            <cfelse>
            
            	<cfset confirmationMSG = "<p>Your confirmation e-mail has been sent to #selectTransaction.ptc_email#. <br />If you have any questions about your donation, please contact us at 604-875-2444 or call toll free 1-888-663-3033 if you're outside of Greater Vancouver.</p>">
            
            </cfif>
            
            
        
        
        <cfelse>
		<!--- TAX Receipt in these cases --->
        
            <cfset GIFT.RECEIPT.taxMessage = "OFFICIAL RECEIPT<br />
                FOR INCOME TAX PURPOSES">
            
            <cfset GIFT.RECEIPT.fileName = "#GIFT.RECEIPT.issuer#-#GIFT.RECEIPT.number#-TaxReceipt">
            <cfset specificReceiptFolder = Left(GIFT.RECEIPT.number, 4)>
            
            <cfset GIFT.RECEIPT.fileLocation = "#APPLICATION.WEBLINKS.File.service#/taxReceiptProcessor/#specificReceiptFolder#/#GIFT.RECEIPT.fileName#.pdf">
            <cfset GIFT.RECEIPT.urlLink = "#APPLICATION.WEBLINKS.SHPservice#/taxReceiptProcessor/#specificReceiptFolder#/#GIFT.RECEIPT.fileName#.pdf">
            <cfset GIFT.RECEIPT.urlLinkVIRTUAL = "#APPLICATION.WEBLINKS.SHPservice#/donate/receipts/?#selectTransaction.pge_UUID#">
            
            <cfset GIFT.RECEIPT.reSubject = "Online Donation">
            
            <cfset GIFT.EMAIL.subject = "#GIFT.RECEIPT.issuer# Tax Receipt #GIFT.RECEIPT.number#">
            
            <cfset confirmationMSG = "<p>Your confirmation e-mail with tax receipt attached has been sent to #selectTransaction.ptc_email#. <br />If you have any questions about this donation receipt, please contact us at 604-875-2444 or call toll free 1-888-663-3033 if you're outside of Greater Vancouver.</p>">
            
        </cfif>
        
        
        <!--- if there are custom receipt settings --->
		<!--- receipt image --->
        <cfif cusImage NEQ ''>
        
            <cfset GIFT.RECEIPT.image = cusImage>
            <cfset GIFT.RECEIPT.imageAlt = cusImageAlt>
        
        </cfif>
        
        <!--- receipt subject --->
        <cfif cusREsub NEQ ''>
        
            <cfset GIFT.RECEIPT.reSubject = cusREsub>
        
        </cfif>
    
    	<!--- load hon/mem name for tax receipt --->
        <cfif selectTransaction.gift_tribute EQ 'Yes'>
        
        	<cfif selectTransaction.trib_notes EQ 'hon'>
            
            	<cfset GIFT.RECEIPT.reSubject = "Online Donation in honour of #selectTransaction.trb_fname# #selectTransaction.trb_lname#">
            
            <cfelseif selectTransaction.trib_notes EQ 'mem'>
            
            	<cfset GIFT.RECEIPT.reSubject = "Online Donation in memory of #selectTransaction.trb_fname# #selectTransaction.trb_lname#">
            
            <cfelse>
            <!--- ecard... --->
           	</cfif>
        
        </cfif>
    
    	<!--- we have everything we need to construct the receipt --->
        
        
        <cfif GIFT.RECEIPT.generate EQ 1>
        
        	<cftry>
        
            
            <!--- directories --->
            <cfset dumpDirectory = "#APPLICATION.WEBLINKS.File.service#\taxReceiptProcessor\#specificReceiptFolder#\">
            
            <!--- check if directory exists --->
            <cfif DirectoryExists(dumpDirectory)>
                <!--- directory exists - we are all good --->
            <cfelse>
                <!--- need to create directory --->
                <cfdirectory directory="#dumpDirectory#" action="create">
                        
            </cfif>
            
            
            
            
            <cfdocument format="pdf" name="donationTaxReceipt" overwrite="yes" filename="#GIFT.RECEIPT.fileLocation#" fontembed="yes" permissions="allowprinting" encryption="128-bit">
            <cfinclude template="processDonation-Receipt.cfm">
            </cfdocument>
            
            <cfcatch type="any">
            	<!--- do not attach or link receipt --->
            	<cfset GIFT.RECEIPT.attach = 0>
            	<cfset GIFT.RECEIPT.link = 0>
                
                <cfmail to="csweeting@bcchf.ca" from="task@bcchf.ca" subject="Receipt Error" type="html"><cfdump var="#cfcatch#"></cfmail>
        	</cfcatch>
            </cftry>
        </cfif>
  
		<!--- Receipt has been generated
		Repost location of receipt in response --->      
        
        


<cfif GIFT.RECEIPT.link EQ 1>
<!--- tax or AWK --->

<cfset confirmationMSG = "#GIFT.RECEIPT.urlLinkVIRTUAL#">
<!--- 
GIFT.RECEIPT.urlLinkVIRTUAL
#GIFT.RECEIPT.fileName#.pdf --->




    

		<!--- update the transaction record to show that the receipt has already been processed --->
        <cftry>

		<!--- update the status code to H - receipt sent --->
        <cfquery name="updateReceiptStatus" datasource="#APPLICATION.DSN.transaction#">
        UPDATE DonationReceiptStatusTable 
        SET emailReceiptStatusID = 'H', 
        lastUpdated = #now()#, 
        retries = 0, 
        lastStatus = 'D'
        WHERE dtnID = #lookupSource.dtnID#
        </cfquery>
        
        <cfcatch type="any">
        </cfcatch>
        </cftry>
    
    
		<!--- also add info into Receipt type for new receipts --->
        <!--- we want to add 
			confirmation Sent
			confirmation Date
			--->
        <cfquery name="updateDonationReceiptRecord" datasource="#APPLICATION.DSN.transaction#">
        UPDATE tblDonation 
        SET dtnReceiptType = '#GIFT.RECEIPT.type#', 
        dtnReceiptNumber = '#GIFT.RECEIPT.number#',
        dtnExtra1 = 'New Receipt',
        dtnExtra2 = '#GIFT.RECEIPT.fileName#.pdf'
        WHERE pge_UUID = '#selectTransaction.pge_UUID#'
        </cfquery> 
        

</cfif>
    
    
    
    
	
<cfreturn confirmationMSG>
<!--- <cfreturn ''>	 --->
</cffunction>
</cfcomponent>