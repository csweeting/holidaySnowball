<!--- gathering data about the donation in order to send the receipt ... --->
<cfcomponent output="false">
<cffunction name="sendReceipt" access="remote" returntype="string">

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
	
	4. construct email
		- WOT / ICE / SHP options
		
	5. send email
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
    
    
    
    <cfif sendConfirmEmail EQ 1>
    
    
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
		<cfset GIFT.RECEIPT.image = "2018_TaxReceiptsLong.jpg">
        <cfset GIFT.RECEIPT.imageAlt = "Thanks for helping us aim higher.">

        
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
		Attach the content of the CFDocument tag to the outgoing email.  --->      
        
        
        <!--- 3. constructing email text --->
        <!--- set general defaults --->  
        <cfif ConstructEventDonText.recordCount EQ 0>
              
        	<cfset GIFT.EMAIL.MainText = "<p>Thank you for supporting BC Children's Hospital Foundation.</p>">
        
        <cfelse>
        
        	<cfset GIFT.EMAIL.MainText = ConstructEventDonText.TextApprovedBody>
        
        </cfif>
        
        <cfset GIFT.EMAIL.Event = ''>
		<cfset GIFT.EMAIL.SupportingMSG = 'Excellence in Child Health'>
        
		<!--- set BBQ attach to 0 ---->
		<cfset GIFT.TICKET.attach = 0>
        <cfset GIFT.TICKET.link = 0>
        
        
    
        <!--- Lookup some BBQ ticket detail for confirmation --->
        <cfif selectTransaction.gift_type EQ 'SloPitch'>
        
            <cfif selectTransaction.TeamID EQ 8503> 
            
                <!--- calculate number of tickets --->
                <cfset BBQtix = GIFT.RECEIPT.totalAmount / 15>
                
                <cfset GIFT.EMAIL.MainText = "<p>Thank you for getting on base for BC kids!</p><p>Please collect your Slo-Pitch BBQ tickets at the registration tent when you arrive at Softball City on your game day. Please note that BBQ tickets are non-refundable and are not eligible for tax receipts.</p><p>By purchasing BBQ tickets for our Slo-Pitch event you are supporting young BC Children’s Hospital patients like Will, whose leukemia diagnosis at age 15 forever changed his and his family’s life. <a href='http://www.bcchf.ca/stories/miracle-stories/will-heine/'>Learn more about his story here</a>.</p><p>For more information about Slo-Pitch visit <a href='http://www.bcchf.ca/events/event-calendar/slo-pitch/'>our website</a> or contact Lana Mador at 604-875-2514 or <a href='mailto:slopitch@bcchf.ca'>slopitch@bcchf.ca</a>.</p><p>Warmest regards,</p>">
                
            
            <cfelse>
                <cfset BBQtix = 0>
            </cfif>

		<cfelseif selectTransaction.gift_type EQ 'JeansDay'>
        
            <!--- lookup number of tickets --->
            <cfquery name="selectBBQ" datasource="bcchf_Superhero">
            SELECT JDBBQ, TeamID, SupID
            FROM Hero_DOnate WHERE pge_UUID = '#pge_UUID#'
            </cfquery>
            
            <cfif selectBBQ.recordCount NEQ 0>
                <cfset BBQtix = selectBBQ.JDBBQ>
            <cfelse>
                <cfset BBQtix = 0>
            </cfif>
            
            
			<cfif selectBBQ.TeamID EQ 0>
            <!--- virtual button
            <cfset GIFT.EMAIL.MainText = "<p>Thank you for participating in Jeans Day&trade;. Your 2018 virtual button can be <a href='https://secure.bcchf.ca/SuperheroPages/JeansDayVirtual.cfm?Event=JeansDay'>downloaded here</a>.</p><p>Show that you're supporting the most urgent needs at BC Children's Hospital by sharing your button on <a href='https://www.facebook.com/BCCHF'>Facebook</a>, <a href='https://www.instagram.com/BCCHF/'>Instagram</a> or <a href='https://twitter.com/BCCHF'>Twitter</a> and tagging us at @bcchf. We look forward to seeing your Canadian Tuxedo as we ##JeanUp on Thursday, May 3 for BC's Kids."> --->
            
            
            </cfif>
			
			
			<cfif BBQtix GT 0>
            
                <!--- 9130 Downtown BBQ --->
                <cfif selectBBQ.TeamID EQ 9130>
        
                    <cfset BBQticAmt = BBQtix * 10>
                    
                    <!--- donation confirmation text for this event --->
                    <cfquery name="ConstructEventDonText" 
                    	datasource="#APPLICATION.DSN.Superhero#">
                    SELECT TextApprovedBody FROM Hero_EventText 
                    WHERE Event = '#selectTransaction.gift_type#' 
                    	AND TextName = 'DonEmail-BBQ'
                    </cfquery>
                    
                    <cfset GIFT.EMAIL.MainText = ConstructEventDonText.TextApprovedBody>
                    
                    <cfset GIFT.EMAIL.MainText = Replace(GIFT.EMAIL.MainText, '%BBQtix%', '#BBQtix#', 'All')>
                    <cfset GIFT.EMAIL.MainText = Replace(GIFT.EMAIL.MainText, '%BBQtixAmt%', '#DollarFormat(BBQticAmt)#', 'All')>
                    
                    
                    <cftry>
                    <!--- GENERATE PDF Tickets to attach ---->
                    <cfquery name="selectBBQtix" datasource="bcchf_SuperHero">
                    SELECT * FROM JeansDay_BBQtix 
                    WHERE BBQ_tblUUID = '#pge_UUID#'
                    </cfquery>
                                        
                    <!--- directories --->
                    <cfset dumpDirectory = "#APPLICATION.WEBLINKS.File.service#\JeansDay\BBQtix\">
                    
                    <!--- check if directory exists --->
                    <cfif DirectoryExists(dumpDirectory)>
                        <!--- directory exists - we are all good --->
                    <cfelse>
                        <!--- need to create directory --->
                        <cfdirectory directory="#dumpDirectory#" action="create">
                                
                    </cfif>
                    
                    <cfif selectBBQtix.recordCount GT 0>
                    	<cfset GIFT.TICKET.attach = 1>
                        <cfset GIFT.TICKET.link = 0>
                    </cfif>
                    
                    
                    <cfcatch type="any">
                        <!--- do not attach or link receipt --->
                        <cfset GIFT.TICKET.attach = 0>
                        <cfset GIFT.TICKET.link = 0>
                        
                        <cfmail to="csweeting@bcchf.ca" from="task@bcchf.ca" subject="BBQ ticket Error" type="html"><cfdump var="#cfcatch#"></cfmail>
                    </cfcatch>
                    </cftry>
            
                <!--- 1917 BCCH --->
                <cfelseif selectBBQ.TeamID EQ 1917>
                
                    <cfset BBQticAmt = BBQtix * 5>
                    
                    <!--- donation confirmation text for this event --->
                    <cfquery name="ConstructEventDonText" datasource="#APPLICATION.DSN.Superhero#">
                    SELECT TextApprovedBody FROM Hero_EventText 
                    WHERE Event = '#selectTransaction.gift_type#' AND TextName = 'DonEmail-BBQbcch'
                    </cfquery>
                    
                    <cfset GIFT.EMAIL.MainText = ConstructEventDonText.TextApprovedBody>
                    
                    <cfset GIFT.EMAIL.MainText = Replace(GIFT.EMAIL.MainText, '%BBQtix%', '#BBQtix#', 'All')>
                    <cfset GIFT.EMAIL.MainText = Replace(GIFT.EMAIL.MainText, '%BBQtixAmt%', '#DollarFormat(BBQticAmt)#', 'All')>
                
                    
                <!--- 2590 HLC - BCCH / SH --->
                <cfelseif selectBBQ.TeamID EQ 2590>
                
                    <cfset BBQticAmt = BBQtix * 5>
                
                    <!--- donation confirmation text for this event --->
                    <cfquery name="ConstructEventDonText" datasource="#APPLICATION.DSN.Superhero#">
                    SELECT TextApprovedBody FROM Hero_EventText 
                    WHERE Event = '#selectTransaction.gift_type#' AND TextName = 'DonEmail-BBQbcch'
                    </cfquery>
                    
                    <cfset GIFT.EMAIL.MainText = ConstructEventDonText.TextApprovedBody>
                    
                    <cfset GIFT.EMAIL.MainText = Replace(GIFT.EMAIL.MainText, '%BBQtix%', '#BBQtix#', 'All')>
                    <cfset GIFT.EMAIL.MainText = Replace(GIFT.EMAIL.MainText, '%BBQtixAmt%', '#DollarFormat(BBQticAmt)#', 'All')>
                
                
                </cfif>
            </cfif>
        
        
        <cfelse>
            <cfset BBQtix = 0>
        </cfif>


<!--- ChildRun, JeansDay and General use RICH HTML content --->
<cfif selectTransaction.gift_type EQ 'ChildRun'
	OR selectTransaction.gift_type EQ 'RFTK'
	OR selectTransaction.gift_type EQ 'JeansDay'
	OR selectTransaction.gift_type EQ 'General'
	OR selectTransaction.gift_type EQ 'HolidaySnowball'>



<cfmail to="#selectTransaction.pty_fname# #selectTransaction.pty_lname# <#selectTransaction.ptc_email#>" from="BCCHF <bcchfds@bcchf.ca>" subject="#GIFT.EMAIL.subject#" type="html">
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">

<head>

<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />

<title>BC Children's Hospital Foundation</title>


<link href="https://fonts.googleapis.com/css?family=Roboto:400,400i,500,700" rel="stylesheet">
<script type="text/javascript" src="https://use.typekit.com/tcs6epu.js"></script>
<script type="text/javascript">try{Typekit.load();}catch(e){}</script>

</head>

<body text="##333333" link="##FF6600" vlink="##FF6600" alink="##FF6600" leftmargin="0" topmargin="0" marginwidth="0" marginheight="0" bgcolor="##c8c9cb">

<style><!--
a:link {
	color:##f9a13a;
}      /* unvisited link */
a:visited {
	color:##f9a13a;
}  /* visited link */
a:hover {
	color:##f9a13a;
}  /* mouse over link */
a:active {
	color:##f9a13a;
}  /* selected link */
--></style>

<table style="width: 100%;" border="0" cellspacing="0" cellpadding="0">
<tbody>
<tr>
<td align="center" bgcolor="##c8c9cb">


<div align="center">
<table style="width: 720px;" border="0" cellspacing="0" cellpadding="0" align="center">
<tbody>
<tr>
<td bgcolor="##ffffff">
<!--- header --->
	<cfset divTagSuffux = ''>
    
    <cfif selectTransaction.gift_type EQ 'ChildRun'>
    
    <img src="http://newsletter.bcchf.ca/images/2015/header-ChildRun.png" width="720" alt="ChildRun" border="0">
    
    <cfelseif selectTransaction.gift_type EQ 'RFTK'>

	<div><img src="http://newsletter.bcchf.ca/images/2018/header-RFTK.png" width="720" alt="2018 RBC Race for the Kids" border="0"></div>
	
	<cfelseif selectTransaction.gift_type EQ 'JeansDay'>

	<div><img src="http://newsletter.bcchf.ca/images/2018/header-JeansDay.png" width="720" alt="Jeans Day" border="0" ></div>
    
    <cfelseif selectTransaction.gift_type EQ 'General'>

	<div><img src="http://newsletter.bcchf.ca/images/2016/header-GeneralA.png" width="720" border="0" alt="BC Children's Hospital Foundation"></div>
    
    <cfelseif selectTransaction.gift_type EQ 'HolidaySnowball'>

	<div><img src="http://newsletter.bcchf.ca/images/2017/header-holidaySnowball.png" width="720" border="0" alt="BC Children's Hospital Foundation"></div>


</cfif>

    
    
        
</td>
</tr>
<tr>
<td bgcolor="##ffffff">&nbsp;</td>
</tr>
<tr>
<td bgcolor="##ffffff">
<table style="width: 720px;" border="0" cellspacing="0" cellpadding="0">
<tbody>
<tr>
<td width="60"><img alt="." height="1" src="https://my.bcchf.ca/view.image?Id=612" width="60" /></td>
<td align="left" width="610">
<!--- main article header
  <div style="color: #007ac2; font-size: 18px; text-align:left; line-height: 25px; font-family: 'futura-pt',Helvetica, sans-serif; font-weight:bold;">5th annual A Night of Miracles gala benefiting BC Children's Hospital</div> --->&nbsp;
</td>
<td width="50"><img alt="." height="1" src="https://my.bcchf.ca/view.image?Id=612" width="50" /></td>
</tr>
<tr>
<td>&nbsp;</td>
<td>
<div style="font-family: <cfif selectTransaction.gift_type EQ 'HolidaySnowball'>Roboto, </cfif>Verdana, Arial, Helvetica, sans-serif; font-size: 12px; text-align: left; line-height: 20px; padding-right: 30px; color: ##000000;">
<p>Dear #selectTransaction.pty_fname# #selectTransaction.pty_lname#,</p>
</div>

<div style="font-family: <cfif selectTransaction.gift_type EQ 'HolidaySnowball'>Roboto, </cfif>Verdana, Arial, Helvetica, sans-serif; font-size: 12px; text-align: left; line-height: 20px; padding-right: 30px; color: ##000000;">
#GIFT.EMAIL.MainText#
</div>

<div style="font-family: <cfif selectTransaction.gift_type EQ 'HolidaySnowball'>Roboto, </cfif>Verdana, Arial, Helvetica, sans-serif; font-size: 12px; text-align: left; line-height: 20px; padding-right: 30px; color: ##000000;">
<cfif selectTransaction.gift_type NEQ 'JeansDay'>
<p><cfif selectTransaction.gift_type EQ 'HolidaySnowball'><strong>Teri Nicholas</strong><cfelse>Teri Nicholas</cfif><br />
President &amp; CEO<br />
BC Children's Hospital Foundation</p>
</cfif>
<cfif GIFT.RECEIPT.type EQ 'TAX-ANNUAL'>
<p>Your charitable tax receipt will be mailed to your address shortly after the end of the year. </p>
</cfif>

<cfif GIFT.RECEIPT.link EQ 1>
<!--- tax or AWK --->
<cfif GIFT.RECEIPT.type EQ 'AWK'>
<p>You may find your acknowledgement receipt attached to this e-mail or <a href="#GIFT.RECEIPT.urlLinkVIRTUAL#">download a copy here</a>. If you have any questions about this acknowledgement receipt, please contact us at 604-875-2444 or call toll free 1-888-663-3033 if you're outside of Greater Vancouver.</p>
<cfelse>
<p>You may find your charitable tax receipt attached to this e-mail or <a href="#GIFT.RECEIPT.urlLinkVIRTUAL#">download a copy here</a>. If you have any questions about this donation receipt, please contact us at 604-875-2444 or call toll free 1-888-663-3033 if you're outside of Greater Vancouver.</p>
</cfif>
</cfif>
<cfif HospitalVisit EQ 1>
<p>Wonderful things happen every day at BC Children's Hospital because of donors like you.  Read inspiring stories and consider sharing your own hospital journey with us.  Visit <a href="http://www.bcchf.ca/stories">www.bcchf.ca/stories</a>.</p>
</cfif>
 
<cfif GIFT.RECEIPT.totalAmount GT 9999>
<!--- include Vanessa's Contact info for gifts above 10,000  --->
<p>For more information on the Circle of Care contact:<br />
Vanessa Abaya at 604-875-2637<br />
<a href="mailto:ccc@bcchf.ca">ccc@bcchf.ca</a></p>
</cfif>

<cfif BBQtix GT 0>
<p>The following summarizes your purchase:</p>
<cfelse>
<p>The following summarizes your donation:</p>
</cfif>

<p>Received on: #DateFormat(Now(), "DDDD, MMMM DD, YYYY")#<br />
Donor Name: #GIFT.RECEIPT.donorName#<br />
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
<cfif BBQtix GT 0>
Total Number of Tickets: #BBQtix#<br />
Transaction Total: #DollarFormat(GIFT.RECEIPT.totalAmount)#<br />
<cfelse>
Donation: #DollarFormat(GIFT.RECEIPT.totalAmount)#<br />
</cfif>
<!--- tribute / WOT / ICE / Hero / eCard / supporting text ---->
<!--- Supporting: #emailConfirmationText#<br /> --->
Comments: #selectTransaction.gift_notes#<br />
<br />
======Transaction Record======<br />
BC Children's Hospital Foundation<br />
938 West 28th Ave.<br />
Vancouver, BC V5Z 4H4<br />
Canada<br />
http://www.bcchf.ca<br />
TYPE: Purchase<br />
PAY TYPE: #lookupSource.post_card_type#<br />
DATE: #DateFormat(Now(), "DD MMM YYYY HH:MM:SS")#<br />
AMOUNT: #DollarFormat(GIFT.RECEIPT.totalAmount)# CAD<br />
AUTH: #selectTransaction.rqst_authorization_num#<br />
REF: #selectTransaction.rqst_sequenceno#<br />
<br />
Thank You.<br />
</p>
</div>
</td>
<td>&nbsp;</td>
</tr>
</tbody>
</table>
</td>
</tr>
<tr>
<td bgcolor="##ffffff">&nbsp;</td>
</tr>
<tr>
<td bgcolor="##ffffff">

<cfif selectTransaction.gift_type EQ 'ChildRun'>

<div><img src="http://newsletter.bcchf.ca/images/2013/footer-ChildRun.png" width="720" border="0" usemap="##Map"><br><img src="http://newsletter.bcchf.ca/images/2013/footer-ChildRun-sponsorOnly.png" width="720" height="98" alt="ChildRun Sponsors"></div>
<map name="Map">
    <area shape="rect" coords="495,31,533,68" href="https://www.facebook.com/ChildRun" target="_blank" alt="Facebook">
    <area shape="rect" coords="538,31,573,68" href="https://twitter.com/bcchildrun" target="_blank" alt="Twitter">
    <area shape="rect" coords="498,81,684,133" href="https://secure.bcchf.ca/SuperheroPages/search.cfm?Event=ChildRun" target="_blank" alt="Donate">
  </map>

<cfelseif selectTransaction.gift_type EQ 'RFTK'>
            
            <div><img src="http://newsletter.bcchf.ca/images/2016/footer-new.png" width="720" border="0" height="168" usemap="##Map"></div>

<map name="Map"> 
	<area shape="rect" coords="644,84,687,128" href="https://youtube.com/bcchf" target="_blank" alt="YouTube" /> 
	<area shape="rect" coords="598,84,641,128" href="https://instagram.com/bcchf" target="_blank" alt="Instagram" /> 
	<area shape="rect" coords="507,84,550,128" href="https://www.facebook.com/BCCHF" target="_blank" alt="Facebook"> 
	<area shape="rect" coords="553,84,596,128" href="http://twitter.com/bcchf" target="_blank" alt="Twitter"> 
	<area shape="rect" coords="507,10,687,81" href="https://secure.bcchf.ca/SuperheroPages/search.cfm?Event=RFTK&utm_source=dConfirmation&utm_medium=email&utm_campaign=RFTK&utm_content=BottomGraphic" target="_blank" alt="Donate"> 
	</map> 


<cfelseif selectTransaction.gift_type EQ 'JeansDay'>

<div><img src="http://newsletter.bcchf.ca/images/2018/footer-jeansday.png" width="720" border="0" height="158" usemap="##JeansMap"></div>


<map name="JeansMap">
    <area shape="rect" coords="644,84,687,128" href="https://youtube.com/bcchf" target="_blank" alt="YouTube" /> 
	<area shape="rect" coords="598,84,641,128" href="https://instagram.com/bcchf" target="_blank" alt="Instagram" /> 
	<area shape="rect" coords="507,84,550,128" href="https://www.facebook.com/BCCHF" target="_blank" alt="Facebook"> 
	<area shape="rect" coords="553,84,596,128" href="http://twitter.com/bcchf" target="_blank" alt="Twitter"> 
	<area shape="rect" coords="507,10,687,81" href="https://secure.bcchf.ca/SuperheroPages/search.cfm?Event=JeansDay&utm_source=DonationConfirmation&utm_medium=email&utm_campaign=JeansDay&utm_content=BottomGraphic" target="_blank" alt="Donate">
</map>
<cfelseif selectTransaction.gift_type EQ 'General'>

<cfset donationLink = 'http://www.bcchf.ca/donate/'>
<cfset FBfootLink = 'https://www.facebook.com/BCCHF'>
<cfset TWfootLink = 'http://twitter.com/bcchf'>
<cfset YTfootLink = 'https://youtube.com/bcchf'>
<cfset IGfootLink = 'https://instagram.com/bcchf'>


<div><img src="http://newsletter.bcchf.ca/images/2016/footer-new.png" width="720" border="0" height="150" usemap="##GeneralMap"></div>

<map name="GeneralMap">
	<area shape="rect" coords="644,84,687,128" href="#YTfootLink#" target="_blank" alt="YouTube" />
    <area shape="rect" coords="598,84,641,128" href="#IGfootLink#" target="_blank" alt="Instagram" />
    <area shape="rect" coords="507,84,550,128" href="#FBfootLink#" target="_blank" alt="Facebook">
    <area shape="rect" coords="553,84,596,128" href="#TWfootLink#" target="_blank" alt="Twitter">
    <area shape="rect" coords="507,10,687,81" href="#donationLink#" target="_blank" alt="Donate">
  </map>
<!--
    <a href="#FBfootLink#" target="_blank" alt="Facebook">Facebook-FooterMap</a>
    <a href="#TWfootLink#" target="_blank" alt="Twitter">Twitter-FooterMap</a>
    <a href="#IGfootLink#" target="_blank" alt="Instagram">Instagram-FooterMap</a>
    <a href="#YTfootLink#" target="_blank" alt="YouTube">YouTube-FooterMap</a>
    <a href="#donationLink#" target="_blank" alt="Donate">DonateNow-FooterMap</a>
-->
<cfelseif selectTransaction.gift_type EQ 'HolidaySnowball'>
</cfif>

</td>
</tr>
</tbody>
</table>
</div>


</td>
</tr>
</tbody>
</table>


</body>
</html>

 
<cfif GIFT.RECEIPT.attach EQ 1>
<cfmailparam
file="#GIFT.RECEIPT.fileName#.pdf"
type="application/pdf"
content="#donationTaxReceipt#"
/>
</cfif>
<cfif GIFT.TICKET.attach EQ 1>
<!--- attempt to generate and attach tickets
    
	<cfloop query="selectBBQtix">
    <cfset GIFT.TICKET.number = selectBBQtix.BBQticketnumber>
    <cfset GIFT.TICKET.totalAmount = 10>
                    
    <cfdocument format="pdf" name="JDBBQcurrentTicket" overwrite="yes" filename="#dumpDirectory#JDBBQticket#GIFT.TICKET.number#.pdf" fontembed="yes" permissions="allowprinting" encryption="128-bit">
    <cfinclude template="processDonation-JDBBQticket.cfm">
    </cfdocument>
    
    <cfmailparam
        file="JDBBQticket#GIFT.TICKET.number#.pdf"
        type="application/pdf"
        content="#JDBBQcurrentTicket#"
        />
    </cfloop>
 --->
</cfif>
 
</cfmail>



    
    
    

<!--- ALL OTHER CONFIRMATIONS --->
<cfelse>  


<cfmail to="#selectTransaction.pty_fname# #selectTransaction.pty_lname# <#selectTransaction.ptc_email#>" from="BCCHF <bcchfds@bcchf.ca>" subject="#GIFT.EMAIL.subject#" type="html">
<p>Dear #selectTransaction.pty_fname# #selectTransaction.pty_lname#,</p>
#GIFT.EMAIL.MainText#
<p>Teri Nicholas<br />
President &amp; CEO<br />
BC Children's Hospital Foundation</p>
<cfif GIFT.RECEIPT.type EQ 'TAX-ANNUAL'>
<p>Your charitable tax receipt will be mailed to your address shortly after the end of the year. </p>
</cfif>

<cfif GIFT.RECEIPT.link EQ 1>
<cfif GIFT.RECEIPT.type EQ 'AWK'>
<p>You may find your acknowledgement receipt attached to this e-mail or <a href="#GIFT.RECEIPT.urlLinkVIRTUAL#">download a copy here</a>. If you have any questions about this acknowledgement receipt, please contact us at 604-875-2444 or call toll free 1-888-663-3033 if you're outside of Greater Vancouver.</p>
<cfelse>
<p>You may find your charitable tax receipt attached to this e-mail or <a href="#GIFT.RECEIPT.urlLinkVIRTUAL#">download a copy here</a>. If you have any questions about this donation receipt, please contact us at 604-875-2444 or call toll free 1-888-663-3033 if you're outside of Greater Vancouver.</p>
</cfif>
</cfif>
<cfif HospitalVisit EQ 1>
<p>Wonderful things happen every day at BC Children's Hospital because of donors like you.  Read inspiring stories and consider sharing your own hospital journey with us.  Visit <a href="http://www.bcchf.ca/stories">www.bcchf.ca/stories</a>.</p>
</cfif>

<cfif GIFT.RECEIPT.totalAmount GT 9999>
<!--- include Vanessa's Contact info for gifts above 10,000  --->
<p>For more information on the Circle of Care contact:<br />
Vanessa Abaya at 604-875-2637<br />
<a href="mailto:ccc@bcchf.ca">ccc@bcchf.ca</a></p>
</cfif>


<cfif BBQtix GT 0>
<p>The following summarizes your purchase:</p>
<cfelse>
<p>The following summarizes your donation:</p>
</cfif>

<p>Received on: #DateFormat(Now(), "DDDD, MMMM DD, YYYY")#<br />
Donor Name: #GIFT.RECEIPT.donorName#<br />
Email: #selectTransaction.ptc_email#<br />
<cfif selectTransaction.ptc_subscribe EQ 'Yes'>
Yes, I allow BC Children's Hospital Foundation to contact me via email with information about my gift, ways to support, and how donor support is benefiting BC Children's Hospital.<br />
<cfelse>
<!--- 
No, I do not allow BC Children's Hospital Foundation to contact me via email with information about my gift, ways to support, and how donor support is benefiting BC Children's Hospital.<br />--->
</cfif>
Address: #selectTransaction.ptc_address# #selectTransaction.ptc_add_Two#<br />
City: #selectTransaction.ptc_city#<br />
Province: #selectTransaction.ptc_prov#<br />
Postal Code: #selectTransaction.ptc_post#<br />
Phone: #selectTransaction.ptc_phone#<br />
Gift Type: #selectTransaction.gift_frequency#<br />
<cfif selectTransaction.gift_frequency EQ 'monthly'>
For monthly donation, you may cancel your authorization at any time by notifying the Foundation at 604-875-2444.<br />
</cfif><br />
<cfif BBQtix GT 0>
Total Number of Tickets: #BBQtix#<br />
Transaction Total: #DollarFormat(GIFT.RECEIPT.totalAmount)#<br />
<cfelse>
Donation: #DollarFormat(GIFT.RECEIPT.totalAmount)#<br />
</cfif>
<!--- tribute / WOT / ICE / Hero / eCard / supporting text ---->
<!--- Supporting: #emailConfirmationText#<br /> --->
Comments: #selectTransaction.gift_notes#<br />
<br />
======Transaction Record======<br />
BC Children's Hospital Foundation<br />
938 West 28th Ave.<br />
Vancouver, BC V5Z 4H4<br />
Canada<br />
http://www.bcchf.ca<br />
TYPE: Purchase<br />
PAY TYPE: #lookupSource.post_card_type#<br />
DATE: #DateFormat(Now(), "DD MMM YYYY HH:MM:SS")#<br />
AMOUNT: #DollarFormat(GIFT.RECEIPT.totalAmount)# CAD<br />
AUTH: #selectTransaction.rqst_authorization_num#<br />
REF: #selectTransaction.rqst_sequenceno#<br />
<br />
Thank You.<br />
</p>


 <!------>
<cfif GIFT.RECEIPT.attach EQ 1>
<cfmailparam
file="#GIFT.RECEIPT.fileName#.pdf"
type="application/pdf"
content="#donationTaxReceipt#"
/>
</cfif> 
 
</cfmail>

</cfif>


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
        dtnExtra1 = 'New Receipt',
        dtnExtra2 = '#GIFT.RECEIPT.fileName#.pdf'
        WHERE pge_UUID = '#selectTransaction.pge_UUID#'
        </cfquery> 
        

        </cfif>
    
    
    
    
	
<cfreturn confirmationMSG>
<!--- <cfreturn ''>	 --->
</cffunction>
</cfcomponent>