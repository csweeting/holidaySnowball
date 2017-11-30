<cfcomponent output="false">
<!--- process donation cfc 
	processes the donation form 
	
		2012 
			new receipt generator in place ---
			legacy generator still running ---
			
			records donor infomration
				records event related information
				sends event related emails
			sends donor email
			
		
		returns a struct about the transaction
		
	---->

<!--- some validation occurs before we hit this step --->
<!--- high level validation not required at this time --->
<!--- mixed results with this ... --- verifyClient="yes" --->
<cffunction name="submitNewDonationForm" access="remote" returnformat="json" >

	<cfargument name="bcchf_donor_first_name" type="string" required="no">
    <cfargument name="bcchf_donor_last_name" type="string" required="no">
    
    <!--- SET form DEFAULTS --->
    <!--- SERVER Date at submission --->
	<cfif NOT IsDefined("pty_date")><cfset pty_date= "#Now()#"></cfif>
    
    <!--- create UUID to access info --->
    <cfset variables.newUUID=createUUID()>
    
    <!--- collect IP address of remote requestor --->
    <cfset newIP = CGI.REMOTE_ADDR>
    <cfset newBrowser = CGI.HTTP_USER_AGENT>
    <cfset ipBlocker = 0>
    
    <!--- return variables
		SET to 0  --->
    <cfset chargeSuccess = 0>
    <cfset donationSuccess = 0>
    <cfset chargeAttempt = 0>
    <cfset chargeAproved = 0>
    <cfset chargeMSG = "">
    <cfset tGenTwoID = 0>
    
    <!--- construct initial return message --->
    <cfset returnSuccess = 0>
    <cfset returnMSG = 'beginAttempt'>
    <cfset exact_respCode = 0>
    
    <!--- set source --->
    <cfset donation_source = 'New 2015 Donation Form'>
    <cfset pty_tax_issuer = 'BCCHF'>

    
    <!--- scrub some variables for db loading --->
    <cftry>
    	
        <!--- Personal or Corporate - set tax values with this info --->
        <cfset hiddenDonationPCType = hiddenDonationPCType>
    
		<!--- donor information --->
        <cfset pty_title = bcchf_salutation>
        <cfset pty_fname = TRIM(bcchf_first_name)>
        <cfset pty_MIname = TRIM(bcchf_middle_initial)>
        <cfset pty_lname = TRIM(bcchf_last_name)>
        
        <cfset pty_tax_title = bcchf_salutation>
        <cfset pty_tax_fname = TRIM(bcchf_first_name)>
        <cfset pty_tax_MIname = TRIM(bcchf_middle_initial)>
        <cfset pty_tax_lname = TRIM(bcchf_last_name)>
        
        <cfset pty_companyname = TRIM(bcchf_company_name)>
        <cfset pty_tax_companyname = TRIM(bcchf_company_name)>
        
        <cfset ptc_address = TRIM(bcchf_address)>
        <cfset ptc_addTwo = TRIM(bcchf_address2)>
        <cfset ptc_city = TRIM(bcchf_city)>
        <cfset ptc_country = TRIM(bcchf_country)>
        <cfset ptc_prov = TRIM(bcchf_province)>
        <cfset ptc_post = TRIM(bcchf_postal_code)>
        <cfset ptc_email = TRIM(bcchf_email)>
        <cfset ptc_phone = TRIM(bcchf_phone)>
        
        <!--- ESubscribe options ---->
        <cfif IsDefined('bcchf_allow_contact')>
            <cfset pty_subscr_r = bcchf_allow_contact>
            <cfset SOC_subscribe = 1>
            <cfset news_subscribe = 1>
            <cfset AR_subscribe = 1>
        <cfelse>
            <cfset pty_subscr_r = 0>
            <cfset SOC_subscribe = 0>
            <cfset news_subscribe = 0>
            <cfset AR_subscribe = 0>
        </cfif>
              
        <!--- SHP event scroll details --->
        <cfset hiddenEventToken = hiddenEventToken>
        <cfset hiddenEventCurrentYear = hiddenEventCurrentYear>
        <cfset hiddenTeamID = hiddenTeamID>
        <cfset hiddenSupID = hiddenSupID>
        <!--- <cfset hiddentype = hiddentype> --->
        <cfset hiddentype = ''>
        <cfset Message = bcchf_encouragement_msg>
        
        <cfif IsDefined('bcchf_hide_message')>
			<cfset Show = 0>
        <cfelse>
        	<cfset Show = 1>
        </cfif>
        
        <!--- Personal Corporate Donation --->
        <cfif hiddenDonationPCType EQ 'corporate'>
        	<cfset DName = '#TRIM(bcchf_donor_company_name)#'>
            <!--- corporate donation 
			 --- EMPTY the personal tax fields--->
            <cfset pty_tax_title = "">
            <cfset pty_tax_fname = "">
            <cfset pty_tax_lname = "">
        <cfelse>
        	<cfset DName = '#TRIM(bcchf_donor_first_name)# #TRIM(bcchf_donor_last_name)#'>
            <!--- personal donation 
				EMPTY the corporate donation fields --->
            <cfset pty_tax_companyname = "">
        </cfif>        
        
        <cfif IsDefined('bcchf_hide_name')>
        	<cfset ShowAnonymous = 1>
            <cfset DName = 'Anonymous'>
        <cfelse>
        	<cfset ShowAnonymous = 0>
        </cfif>
        
        <cfif DName EQ '' OR DName EQ ' '>
        	<cfset ShowAnonymous = 1>
        	<cfset DName = 'Anonymous'>
        </cfif>
        
        <!--- set gift type --->
        <cfset gift_type = hiddenGiftType>
        <cfset gift_notes = bcchf_special_instr>
        
        <!--- set gift amount --->
        <cfif bcchf_gift_amount EQ ''>
            <cfset hiddenGiftAmount = bcchf_other_amt>
        <cfelse>
            <cfset hiddenGiftAmount = bcchf_gift_amount>
        </cfif>
        
        <cfset hiddenGiftAmount = REREPlace(hiddenGiftAmount, '[^0-9.]','','all')>
        <cfset post_dollaramount = hiddenGiftAmount>
        <cfset Hero_Donate_Amount = post_dollaramount>
        
        <cfset giftAdvantage = 0>
        <cfset giftTaxable = post_dollaramount>
        
        <!--- gift frequency --->
        <cfset hiddenDonationType = bcchf_donation_type>
        <cfset donation_type = bcchf_donation_type>
        <cfset hiddenFreqDay = bcchf_donation_on>
        
        <!--- determine gift frequency Day --->
		<cfif hiddenDonationType EQ 'monthly'>
            
			<cfset GiftFreqM = 1>
			<cfset gift_frequency = 'Monthly'>
            
			<cfif IsDefined('hiddenFreqDay')>
                <cfset gift_day = hiddenFreqDay>
            <cfelse>
                <cfset gift_day = 1>
            </cfif>
            
        <cfelse>
        
        	<cfset GiftFreqM = 0>
        	<cfset gift_frequency = 'Single'>
            <cfset gift_day = "">
            
        </cfif>
        
        <!--- tribute type --->
        <!--- eCard for eCards - Pledge for Pledge --->
        <cfif IsDefined('bcchf_donation_honour')>
			<cfset hiddenTributeType = bcchf_donation_honour>
            <cfset gift_TributeType = bcchf_donation_honour>
        <cfelse>
			<cfset hiddenTributeType = 'general'>
            <cfset gift_TributeType = 'general'>
        </cfif>
        
        <!--- tax receipt information --->
        <cfset pty_tax = bcchf_receipt>
        <!--- DEFAULT Ink Friendly --->
        <cfset pty_ink = 'Yes'>
        
        <!--- cardholder data --->
        <cfset post_card_number = bcchf_cc_number>
        <cfset post_expiry_month = bcchf_expire_month>
        <!--- ensure expiry date length --->
        <cfif Len(post_expiry_month) EQ 1>
            <cfset post_expiry_month = "0#post_expiry_month#">
        </cfif>
        <cfset post_expiry_year = bcchf_expire_year>
        <cfset post_expiry_date = '#post_expiry_month##post_expiry_year#'>
        <cfset post_cardholdersname = bcchf_cc_name>
        <cfset post_CVV = bcchf_cvv>
        
        <cfif Left(post_card_number, 1) EQ 3>
            <cfset post_card_type = 'AMEX'>
        <cfelseif Left(post_card_number, 1) EQ 4>
            <cfset post_card_type = 'VISA'>
        <cfelseif Left(post_card_number, 1) EQ 5>
            <cfset post_card_type = 'MC'>
        <cfelseif Left(post_card_number, 1) EQ 6>
            <cfset post_card_type = 'DISCOVER'>
        <cfelse>
            <cfset post_card_type = 'Invalid'>
        </cfif>
        
        <!--- email referal conditions --->
        <cfset emailReferal = ''>
        
        <!--- tribute information --->
        <cfif hiddenTributeType EQ 'honour'>
            <cfset trb_fname = ''>
            <cfset trb_lname = bcchf_in_honour_name>
            <cfset gTribute = 'Yes'>
        <cfelseif hiddenTributeType EQ 'memory'>
            <cfset trb_fname = ''>
            <cfset trb_lname = bcchf_in_memory_name>
            <cfset gTribute = 'Yes'>
        <cfelse>
            <cfset trb_fname = ''>
            <cfset trb_lname = ''>
            <cfset gTribute = 'No'>
        </cfif>
        <cfset cleanTrbMessage =''>
        
        <!--- Tribute AWK indicator token --->
        <cfif IsDefined('bcchf_acknowledgement')>
            <cfset hiddenAWKtype = 'ask'>
        <cfelse>
            <cfset hiddenAWKtype = ''>
        </cfif>
        
        <!--- read ePhil Source --->
        <cfif IsDefined('ePhilanthropySource')>
            <cfset ePhilSRC = ePhilanthropySource>
        <cfelse>
            <cfset ePhilSRC = ''>
        </cfif>
        
        <!--- pledge details --->
        <cfif hiddenTributeType EQ 'pledge'>
		
			<cfset gift_pledge_DonorID = bcchf_donor_id>
            <cfset gift_pledge_det = gift_pledge_DonorID>
            <cfset gPledge = 'Yes'>
        
        <cfelse>
        
            <cfset gift_pledge_DonorID =''>
            <cfset gift_pledge_det = ''>
            <cfset gPledge = 'No'>
        
        </cfif>
        
    	<!--- TAX receipt options for processor ---->
        <!--- receipt types
			TAX = TAX RECEIPT
			AWK = AWKNOWLEDGMENT RECEIPT
			TAX-IF = Ink Friendly
			TAX-ANNUAL = Annual Receipt for monthly gift
			NONE = None requested / ineligible
			--->
		<cfif GiftFreqM EQ 1>
        
        	<!--- Monthly Receipt --->
            <cfif pty_tax EQ "no">
                <cfset receipt_type = 'NONE'>
            <cfelse>
                <cfset receipt_type = 'TAX-ANNUAL'>
            </cfif>  
            
        <cfelse>
        
        	<cfif pty_tax EQ "no">
                <cfset receipt_type = 'NONE'>
            <cfelse>
    			<cfset receipt_type = 'TAX-IF'>
            </cfif>
             
        </cfif>
        
    
    	<!--- legacy: receipt generator method
			- check for receipt status 
			- append 'no receipt' to frequency for no receipt--->
        <cfif pty_tax EQ "no">
			<cfset gift_frequency="#hiddenDonationType# - No Receipt">
        <cfelse>
        	<cfset gift_frequency="#hiddenDonationType#">
        </cfif>
        
        
        
    <cfcatch type="any">
    	<!--- ERROR Message ---------------------------------------------------- --->
    	<cfset eDetailMSG = {tDate = pty_date,
			cfcatch = cfcatch,
			CGIscope = CGI,
			tUUID = variables.newUUID,
			eP = 2,
			eML = 1}>
		<cfset eDetails = SerializeJSON(eDetailMSG)>
    	<cfset errorSend = sendERRmsg(eDetails)>
    
    </cfcatch>
    </cftry>
    
    
    <!--- attempt charge --->
	<cfset chargeAttempt = 1>
    <cfset attemptCharge = 1>
    <cfset returnMSG = 'beginAttempt-charging'>
    
    
	<!--- Trying to record Attempt Record --->
    <cftry>
    
    	<cfset tAttemptRecord = {tDate = pty_date, 
						tUUID = variables.newUUID,
						tDonor = {
							dTitle = pty_title,
							dFname = pty_fname,
							dMname = pty_miname,
							dLname = pty_lname,
							dCname = pty_companyname,
							dTaxTitle = pty_tax_title,
							dTaxFname = pty_tax_fname,
							dTaxMname = pty_miname,
							dTaxLname = pty_tax_lname,
							dTaxCname = pty_tax_companyname,
							dAddress = {
								aOne = ptc_address,
								aTwo = ptc_addTwo,
								aCity = ptc_city,
								aProv = ptc_prov,
								aPost = ptc_post,
								aCountry = ptc_country
							},
							dEmail = ptc_email,
							dPhone = ptc_phone
						},
						tGift = post_dollaramount,
						tGiftAdv = 0,
						tGiftTax = post_dollaramount,
						tType = gift_type,
						tFreq = gift_frequency,
						tNotes = gift_notes,
						tSource = donation_source,
						eSource = ePhilSRC,
						tBrowser = {
							bUAgent = newBrowser,
							bName = uabrowsername,
							bMajor = uabrowsermajor,
							bVer = uabrowserversion,
							bOSname = uaosname,
							bOSver = uaosversion,
							dDevice = uadevicename,
							bDtype = uadevicetype,
							bDvend = uadevicevendor,
							bIP = newIP
						},
						tTType = pty_tax,
						tFreqDay = gift_day,
						tSHP = {
							tAdd = 1,
							tToken = hiddenEventToken,
							tCampaign = hiddenEventCurrentYear,
							tTeamID = hiddenTeamID,
							tSupID = hiddenSupID,
							tDname = DName,
							tStype = hiddentype,
							tSmsg = Message,
							tSshow = Show,
							Hero_Donate_Amount = Hero_Donate_Amount
						},
						tFORM = {
							hiddenDonationPCType = hiddenDonationPCType,
							hiddenDonationType = hiddenDonationType,
							hiddenFreqDay = hiddenFreqDay,
							hiddenGiftAmount = hiddenGiftAmount,
							donation_type = donation_type,
							gift_frequency = gift_frequency,
							gift_day = gift_day,
							hiddenTributeType = hiddenTributeType,
							gift_tributeType = gift_tributeType
							
						},
						adInfo = {
							SOC_subscribe = SOC_subscribe,
							news_subscribe = news_subscribe,
							AR_subscribe = AR_subscribe,
							gPledgeDet = gift_pledge_det,
							gPledgeDREID = gift_pledge_DonorID,
							gPledge = gPledge
						},
						tribInfo = {
							trbFname = trb_fname,
							trbLname = trb_lname,
							cardSend = hiddenAWKtype,
							tribNotes = hiddenTributeType,
							gTribute = gTribute
						}
			} />
            
            <cfset tAttempt = SerializeJSON(tAttemptRecord)>
    	
    		<cfset tATPrec = recordTransAttempt(tAttempt)>
    
    	<!---- <cfinclude template="../includes/0log_donation.cfm"> --->
    
    <cfcatch type="any">
    
    	<!--- ERROR Message ------------------------------------------------------ --->
    	<cfset eDetailMSG = {tDate = pty_date,
			cfcatch = cfcatch,
			CGIscope = CGI,
			tUUID = variables.newUUID,
			eP = 3,
			eML = 2}>
		<cfset eDetails = SerializeJSON(eDetailMSG)>
    	<cfset errorSend = sendERRmsg(eDetails)>
    
    </cfcatch>
    </cftry>
    
    <!--- try fraudster intercept:
		check for XDS
		check IP on blackList
		check fraudster MO --->
    <cftry>
    
    	<!--- XDS --->
		<cfset goodXDS = checkXDS(APPLICATION.AppVerifyXDS, FORM.App_verifyToken, CGI.HTTP_REFERER)>
        
        <cfif goodXDS EQ 0>
            <cfset attemptCharge = 0>
        </cfif>
    
		<!--- check IP against blacklist --->
        <cfset goodIP = checkIPaddress(newIP)>
        
        <cfif goodIP EQ 0>
            <cfset attemptCharge = 0>
        </cfif>
    
		<!--- check Fraudster MO --->
        <cfset fradulent = checkFraudsterMO(pty_tax_fname, pty_tax_lname, pty_fname, pty_lname, ptc_email, ptc_country, gift_frequency, post_dollaramount)>
        
        <cfif fradulent EQ 1>
            <cfset attemptCharge = 0>
        </cfif>
    
    <cfcatch type="any">
    	<cfset attemptCharge = 0>
    
    	<!--- ERROR Message ------------------------------------------------------ --->
    	<cfset eDetailMSG = {tDate = pty_date,
			cfcatch = cfcatch,
			CGIscope = CGI,
			tUUID = variables.newUUID,
			eP = 3,
			eML = 3}>
		<cfset eDetails = SerializeJSON(eDetailMSG)>
    	<cfset errorSend = sendERRmsg(eDetails)>
    
    </cfcatch>
    </cftry>
    
    
    <!--- ------------------- start of exact processing --------------------------- --->
    <!--- if we can attempt the charge --->
    <cfif attemptCharge EQ 1>
        
		<!--- trying to process on e-xact --->
        <cftry>
        
			<!--- BCCHF Exact Gobal Vars --->
            <cfinclude template="../includes/e-xact_include_var.cfm">
            
            <cfif post_card_number EQ 4111111111111111><!--- allow testing --->
            
                <!--- Testing Process ---><cfinclude template="../includes/testBlock.cfm"> 
                <!--- UUID used in test approvals --->
            
            <cfelse>
            
                <!--- Exact Method cfinvoke webservice ---> 
                <cfinclude template="../includes/e-xact_post_v60.1.cfm">
            
            </cfif> 
        
        
        <cfcatch type="any">
        
        <cfset rqst_transaction_approved = 0>
        <cfset rqst_exact_respCode = 0>
    	<cfset chargeAproved = 0>
        <cfset exact_respCode = 0>
        <cfset returnMSG = 'Charge Not Attempted - ERROR'>
        
        <!--- ERROR Message ------------------------------------------------------ --->
    	<cfset eDetailMSG = {tDate = pty_date,
			cfcatch = cfcatch,
			CGIscope = CGI,
			tUUID = variables.newUUID,
			eP = 1,
			eML = 4}>
		<cfset eDetails = SerializeJSON(eDetailMSG)>
    	<cfset errorSend = sendERRmsg(eDetails)>
        
        
        </cfcatch>
        </cftry>
        

        <!--- trying to record Recieved Record --->
        <!--- records form data and exact returned vars --->
        <cftry>
        
        	<!--- Update Attempt Record with E-Xact Charge Tokens --->
            <cfset eTransResult = {
				rqst_transaction_approved = rqst_transaction_approved,
				rqst_dollaramount = rqst_dollaramount,
				rqst_CTR = rqst_CTR,
				rqst_authorization_num = rqst_authorization_num,
				rqst_sequenceno = rqst_sequenceno,
				rqst_bank_message = rqst_bank_message,
				rqst_exact_message = rqst_exact_message,
				rqst_formpost_message = rqst_formpost_message,
				rqst_exact_respCode = rqst_exact_respCode,
				rqst_AVS = rqst_AVS
			}/>
            
            
            
            <cfset eXactRes = SerializeJSON(eTransResult)>
            
            <cfset eATPrec = recordExactAttempt(eXactRes, variables.newUUID)>
            
        
            <!--- <cfinclude template="../includes/1log_donation.cfm"> --->
        
        <cfcatch type="any">
        
        <!--- ERROR Message ------------------------------------------------------ --->
    	<cfset eDetailMSG = {tDate = pty_date,
			cfcatch = cfcatch,
			CGIscope = CGI,
			tUUID = variables.newUUID,
			eP = 3,
			eML = 5}>
		<cfset eDetails = SerializeJSON(eDetailMSG)>
    	<cfset errorSend = sendERRmsg(eDetails)>
        
        </cfcatch>
        </cftry>
    

    <cfelse>
    	<!--- charge not attempted - IP blocked --->
    
    	<cfset rqst_transaction_approved = 0>
        <cfset rqst_exact_respCode = 0>
        <cfset rqst_bank_message = 0>
    	<cfset chargeAproved = 0>
        <cfset exact_respCode = 0>
        <cfset returnMSG = 'Charge Not Attempted'>
    
    </cfif>
    <!--- -------------------- end of exact of processing  ---------------------- --->
    
    
    <!--- ---------------- start of database processing  -------------------------- --->
    <!--- NOT approved --->
    <cfif rqst_transaction_approved NEQ 1>
    
    	<!--- abort and return DECLINED message --->
    	<cfset chargeAproved = 0>
        <cfset exact_respCode = rqst_exact_respCode>
        <cfset returnMSG = 'charging-notapproved'>
        <cftry>
        <!--- check decline code 
		- for pick up card or malicious codes, block the IP --->
        <cfif rqst_bank_message EQ 'PICK UP CARD       * CALL BANK          =' 
			OR rqst_bank_message EQ 'HOLD CARD          * CALL               ='>
            <cfset recordIP = blockIP(newIP)>
        </cfif>
        
		<!--- track non approvals in IP Blocer Table ---->
		<!--- try to check IP against blacklist 
			-- if this IP has already made a failed attempt send to error page --->
        

		<cfset recordIP = recordIPaddress(newIP)>
		
        <!--- set ipBlocker token --->
        <cfif recordIP EQ 1>
        	<cfset ipBlocker = 1>
        <cfelse>
        	<cfset ipBlocker = 0>
        </cfif>
        
        <cfcatch type="any">
        
        <!--- ERROR Message ------------------------------------------------------ --->
    	<cfset eDetailMSG = {tDate = pty_date,
			cfcatch = cfcatch,
			CGIscope = CGI,
			tUUID = variables.newUUID,
			eP = 3,
			eML = 6}>
		<cfset eDetails = SerializeJSON(eDetailMSG)>
    	<cfset errorSend = sendERRmsg(eDetails)>
            
        </cfcatch>
        </cftry>
        
        
		<!--- ----------------- END of NOT APPROVED AREA -------------------------- --->
        <!----------------------------------- --------------------------------------> 
        
        
    <cfelse>
    <!--- charge approved --->
    
    	<cfset chargeAproved = 1>
        <cfset returnMSG = 'charging-approved'>
        
        <!--- try to remove IP from blocker trace --->
        <cftry>
        
        <cfset removeIP = removeIPaddress(newIP)>
        
        <cfcatch type="any">
        
        <!--- ERROR Message ---------------------------------------------------- --->
    	<cfset eDetailMSG = {tDate = pty_date,
			cfcatch = cfcatch,
			CGIscope = CGI,
			tUUID = variables.newUUID,
			eP = 3,
			eML = 7}>
		<cfset eDetails = SerializeJSON(eDetailMSG)>
    	<cfset errorSend = sendERRmsg(eDetails)>
        
        </cfcatch>
        </cftry>
        
        <!--- try and record the transaction details in a flat txt file --->
        <cftry>
        
			<!--- directories --->
            <cfset monthlyDumpDirectory = DateFormat(Now(), 'mm-yy')>
            <Cfset dailyDumpDirectory = DateFormat(Now(), 'DD')>
            
            <cfset dumpDirectory = "#APPLICATION.WEBLINKS.File.service#\transactions\#monthlyDumpDirectory#\#dailyDumpDirectory#\">
            
            <!--- check if directory exists --->
            <cfif DirectoryExists(dumpDirectory)>
                <!--- directory exists - we are all good --->
            <cfelse>
                <!--- need to create directory --->
                <cfdirectory directory="#dumpDirectory#" action="create">
                        
            </cfif>
            
            <!--- add timestamp to file --->
            <Cfset append = "#DateFormat(Now())#---#TimeFormat(Now(), 'HH-mm-ss.l')#">
            
            <!--- dump form to file --->
            <!--- hide PCI fields --->
            <cfdump var="#form#" output="#dumpDirectory#bcchildren_full_donation_dump_date-#append#.txt" hide="POST_CARD_NUMBER,POST_CVV,FIELDNAMES,POST_DOLLARAMOUNT,js_bcchf_cardnumber,js_bcchf_cvv,bcchf_cvv,bcchf_cc_number" type="html">
        
    	<cfcatch type="any">
        
        <!--- ERROR Message ---------------------------------------------------- --->
    	<cfset eDetailMSG = {tDate = pty_date,
			cfcatch = cfcatch,
			CGIscope = CGI,
			tUUID = variables.newUUID,
			eP = 3,
			eML = 8}>
		<cfset eDetails = SerializeJSON(eDetailMSG)>
    	<cfset errorSend = sendERRmsg(eDetails)>
        
        </cfcatch>
        </cftry>
        
        
        <!--- Parse exact rqst_CTR for exact time --->
        <cftry>
			<cfset DTindex = REFIND("DATE/TIME", rqst_CTR) + 14>
            <cfset DT = Mid(rqst_CTR, DTindex, 18)>
            <cfset exact_odbcDT = CreateODBCDateTime(DT)>
        <cfcatch type="any">
			<cfset exact_odbcDT = pty_Date>
        </cfcatch>
        </cftry>
        
        <!--- Try to Insert Successful Record Into Database --->
        <cftry>
        
        <!--- encrypt card data --->
        <cfset encrptedCardData = encrptCard(post_card_number, hiddenDonationType)>
        
        <!--- Successful Record Struct --->
        <cfset tSuccessRecord = {
			tUUID = variables.newUUID,
			tDollar = post_dollaramount,
			tAdv = giftAdvantage,
			tTax = giftTaxable,
			tRType = receipt_type,
			tSource = donation_source,
			eSource = ePhilSRC,
			tENC = encrptedCardData,
			tCard = {
				cName = post_cardholdersname,
				eXm = post_expiry_month,
				eXy = post_expiry_year
			},
			tDonor = {
				dTitle = pty_title,
				dFname = pty_fname,
				dMname = pty_miname,
				dLname = pty_lname,
				dCname = pty_companyname,
				dTaxTitle = pty_tax_title,
				dTaxFname = pty_tax_fname,
				dTaxMname = pty_miname,
				dTaxLname = pty_tax_lname,
				dTaxCname = pty_tax_companyname,
				dAddress = {
					aOne = ptc_address,
					aTwo = ptc_addTwo,
					aCity = ptc_city,
					aProv = ptc_prov,
					aPost = ptc_post,
					aCountry = ptc_country
				},
				dEmail = ptc_email,
				dPhone = ptc_phone
			},
			tType = gift_type,
			tFreq = gift_frequency,
			tNotes = gift_notes,
			tTType = pty_tax,
			tFreqDay = gift_day,
			tSHP = {
				tAdd = 1,
				tToken = hiddenEventToken,
				tCampaign = hiddenEventCurrentYear,
				tTeamID = hiddenTeamID,
				tSupID = hiddenSupID,
				tDname = DName,
				tStype = hiddentype,
				tSmsg = Message,
				tSshow = Show
			}
			
		} />
        
        <cfset tSRec = SerializeJSON(tSuccessRecord)>
        
        <cfset tSSUCrec = recordSuccAttempt(tSRec, variables.newUUID)>
        
        
        <!--- DEPRECIATE: bcchf_bcchildren -- transaction data in tblDonation --->
        <CFQUERY datasource="#APPLICATION.DSN.transaction#" name="insert_record" dbtype="ODBC">
        INSERT INTO tblDonation (dtnDate, exact_date, dtnAmt, dtnBenefit, dtnReceiptAmt, dtnReceiptType, dtnBatch, dtnSource, post_cardholdersname, post_card_number, post_expiry_month, post_expiry_year, post_card_type, DEK_ID, post_ExactID, rqst_transaction_approved, rqst_authorization_num, rqst_dollaramount, rqst_CTR, rqst_sequenceno, rqst_bank_message, rqst_exact_message, rqst_formpost_message, rqst_AVS, pge_UUID, dtnIP, dtnBrowser) 
        VALUES (#pty_Date#, #exact_odbcDT#, '#post_dollaramount#', '#giftAdvantage#', '#giftTaxable#', '#receipt_type#', 'Online', '#donation_source#', '#post_cardholdersname#', '#encrptedCardData.ENCDATA#', '#post_expiry_month#', '#post_expiry_year#', '#encrptedCardData.ENCTYPE#', #encrptedCardData.ENCDEKID#, 'A00063-01', '#rqst_transaction_approved#', '#rqst_authorization_num#', '#rqst_dollaramount#', '#rqst_CTR#', '#rqst_sequenceno#', '#rqst_bank_message#', '#rqst_exact_message#', '#rqst_formpost_message#', '#rqst_AVS#', '#variables.newUUID#', '#newIP#', '#newBrowser#') 
        </CFQUERY>
        
        <!--- we want the ID from tblDonation for the tax receipt --->
        <cfquery name="selectID" datasource="#APPLICATION.DSN.transaction#">
        SELECT dtnID FROM tblDonation WHERE pge_UUID = '#variables.newUUID#'
        </cfquery>
        
        <!--- set receipt number --->
		<cfset receiptNumber = selectID.dtnID + 1100000>
        
        <!--- DEPRECIATE: bcchf_donationGeneral -- donor data in tblGeneral --->
        <CFQUERY datasource="#APPLICATION.DSN.general#" name="insert_record">
        INSERT INTO tblGeneral (pty_date, exact_date, pty_title, pty_fname, pty_miname, pty_lname, pty_companyname, ptc_address, ptc_add_two, ptc_city, ptc_prov, ptc_post, ptc_country, ptc_email, ptc_phone, pty_tax_title, pty_tax_fname, pty_tax_lname, pty_tax_companyname, gift, gift_Advantage, gift_Eligible, gift_type, gift_frequency, gift_notes, rqst_authorization_num, pty_tax, POST_REFERENCE_NO, rqst_sequenceno, gift_day, JD_Pin, JD_Button, pge_UUID, receipt_type) 
        VALUES (#pty_date#, #exact_odbcDT#, '#pty_title#', '#pty_fname#', '#pty_miname#', '#pty_lname#',  '#pty_companyname#', '#ptc_address#', '#ptc_addTwo#', '#ptc_city#', '#ptc_prov#', '#ptc_post#', '#ptc_country#', '#ptc_email#', '#ptc_phone#', '#pty_tax_title#', '#pty_tax_fname#', '#pty_tax_lname#', '#pty_tax_companyname#', '#post_dollaramount#', '#giftAdvantage#', '#giftTaxable#', '#gift_type#', '#gift_frequency#', '#gift_notes#', '#rqst_authorization_num#', '#pty_tax#', '#rqst_sequenceno#', '#rqst_sequenceno#', '#gift_day#', '0',  '0', '#variables.newUUID#', '#ePhilSRC#')
        </CFQUERY>
        
        <!--- /// DEPRICATE --->
        
        <!--- if the try block fails --->
        <!--- send email with details to isbcchf --- log transaction --->
        <cfcatch type="any">
        
        	<!--- ERROR Message ---------------------------------------------------- --->
			<cfset eDetailMSG = {tDate = pty_date,
                cfcatch = cfcatch,
                CGIscope = CGI,
                tUUID = variables.newUUID,
                eP = 2,
                eML = 9}>
            <cfset eDetails = SerializeJSON(eDetailMSG)>
            <cfset errorSend = sendERRmsg(eDetails)>
        
        </cfcatch>
        </cftry>
                
        <!--- try and update the rest of the transaction details --->
        <!--- Additional Information --->
        <cftry>
        
        	<!--- check URL for email referal --->
            <cfif IsDefined('emailReferal') AND emailReferal NEQ ''>
                <cfset eRefUpdate = checkEmailReff(emailReferal, variables.newUUID)>
            </cfif>
                    
            <cfset adInfo = {
				SOC_subscribe = SOC_subscribe,
				news_subscribe = news_subscribe,
				AR_subscribe = AR_subscribe,
				gPledgeDet = gift_pledge_det
				
			} />
            
            <cfset addInfo = SerializeJSON(adInfo)>
            
            <cfset tSSUCadd = recordSuccAdd(addInfo, variables.newUUID)>
            
            <cfif hiddenTeamID EQ ''>
            	<cfset hiddenTeamID = 0>
            </cfif>
            
            <cfif hiddenSupID EQ ''>
            	<cfset hiddenSupID = 0>
            </cfif>
            
            
            <!--- DEPRECIATE: addadditional information section --->
            <cfquery name="updateAddInfo" datasource="#APPLICATION.DSN.general#">
            UPDATE tblGeneral
            SET	TeamID = #hiddenTeamID#,
                SupID = #hiddenSupID#,
                ptc_subscribe = '#news_subscribe#',
				SOC_subscribe = '#SOC_subscribe#', 
				AR_subscribe = '#AR_subscribe#', 
                gift_pledge_det = '#gift_pledge_det#'
            WHERE pge_UUID = '#variables.newUUID#'
            </cfquery>
            
			<!--- update donation general with pledge info --->
            <cfif gPledge EQ 'Yes'>
            
                <cfset plInfo = {
                    pledge = 'yes',
                    pDetail = gift_pledge_det,
                    pDREID = gift_pledge_DonorID
                }/ >
                
                <cfset plInfoJSON = SerializeJSON(plInfo)>
                
                <cfset tSSUCpl = recordSuccPledge(plInfoJSON, variables.newUUID)>        
            
                <!--- update tblGeneral with tribute data --->
                <cfquery name="updatePledgeData" datasource="#APPLICATION.DSN.general#">
                UPDATE tblGeneral
                SET	ConstitID = '#gift_pledge_DonorID#',
                gift_pledge = 'yes'
                WHERE pge_UUID = '#variables.newUUID#'
                </cfquery>
            
            
            </cfif>
            
            <!--- update donation general with tribute info --->
            <cfif hiddenTributeType EQ 'honour' OR hiddenTributeType EQ 'memory'>
            
                <cfset tribInfo = {
                    trbFname = trb_fname,
                    trbLname = trb_lname,
                    tribNotes = hiddenTributeType,
                    cardSend = hiddenAWKtype
                    
                } />
                
                <cfset tribInfoJSON = SerializeJSON(tribInfo)>
                
                <!--- <cfset tSSUCtrib = recordSuccTrib(tribInfoJSON, variables.newUUID)> --->
            
                <!--- update tblGeneral with tribute data --->
                <cfquery name="updateTributeData" datasource="#APPLICATION.DSN.general#">
                UPDATE tblGeneral
                SET	gift_tribute = 'yes',
                    trb_fname = '#trb_fname#',
                    trb_lname = '#trb_lname#', 
                    trib_notes = '#hiddenTributeType#',
                    card_send = '#hiddenAWKtype#'
                WHERE pge_UUID = '#variables.newUUID#'
                </cfquery>
            
            
            </cfif>
        
        <!--- --->
        <cfcatch type="any">
        
        	<!--- ERROR Message ---------------------------------------------------- --->
			<cfset eDetailMSG = {tDate = pty_date,
                cfcatch = cfcatch,
                CGIscope = CGI,
                tUUID = variables.newUUID,
                eP = 3,
                eML = 10}>
            <cfset eDetails = SerializeJSON(eDetailMSG)>
            <cfset errorSend = sendERRmsg(eDetails)>
        
        </cfcatch>
        </cftry>
                
        
                
        <!--- ------------------- end of database processing ----------------------- --->
        <!--- ------------------- confirmation email process ----------------------- --->
        <cftry>
        
        <!---- TO FOUNDATION IN ALL CASES 
			DONOR EMAILS FIRE FROM CONFIRMATION SCREEN --->
        <cfset FDNnotifyEmail = FDNnotifyEmail(variables.newUUID)>
       
		<cfcatch type="any">
        
        	<!--- ERROR Message ---------------------------------------------------- --->
			<cfset eDetailMSG = {tDate = pty_date,
                cfcatch = cfcatch,
                CGIscope = CGI,
                tUUID = variables.newUUID,
                eP = 3,
                eML = 11}>
            <cfset eDetails = SerializeJSON(eDetailMSG)>
            <cfset errorSend = sendERRmsg(eDetails)>
        	
            
        </cfcatch>
        </cftry>	
			
		<!--- ------------------- end of email processing ------------------------- --->

        <!--- send return message to browser window that the transaction is complete --->
        
        <!--- message about frequency  --->
        <cfset chargeMSG = gift_frequency>
        <!--- after inserting in DB and sending emails --->
        <cfset returnSuccess = 1>
        
    </cfif>
    <!--- ---------------------- end of if charging approved  ---------------------- --->
    

    <!--- return message --->
    <cfset ChargeAttmpt = {
		cAttempted = chargeAttempt,
		cApproved = chargeAproved,
		cMSG = chargeMSG,
		exact_respCode = exact_respCode,
		ipBlocker = ipBlocker,
		goodXDS = goodXDS
		} />

	<!--- this is the structure of the return message --->
    <cfset SHPdonationReturnMSG = {
	Success = returnSuccess,
	ChargeAttmpt = ChargeAttmpt,
	Message = returnMSG,
	EventToken = hiddenEventToken,
	UUID = variables.newUUID,
	tGenTwoID = tGenTwoID
	} />
    
    <cfreturn SHPdonationReturnMSG>

</cffunction>





<cffunction name="submitNewDonationFormPayPal" access="remote" returnformat="json" >

	<cfargument name="bcchf_donor_first_name" type="string" required="no">
    <cfargument name="bcchf_donor_last_name" type="string" required="no">
    
    
    <!--- SET form DEFAULTS --->
    <!--- BCCHF sandbox 
	<cfset ClientID = 'AU7JuxDyWHnqy5vngOapa6_ndHU-0NfJP37DZtG-x6E_KPjH9KiKetcSb9AY'>
    <cfset clientPass = 'EGSdMhC9MagPgmY8QwOs_yzMFZ69QSNb4Y4ytGqv0HE0SB-QqOl9C7rTdCmJ'>
            
    <cfset apiendPoint = 'http://api.sandbox.paypal.com/'>
    <cfset secureBCCHF = 'http://208.73.58.70/'>--->
    
    <!--- BCCLF LIVE --->
	<cfset ClientID = 'AUQ0kRD4EXX6hhe3nQ4Uu78Q18Ea2F2_hHTAL5LsrHgIRvk1xtYvsq-TvH8p'>
    <cfset clientPass = 'ENnkbRA4zr4vQ84FJvB1WV-vV8CgAL-BpiF22pejC_m6C2AMudlH5RvbrtsD'>
        
    <cfset apiendPoint = 'https://api.paypal.com/'>
    <cfset secureBCCHF = 'https://secure.bcchf.ca/'>
	
    <!--- SERVER Date at submission --->
	<cfif NOT IsDefined("pty_date")><cfset pty_date= "#Now()#"></cfif>
    
    <!--- create UUID to access info --->
    <cfset variables.newUUID=createUUID()>
    
    <!--- collect IP address of remote requestor --->
    <cfset newIP = CGI.REMOTE_ADDR>
    <cfset newBrowser = CGI.HTTP_USER_AGENT>
    <cfset ipBlocker = 0>
    
    <!--- return variables
		SET to 0  --->
    <cfset chargeSuccess = 0>
    <cfset donationSuccess = 0>
    <cfset chargeAttempt = 0>
    <cfset chargeAproved = 0>
    <cfset chargeMSG = "">
    <cfset tGenTwoID = 0>
    
    <!--- construct initial return message --->
    <cfset returnSuccess = 0>
    <cfset returnMSG = 'beginAttempt'>
    <cfset exact_respCode = 0>
    
    <!--- set source --->
    <cfset donation_source = 'New 2015 Donation Form'>
    <cfset pty_tax_issuer = 'BCCHF'>

    
    <!--- scrub some variables for db loading --->
    <cftry>
    	
        <!--- Personal or Corporate - set tax values with this info --->
        <cfset hiddenDonationPCType = hiddenDonationPCType>
    
		<!--- donor information --->
        <cfset pty_title = bcchf_salutation>
        <cfset pty_fname = TRIM(bcchf_first_name)>
        <cfset pty_MIname = TRIM(bcchf_middle_initial)>
        <cfset pty_lname = TRIM(bcchf_last_name)>
        
        <cfset pty_tax_title = bcchf_salutation>
        <cfset pty_tax_fname = TRIM(bcchf_first_name)>
        <cfset pty_tax_MIname = TRIM(bcchf_middle_initial)>
        <cfset pty_tax_lname = TRIM(bcchf_last_name)>
        
        <cfset pty_companyname = TRIM(bcchf_company_name)>
        <cfset pty_tax_companyname = TRIM(bcchf_company_name)>
        
        <cfset ptc_address = TRIM(bcchf_address)>
        <cfset ptc_addTwo = TRIM(bcchf_address2)>
        <cfset ptc_city = TRIM(bcchf_city)>
        <cfset ptc_country = TRIM(bcchf_country)>
        <cfset ptc_prov = TRIM(bcchf_province)>
        <cfset ptc_post = TRIM(bcchf_postal_code)>
        <cfset ptc_email = TRIM(bcchf_email)>
        <cfset ptc_phone = TRIM(bcchf_phone)>
        
        <!--- ESubscribe options ---->
        <cfif IsDefined('bcchf_allow_contact')>
            <cfset pty_subscr_r = bcchf_allow_contact>
            <cfset SOC_subscribe = 1>
            <cfset news_subscribe = 1>
            <cfset AR_subscribe = 1>
        <cfelse>
            <cfset pty_subscr_r = 0>
            <cfset SOC_subscribe = 0>
            <cfset news_subscribe = 0>
            <cfset AR_subscribe = 0>
        </cfif>
              
        <!--- SHP event scroll details --->
        <cfset hiddenEventToken = hiddenEventToken>
        <cfset hiddenEventCurrentYear = hiddenEventCurrentYear>
        <cfset hiddenTeamID = hiddenTeamID>
        <cfset hiddenSupID = hiddenSupID>
        <cfset hiddentype = hiddentype>
        <cfset Message = bcchf_encouragement_msg>
        
        <cfif IsDefined('bcchf_hide_message')>
			<cfset Show = 0>
        <cfelse>
        	<cfset Show = 1>
        </cfif>
        
        <!--- Personal Corporate Donation --->
        <cfif hiddenDonationPCType EQ 'corporate'>
        	<cfset DName = '#TRIM(bcchf_donor_company_name)#'>
            <!--- corporate donation 
			 --- EMPTY the personal tax fields--->
            <cfset pty_tax_title = "">
            <cfset pty_tax_fname = "">
            <cfset pty_tax_lname = "">
        <cfelse>
        	<cfset DName = '#TRIM(bcchf_donor_first_name)# #TRIM(bcchf_donor_last_name)#'>
            <!--- personal donation 
				EMPTY the corporate donation fields --->
            <cfset pty_tax_companyname = "">
        </cfif>        
        
        <cfif IsDefined('bcchf_hide_name')>
        	<cfset ShowAnonymous = 1>
            <cfset DName = 'Anonymous'>
        <cfelse>
        	<cfset ShowAnonymous = 0>
        </cfif>
        
        <!--- set gift type --->
        <cfset gift_type = hiddenGiftType>
        <cfset gift_notes = bcchf_special_instr>
        
        <!--- set gift amount --->
        <cfif bcchf_gift_amount EQ ''>
            <cfset hiddenGiftAmount = bcchf_other_amt>
        <cfelse>
            <cfset hiddenGiftAmount = bcchf_gift_amount>
        </cfif>
        
        <cfset hiddenGiftAmount = REREPlace(hiddenGiftAmount, '[^0-9.]','','all')>
        <cfset post_dollaramount = hiddenGiftAmount>
        <cfset Hero_Donate_Amount = post_dollaramount>
        
        <cfset giftAdvantage = 0>
        <cfset giftTaxable = post_dollaramount>
        
        <!--- gift frequency --->
        <cfset hiddenDonationType = bcchf_donation_type>
        <cfset donation_type = bcchf_donation_type>
        <cfset hiddenFreqDay = bcchf_donation_on>
        
        <!--- determine gift frequency Day --->
		<cfif hiddenDonationType EQ 'monthly'>
            
			<cfset GiftFreqM = 1>
			<cfset gift_frequency = 'Monthly'>

            
			<cfif IsDefined('hiddenFreqDay')>
                <cfset gift_day = hiddenFreqDay>
            <cfelse>
                <cfset gift_day = 1>
            </cfif>
            
        <cfelse>
        
        	<cfset GiftFreqM = 0>
        	<cfset gift_frequency = 'Single'>
            <cfset gift_day = "">
            
        </cfif>
        
        <!--- tribute type --->
        <!--- eCard for eCards - Pledge for Pledge --->
        <cfset hiddenTributeType = bcchf_donation_honour>
        <cfset gift_TributeType = bcchf_donation_honour>
        
        <!--- tax receipt information --->
        <cfset pty_tax = bcchf_receipt>
        <!--- DEFAULT Ink Friendly --->
        <cfset pty_ink = 'Yes'>
        
        <!--- cardholder data --->
        <cfset post_card_number = bcchf_cc_number>
        <cfset post_expiry_month = bcchf_expire_month>
        <!--- ensure expiry date length --->
        <cfif Len(post_expiry_month) EQ 1>
            <cfset post_expiry_month = "0#post_expiry_month#">
        </cfif>
        <cfset post_expiry_year = bcchf_expire_year>
        <cfset post_expiry_date = '#post_expiry_month##post_expiry_year#'>
        <cfset post_cardholdersname = bcchf_cc_name>
        <cfset post_CVV = bcchf_cvv>
        
        <cfif Left(post_card_number, 1) EQ 3>
            <cfset post_card_type = 'AMEX'>
        <cfelseif Left(post_card_number, 1) EQ 4>
            <cfset post_card_type = 'VISA'>
        <cfelseif Left(post_card_number, 1) EQ 5>
            <cfset post_card_type = 'MC'>
        <cfelseif Left(post_card_number, 1) EQ 6>
            <cfset post_card_type = 'DISCOVER'>
        <cfelse>
            <cfset post_card_type = 'Invalid'>
        </cfif>
        
        <!--- email referal conditions --->
        <cfset emailReferal = ''>
        
        <!--- tribute information --->
        <cfif hiddenTributeType EQ 'honour'>
            <cfset trb_fname = ''>
            <cfset trb_lname = bcchf_in_honour_name>
            <cfset gTribute = 'Yes'>
        <cfelseif hiddenTributeType EQ 'memory'>
            <cfset trb_fname = ''>
            <cfset trb_lname = bcchf_in_memory_name>
            <cfset gTribute = 'Yes'>
        <cfelse>
            <cfset trb_fname = ''>
            <cfset trb_lname = ''>
            <cfset gTribute = 'No'>
        </cfif>
        <cfset cleanTrbMessage =''>
        
        <!--- Tribute AWK indicator token --->
        <cfif IsDefined('bcchf_acknowledgement')>
            <cfset hiddenAWKtype = 'ask'>
        <cfelse>
            <cfset hiddenAWKtype = ''>
        </cfif>
        
        <!--- read ePhil Source --->
        <cfif IsDefined('ePhilanthropySource')>
            <cfset ePhilSRC = ePhilanthropySource>
        <cfelse>
            <cfset ePhilSRC = ''>
        </cfif>
        
        <!--- pledge details --->
        <cfif hiddenTributeType EQ 'pledge'>
		
			<cfset gift_pledge_DonorID = bcchf_donor_id>
            <cfset gift_pledge_det = gift_pledge_DonorID>
            <cfset gPledge = 'Yes'>
        
        <cfelse>
        
            <cfset gift_pledge_DonorID =''>
            <cfset gift_pledge_det = ''>
            <cfset gPledge = 'No'>
        
        </cfif>
        
    	<!--- TAX receipt options for processor ---->
        <!--- receipt types
			TAX = TAX RECEIPT
			AWK = AWKNOWLEDGMENT RECEIPT
			TAX-IF = Ink Friendly
			TAX-ANNUAL = Annual Receipt for monthly gift
			NONE = None requested / ineligible
			--->
		<cfif GiftFreqM EQ 1>
        
        	<!--- Monthly Receipt --->
            <cfif pty_tax EQ "no">
                <cfset receipt_type = 'NONE'>
            <cfelse>
                <cfset receipt_type = 'TAX-ANNUAL'>
            </cfif>  
            
        <cfelse>
        
        	<cfif pty_tax EQ "no">
                <cfset receipt_type = 'NONE'>
            <cfelse>
    			<cfset receipt_type = 'TAX-IF'>
            </cfif>
             
        </cfif>
        
    
    	<!--- legacy: receipt generator method
			- check for receipt status 
			- append 'no receipt' to frequency for no receipt--->
        <cfif pty_tax EQ "no">
			<cfset gift_frequency="#hiddenDonationType# - No Receipt">
        <cfelse>
        	<cfset gift_frequency="#hiddenDonationType#">
        </cfif>
        
        
        
    <cfcatch type="any">
    	<!--- ERROR Message ---------------------------------------------------- --->
    	<cfset eDetailMSG = {tDate = pty_date,
			cfcatch = cfcatch,
			CGIscope = CGI,
			tUUID = variables.newUUID,
			eP = 2,
			eML = 1}>
		<cfset eDetails = SerializeJSON(eDetailMSG)>
    	<cfset errorSend = sendERRmsg(eDetails)>
    
    </cfcatch>
    </cftry>
    
    
    
    <!--- attempt charge --->
	<cfset chargeAttempt = 1>
    <cfset attemptCharge = 1>
    <cfset returnMSG = 'beginAttempt-charging'>
    
    
	<!--- Trying to record Attempt Record --->
    <cftry>
    
    	<cfset tAttemptRecord = {tDate = pty_date, 
						tUUID = variables.newUUID,
						tDonor = {
							dTitle = pty_title,
							dFname = pty_fname,
							dMname = pty_miname,
							dLname = pty_lname,
							dCname = pty_companyname,
							dTaxTitle = pty_tax_title,
							dTaxFname = pty_tax_fname,
							dTaxMname = pty_miname,
							dTaxLname = pty_tax_lname,
							dTaxCname = pty_tax_companyname,
							dAddress = {
								aOne = ptc_address,
								aTwo = ptc_addTwo,
								aCity = ptc_city,
								aProv = ptc_prov,
								aPost = ptc_post,
								aCountry = ptc_country
							},
							dEmail = ptc_email,
							dPhone = ptc_phone
						},
						tGift = post_dollaramount,
						tGiftAdv = 0,
						tGiftTax = post_dollaramount,
						tType = gift_type,
						tFreq = gift_frequency,
						tNotes = gift_notes,
						tSource = donation_source,
						eSource = ePhilSRC,
						tBrowser = {
							bUAgent = newBrowser,
							bName = uabrowsername,
							bMajor = uabrowsermajor,
							bVer = uabrowserversion,
							bOSname = uaosname,
							bOSver = uaosversion,
							dDevice = uadevicename,
							bDtype = uadevicetype,
							bDvend = uadevicevendor,
							bIP = newIP
						},
						tTType = pty_tax,
						tFreqDay = gift_day,
						tSHP = {
							tAdd = 1,
							tToken = hiddenEventToken,
							tCampaign = hiddenEventCurrentYear,
							tTeamID = hiddenTeamID,
							tSupID = hiddenSupID,
							tDname = DName,
							tStype = hiddentype,
							tSmsg = Message,
							tSshow = Show,
							Hero_Donate_Amount = Hero_Donate_Amount
						},
						tFORM = {
							hiddenDonationPCType = hiddenDonationPCType,
							hiddenDonationType = hiddenDonationType,
							hiddenFreqDay = hiddenFreqDay,
							hiddenGiftAmount = hiddenGiftAmount,
							donation_type = donation_type,
							gift_frequency = gift_frequency,
							gift_day = gift_day,
							hiddenTributeType = hiddenTributeType,
							gift_tributeType = gift_tributeType
							
						},
						adInfo = {
							SOC_subscribe = SOC_subscribe,
							news_subscribe = news_subscribe,
							AR_subscribe = AR_subscribe,
							gPledgeDet = gift_pledge_det,
							gPledgeDREID = gift_pledge_DonorID,
							gPledge = gPledge
						},
						tribInfo = {
							trbFname = trb_fname,
							trbLname = trb_lname,
							cardSend = hiddenAWKtype,
							tribNotes = hiddenTributeType,
							gTribute = gTribute
						}
			} />
            
            <cfset tAttempt = SerializeJSON(tAttemptRecord)>
    	
    		<cfset tATPrec = recordTransAttempt(tAttempt)>
    
    	<!---- <cfinclude template="../includes/0log_donation.cfm"> --->
    
    <cfcatch type="any">
    
    	<!--- ERROR Message ------------------------------------------------------ --->
    	<cfset eDetailMSG = {tDate = pty_date,
			cfcatch = cfcatch,
			CGIscope = CGI,
			tUUID = variables.newUUID,
			eP = 3,
			eML = 2}>
		<cfset eDetails = SerializeJSON(eDetailMSG)>
    	<cfset errorSend = sendERRmsg(eDetails)>
    
    </cfcatch>
    </cftry>
    
    <!--- try fraudster intercept:
		check for XDS
		check IP on blackList
		check fraudster MO --->
    <cftry>
    
    	<!--- XDS --->
		<cfset goodXDS = checkXDS(APPLICATION.AppVerifyXDS, FORM.App_verifyToken, CGI.HTTP_REFERER)>
        
        <cfif goodXDS EQ 0>
            <cfset attemptCharge = 0>
        </cfif>
    
		<!--- check IP against blacklist --->
        <cfset goodIP = checkIPaddress(newIP)>
        
        <cfif goodIP EQ 0>
            <cfset attemptCharge = 0>
        </cfif>
    
		<!--- check Fraudster MO --->
        <cfset fradulent = checkFraudsterMO(pty_tax_fname, pty_tax_lname, pty_fname, pty_lname, ptc_email, ptc_country, gift_frequency, post_dollaramount)>
        
        <cfif fradulent EQ 1>
            <cfset attemptCharge = 0>
        </cfif>
    
    <cfcatch type="any">
    	<cfset attemptCharge = 0>
    
    	<!--- ERROR Message ------------------------------------------------------ --->
    	<cfset eDetailMSG = {tDate = pty_date,
			cfcatch = cfcatch,
			CGIscope = CGI,
			tUUID = variables.newUUID,
			eP = 3,
			eML = 3}>
		<cfset eDetails = SerializeJSON(eDetailMSG)>
    	<cfset errorSend = sendERRmsg(eDetails)>
    
    </cfcatch>
    </cftry>
    
    
    <!--- if we can attempt to post to PayPal --->
    <cfif attemptCharge EQ 1>
    
		<!--- trying to post to PayPal--->
        <cftry>
        
        <!--- a monthly transaction requires a billing pland and subsequent approval of the billing agreement.
		one time gift requires a regular 'payment'
		--->
		
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

		<!--- 
 		<cfmail to="csweeting@bcchf.ca" from="paypal@bcchf.ca" subject="PayPalConnection Est." type="html">
            PayPal Login Detail
            <cfdump var="#result#" label="catch">
        </cfmail>
		--->
                
		<cfif result.responseheader.status_code EQ 200>
 
			<cfset SHPevent = DeserializeJSON(toString( result.fileContent ))>
        
            <!--- auth token --->
            <cfset requestToken='#SHPevent.token_type# #SHPevent.access_token#'>
            
            <!--- Set PayPal Structure for API call --->
            <cfset payDetail["intent"] = "sale">
			<cfset payDetail["payer"] = {}>
            <cfset payDetail.payer["payment_method"] = 'paypal' />
            <cfset payDetail["transactions"] = ArrayNew(1)>
            <cfset payDetail.transactions[1]["amount"] = {}>
            <cfset payDetail.transactions[1].amount["currency"] = 'CAD'>
            <cfset payDetail.transactions[1].amount["total"] = post_dollaramount>
            <cfset payDetail.transactions[1]["description"] = '#DollarFormat(post_dollaramount)# #gift_type# Donation'>
            <cfset payDetail.transactions[1]["invoice_number"] = variables.newUUID>
            <cfset payDetail.transactions[1]["soft_descriptor"] = "BCCHF">
            <cfset payDetail["redirect_urls"] = {}>
            
            <cfif gift_type EQ 'HolidaySnowball'>
            	<cfset payDetail.redirect_urls["cancel_url"] = '#secureBCCHF#/donate/donation-Snowball.cfm?DtnID=#variables.newUUID#&Event=#gift_type#&Donation=Gen&SHP=yes&#CGI.QUERY_STRING#'>
                <cfset payDetail.redirect_urls["return_url"] = '#secureBCCHF#/donate/completeDonation-Snowball-PayPal.cfm?Event=#gift_type#&SHP=yes&UUID=#variables.newUUID#'>
            <cfelse>
				<cfset payDetail.redirect_urls["cancel_url"] = '#secureBCCHF#/donate/donation-New.cfm?DtnID=#variables.newUUID#&#CGI.QUERY_STRING#'>
                <cfset payDetail.redirect_urls["return_url"] = '#secureBCCHF#/donate/completeDonation-New-PayPal.cfm?Event=#gift_type#&UUID=#variables.newUUID#'>
            </cfif>
            
            <!--- Call PayPal API --->
            <cfhttp 
            result="result"
            method="post"
            url="#apiendPoint#v1/payments/payment" 
            >
                <cfhttpparam type="header" name="Content-Type" value="application/json" />
                <cfhttpparam type="header" name="Authorization" value="#requestToken#" />
                <cfhttpparam type="body" value="#serializeJSON(payDetail)#">
            </cfhttp>
            
            <!--- 
            <cfmail to="csweeting@bcchf.ca" from="paypal@bcchf.ca" subject="PayPalConnection Est." type="html">
            PayPal Setup Detail
            <cfdump var="#result#" label="catch">
        	</cfmail>
			--->
            
            

 			<!--- check result header for 201 status code --->
			<cfif result.responseheader.status_code EQ 201>
 				
                <!--- payment has been 'created' on PayPal --->
                <!--- parse response --->
				<cfset SHPevent = DeserializeJSON(toString( result.fileContent ))>
    
				<cfset i = 0>
    			<cfset rdrLinkFnd = 0>
    			
    			
                <!--- check for execution link --->
    			<cfloop condition = "rdrLinkFnd EQUALS 0">
    				<cfset i = i + 1>
    
					<cfif StructKeyExists(SHPevent.links[i], 'method') 
                        AND SHPevent.links[i].method EQ 'REDIRECT'>
                        <cfset rdrLinkFnd = 1>
                        <cfset rdrLnk = SHPevent.links[i].href>
                    </cfif>
                    
				</cfloop>
                
                <!---- OK to proceed with PayPal Payment ID --->
				<cfset rqst_transaction_approved = 1>
				<cfset payPalPaymentID = SHPevent.id>

    
			<cfelse>
                
                <!--- non 201 code response - indicate error --->
                <cfset rqst_exact_respCode = '#result.responseheader.status_code# Error Connectiong to PayPal.'>
                
                <cfmail to="csweeting@bcchf.ca" from="paypal@bcchf.ca" subject="payPal Response error result" type="html">
                Response other than 201 when creating transaction
                <cfdump var="#result#" label="catch">
                </cfmail>

			</cfif>
    
    	<cfelse>
        
        	<!--- PayPal login failure --->
			<cfset rqst_transaction_approved = 0>
            <cfset rqst_exact_respCode = 'Error Connectiong to PayPal.'>
            
            <cfmail to="csweeting@bcchf.ca" from="paypal@bcchf.ca" subject="payPal Login error result" type="html">
            Login Failure
            <cfdump var="#result#" label="catch">
            </cfmail>
        
        </cfif>


        <cfcatch type="any">
        <!--- ERROR Message ---------------------------------------------------- --->
    	<cfset eDetailMSG = {tDate = pty_date,
			cfcatch = cfcatch,
			CGIscope = CGI,
			tUUID = variables.newUUID,
			eP = 1,
			eML = 12}>
		<cfset eDetails = SerializeJSON(eDetailMSG)>
    	<cfset errorSend = sendERRmsg(eDetails)>
        
        <cfset rqst_transaction_approved = 0>
        <cfset rqst_exact_respCode = 0>
    	<cfset chargeAproved = 0>
        <cfset exact_respCode = 0>
        <cfset returnMSG = 'Charge Not Attempted'>
        
        </cfcatch>
        </cftry>
    

    <cfelse>
    	<!--- charge not attempted - IP blocked --->
    
    	<cfset rqst_transaction_approved = 0>
        <cfset rqst_exact_respCode = 0>
    	<cfset chargeAproved = 0>
        <cfset exact_respCode = 0>
        <cfset returnMSG = 'Charge Not Attempted'>
    
    </cfif>
    
    
    <!--- NOT recorded in PayPal --->
    <cfif rqst_transaction_approved NEQ 1>
    
    	<!--- abort and show messages --->
    	<cfset chargeAproved = 0>
        <cfset exact_respCode = rqst_exact_respCode>
        <cfset returnMSG = 'charging-notapproved'>
        
		<!--- END of NOT RECORDED AREA --->        
        <!----------------------------------- --------------------------------------> 
        <!--- will return paypal message for display to the user ---->   
        
        
        
    <cfelse>
    <!--- transaction created in PayPal --->
    
    	<cfset chargeAproved = 1>
        <cfset returnMSG = 'charging-approved'>
        
    	<!--- record transaction information 
			
			1. Dump content of form to txt file
			2. Insert core transaction information into db
				- Transaction Information
				- Donor Information
				- SHP tables if necessary
			3. Update additional information
			4. Update tribute information
		
		--->
        
        <!--- try and record the transaction details in a flat txt file --->
        <cftry>
        
			<!--- directories --->
            <cfset monthlyDumpDirectory = DateFormat(Now(), 'mm-yy')>
            <Cfset dailyDumpDirectory = DateFormat(Now(), 'DD')>
            
            <cfset dumpDirectory = "#APPLICATION.WEBLINKS.File.service#\transactions\#monthlyDumpDirectory#\#dailyDumpDirectory#\">
            
            <!--- check if directory exists --->
            <cfif DirectoryExists(dumpDirectory)>
                <!--- directory exists - we are all good --->
            <cfelse>
                <!--- need to create directory --->
                <cfdirectory directory="#dumpDirectory#" action="create">
                        
            </cfif>
            
            <!--- add timestamp to file --->
            <Cfset append = "#DateFormat(Now())#---#TimeFormat(Now(), 'HH-mm-ss.l')#">
            
            <!--- dump form to file --->
            <!--- hide PCI fields --->
            <cfdump var="#form#" output="#dumpDirectory#bcchildren_full_donation_dump_date-#append#.txt" hide="POST_CARD_NUMBER,POST_CVV,FIELDNAMES,POST_DOLLARAMOUNT,js_bcchf_cardnumber,js_bcchf_cvv,bcchf_cvv,bcchf_cc_number" type="html">
        
    	<cfcatch type="any">
        
        <!--- ERROR Message ---------------------------------------------------- --->
    	<cfset eDetailMSG = {tDate = pty_date,
			cfcatch = cfcatch,
			CGIscope = CGI,
			tUUID = variables.newUUID,
			eP = 3,
			eML = 8}>
		<cfset eDetails = SerializeJSON(eDetailMSG)>
    	<cfset errorSend = sendERRmsg(eDetails)>
        
        </cfcatch>
        </cftry>
        
        
        
        <!--- Try to Insert PayPal Created Payment Record Into Database --->
        <cftry>
       
        <!--- exact date from server --->
		<cfset exact_odbcDT = pty_Date>
        
        <!--- transaction information--->
        <CFQUERY datasource="#APPLICATION.DSN.Superhero#" name="insert_record" dbtype="ODBC">
        INSERT INTO tblPayPal (dtnDate, exact_date, dtnAmt, dtnBenefit, dtnReceiptAmt, dtnReceiptType, dtnBatch, dtnSource, rqst_dollaramount, pge_UUID, dtnIP, dtnBrowser, payPalPaymentID, payPalEXE) 
        VALUES (#pty_Date#, #exact_odbcDT#, '#post_dollaramount#', '#giftAdvantage#', '#giftTaxable#', '#receipt_type#', 'Online', '#donation_source#', '#post_dollaramount#', '#variables.newUUID#', '#newIP#', '#newBrowser#', '#payPalPaymentID#', '#rdrLnk#') 
        </CFQUERY>
                
        
        <cfcatch type="any">
        	<!--- ERROR Message ---------------------------------------------------- --->
			<cfset eDetailMSG = {tDate = pty_date,
                cfcatch = cfcatch,
                CGIscope = CGI,
                tUUID = variables.newUUID,
                eP = 3,
                eML = 13}>
            <cfset eDetails = SerializeJSON(eDetailMSG)>
    		<cfset errorSend = sendERRmsg(eDetails)>
			 
        </cfcatch>
        </cftry>
        
        
        <!--- check URL for email referal --->
        <cftry>
        
        <!--- lookup email and add note that donation has been made --->
        <cfif IsDefined('emailReferal') AND emailReferal NEQ ''>
        
            <cfset eRefUpdate = checkEmailReff(emailReferal, variables.newUUID)>
        
        </cfif>
        
        
        <cfcatch type="any">
        	<!--- do nothing --->
        </cfcatch>
        </cftry>

                
        
        <!--- ------------------- end of database processing ----------------------- --->

		<!--- user will be passed to paypal to confirm details of transaction
			- user will be passed back to us to execute transaction on completeDonation-NEW-PayPal.cfm
			--->
        
        <!--- message about frequency  --->
        <cfset chargeMSG = gift_frequency>
        <!--- after inserting in DB and sending emails --->
        <cfset returnSuccess = 1>
        
	</cfif><!--- end of if created in paypal --->
   
    
    <!--- return message --->
    <cfset ChargeAttmpt = {
		cAttempted = chargeAttempt,
		cApproved = chargeAproved,
		cMSG = chargeMSG,
		exact_respCode = exact_respCode,
		ipBlocker = ipBlocker,
		goodXDS = goodXDS,
		ppEXURL = rdrLnk,
		ppID = payPalPaymentID 
		} />

	<!--- this is the structure of the return message --->
    <cfset SHPdonationReturnMSG = {
	Success = returnSuccess,
	ChargeAttmpt = ChargeAttmpt,
	Message = returnMSG,
	EventToken = hiddenEventToken,
	UUID = variables.newUUID,
	tGenTwoID = tGenTwoID
	} />
    
    <cfreturn SHPdonationReturnMSG>

</cffunction>



<cffunction name="submitDonationForm" access="remote" >
    
	<!--- donor information --->
    <cfargument name="pty_title" type="string" required="yes">
    <cfargument name="pty_fname" type="string" required="yes">
    <cfargument name="pty_MIname" type="string" required="no">
    <cfargument name="pty_lname" type="string" required="yes">
    
    <cfargument name="pty_tax_title" type="string" required="yes">
    <cfargument name="pty_tax_fname" type="string" required="yes">
    <cfargument name="pty_tax_MIname" type="string" required="no">
    <cfargument name="pty_tax_lname" type="string" required="yes">
    
    <cfargument name="pty_companyname" type="string" required="yes">
    <cfargument name="pty_tax_companyname" type="string" required="yes">
    
    <cfargument name="ptc_address" type="string" required="yes">
    <cfargument name="ptc_addTwo" type="string" required="yes">
    <cfargument name="ptc_city" type="string" required="yes">
    <cfargument name="ptc_country" type="string" required="yes">
    <cfargument name="ptc_prov" type="string" required="yes">
    <cfargument name="ptc_post" type="string" required="yes">
    <cfargument name="ptc_email" type="string" required="yes">
    <cfargument name="pty_subscr_r" type="string" required="no">
    <cfargument name="ptc_phone" type="string" required="yes">
    
    <!--- tribute information --->
    <cfargument name="trb_fname" type="string" required="no">
    <cfargument name="trb_lname" type="string" required="no">
    <cfargument name="hiddenAWKtype" type="string" required="no">
    <cfargument name="srp_fname" type="string" required="no">
    <cfargument name="srp_lname" type="string" required="no">
    <cfargument name="trb_address" type="string" required="no">
	<cfargument name="trb_addtwo" type="string" required="no">
	<cfargument name="trb_city" type="string" required="no">
	<cfargument name="trb_prov" type="string" required="no">
    <cfargument name="trb_post" type="string" required="no">
    <cfargument name="trb_country" type="string" required="no">
    <cfargument name="trb_email" type="string" required="no">
    <cfargument name="trb_message" type="string" required="no">
    <cfargument name="trb_cardfrom" type="string" required="no">
    
    <!--- eCard Information --->
    <cfargument name="cardRec_fname" type="string" required="no">
    <cfargument name="cardRec_lname" type="string" required="no">
    <cfargument name="cardRec_email" type="string" required="no">
    <cfargument name="cardSend_fname" type="string" required="no">
    <cfargument name="cardSend_lname" type="string" required="no">
    <cfargument name="cardSend_email" type="string" required="no">
    <cfargument name="eCardMessage" type="string" required="no">
    <cfargument name="eCard_image" type="string" required="no">
    <cfargument name="eCard_occasion" type="string" required="no">
    <cfargument name="cardSend_date" type="string" required="no">
    <cfargument name="eCardMessagehidden" type="string" required="no">
    
    <!--- SHP event scroll details --->
    <cfargument name="hiddenEventToken" type="string" required="no">
    <cfargument name="hiddenEventCurrentYear" type="string" required="no">
    <cfargument name="hiddenTeamID" type="string" required="no">
    <cfargument name="hiddenSupID" type="string" required="no">
    <cfargument name="DName" type="string" required="no">
    <cfargument name="hiddentype" type="string" required="no">
    <cfargument name="Message" type="string" required="no">
    <cfargument name="Show" type="string" required="no">
    <cfargument name="ShowAnonymous" type="string" required="no">
    
    <!--- additional details --->
    <cfargument name="gift_notes" type="string" required="no">
    <cfargument name="info_where" type="string" required="no">
    <cfargument name="donated_before" type="string" required="no">
	<!--- info about securities --->
    <cfargument name="info_securities" type="string" required="no">
    <!--- included in will --->
    <cfargument name="info_willinclude" type="string" required="no">
    <!--- included in life --->
    <cfargument name="info_lifeinclude" type="string" required="no">
    <!--- included in RSP --->
    <cfargument name="info_RSPinclude" type="string" required="no">
    <!--- send more info --->
    <cfargument name="info_will" type="string" required="no">
    <cfargument name="info_life" type="string" required="no">
    <cfargument name="info_RRSP" type="string" required="no">
    <cfargument name="info_trusts" type="string" required="no">
    
    <!--- subscriptions --->
    <cfargument name="news_subscribe" type="string" required="no">
    <cfargument name="SOC_subscribe" type="string" required="no">
    <cfargument name="AR_subscribe" type="string" required="no">
    
    <!--- pledge details --->
    <cfargument name="gift_pledge_det" type="string" required="no">
    <cfargument name="gift_pledge_DonorID" type="string" required="no"><!---  --->
    
    <!--- donation information --->
    <!--- gift type --->
    <cfargument name="hiddenGiftType" type="string" required="yes">
	<!--- gift amount --->
    <cfargument name="hiddenGiftAmount" type="string" required="yes">
    <!--- Personal or Corporate - set tax values with this info --->
    <cfargument name="hiddenDonationPCType" type="string" required="yes">
    <!--- indicated frequency --->
    <cfargument name="hiddenDonationType" type="string" required="yes">
    <!--- monthly day  not required for single --->
    <cfargument name="hiddenFreqDay" type="string" required="no">
    <!--- tribute type --->
    <!--- eCard for eCards - Pledge for Pledge --->
    <cfargument name="hiddenTributeType" type="string" required="yes">
    
    <!--- tax receipt information --->
    <cfargument name="pty_tax" type="string" required="yes">
    <cfargument name="pty_ink" type="string" required="no">
    <cfargument name="pty_tax_issuer" type="string" required="yes">
    <!--- TO ADD tax type for HK receipts --->
    
    <!--- cardholder data --->
    <cfargument name="post_card_number" type="string" required="no">
    <cfargument name="post_expiry_date" type="string" required="no">
    <cfargument name="post_cardholdersname" type="string" required="no">
    <cfargument name="post_CVV" type="string" required="no">
    
    <!--- email referal conditions --->
    <cfargument name="emailReferal" type="string" required="no">
    
    <!--- JeansDay Information --->
    <cfargument name="runnerPin" type="string" required="no">
    <cfargument name="runnerButton" type="string" required="no">
    <cfargument name="runnerBBQ" type="string" required="no">
    
    <!--- HSBC Information --->
    <cfargument name="TransitNumber" type="string" required="no">
    <cfargument name="TransitNumberOther" type="string" required="no">
    
    <!--- ---------------------------- start of processing  -------------------------------------------- --->
    <!--- SERVER Date at submission --->
    <cfif NOT IsDefined("pty_date")><cfset pty_date= "#Now()#"></cfif>
    
    <!--- DENY XXS Attack --->
    <cfif CGI.REMOTE_ADDR EQ '58.187.162.122'>
    <cfthrow message="toast" type="error">
    </cfif>
    
    <!--- create UUID to access info --->
    <cfset variables.newUUID=createUUID()>
    <!--- collect IP address of remote requestor --->
	<cfset newIP = CGI.REMOTE_ADDR>
	<cfset newBrowser = CGI.HTTP_USER_AGENT>
    <cfset ipBlocker = 0>
    
    <!--- set transaction amount --->
    <cfset hiddenGiftAmount = REREPlace(hiddenGiftAmount, '[^0-9.]','','all')>
    <cfset post_dollaramount = hiddenGiftAmount>
    
    <cfset giftAdvantage = 0>
    <cfset giftTaxable = post_dollaramount>
    
    <!--- default setting is not adding to hero donate ---> 
    <cfset HeroDonateAdd = 0>
    
    <!--- successful variables --->
    <cfset chargeSuccess = 0>
    <cfset donationSuccess = 0>
    <cfset chargeAttempt = 0>
    <cfset chargeAproved = 0>
    <cfset chargeMSG = "">
    <cfset tGenTwoID = 0>
    
    <!--- construct return message --->
    <cfset returnSuccess = 0>
    <cfset returnMSG = 'beginAttempt'>
    <cfset exact_respCode = 0>
    
    <!--- trim name vars --->
    <cfset pty_tax_fname = TRIM(pty_tax_fname)>
	<cfset pty_tax_lname = TRIM(pty_tax_lname)>
	<cfset pty_companyname = TRIM(pty_companyname)>
    <cfif pty_companyname EQ ' '>
		<cfset pty_companyname = ''>
    </cfif>
    
    
    <!--- set gift type on form pre load --->
    <cfset gift_type = hiddenGiftType>
        
	<!--- set source --->
	<cfset donation_source = 'New Donation Form'>
    
    <!--- read ePhil Source --->
    <cfif IsDefined('ePhilanthropySource')>
    	<cfset ePhilSRC = ePhilanthropySource>
    <cfelse>
    	<cfset ePhilSRC = ''>
    </cfif>
    
    
    <!--- scrub some variables for db loading --->
    <cftry>
    
    	        
        <!--- corp / personal tax settings --->
		<cfif hiddenDonationPCType EQ 'corporate'>
            <!--- corporate donation --->
            <cfset pty_tax_title = "">
            <cfset pty_tax_fname = "">
            <cfset pty_tax_lname = "">
            <cfset pty_companyname = pty_tax_companyname>
        <cfelse>
            <!--- personal donation fields --->
            <cfset pty_title = pty_tax_title>
            <cfset pty_fname = pty_tax_fname>
            <cfset pty_lname = pty_tax_lname>
            <cfset pty_tax_companyname = "">
        </cfif>
    
    	<!--- determine gift Day --->
		<cfif hiddenDonationType EQ 'monthly'>
            <cfif IsDefined('hiddenFreqDay')>
                <cfset gift_day = hiddenFreqDay>
            <cfelse>
                <cfset gift_day = 1>
            </cfif>
        <cfelse>
            <cfset gift_day = "">
        </cfif>
    
    	<!--- TAX receipt options for processor ---->
        <!--- use receipt type for Ink/No Ink --->
        <!--- TODO: HK receipting options --->
        <!--- receipt types
			TAX = TAX RECEIPT
			AWK = AWKNOWLEDGMENT RECEIPT
			TAX-HK = Hong Kong 
			TAX-IF = Ink Friendly
			TAX-ANNUAL = Annual Receipt for monthly gift
			TAX-HK-ANNUAL = Annual Receipt for monthly gift on HK page
			NONE = None requested / ineligible
			--->
		
		<cfif pty_tax_issuer EQ 'BCCHF'>
        
			<cfif gift_frequency EQ 'single'>
                <cfif pty_tax EQ "no">
                    <cfset receipt_type = 'NONE'>
                <cfelse>
                	<cfif IsDefined('pty_ink')>
                    	<cfif pty_ink EQ 'yes'>
                        	<cfset receipt_type = 'TAX-IF'>
                    	<cfelse>
                        	<cfset receipt_type = 'TAX'>
                    	</cfif>
                    <cfelse>
                    	<cfset receipt_type = 'TAX'>
                    </cfif>
                </cfif>
            <cfelse>
                <cfif pty_tax EQ "no">
                    <cfset receipt_type = 'NONE'>
                <cfelse>
                    <cfset receipt_type = 'TAX-ANNUAL'>
                </cfif>        
            </cfif>
        
        <cfelseif pty_tax_issuer EQ 'HK'>
        
        	<cfif gift_frequency EQ 'single'>
                <cfif pty_tax EQ "no">
                    <cfset receipt_type = 'NONE'>
                <cfelse>
                    <cfset receipt_type = 'TAX-HK'>
                </cfif>
            <cfelse>
                <cfif pty_tax EQ "no">
                    <cfset receipt_type = 'NONE'>
                <cfelse>
                    <cfset receipt_type = 'TAX-HK-ANNUAL'>
                </cfif>        
            </cfif>
                
        <cfelse>
        </cfif>
    
    	<!--- legacy: receipt generator method
			- check for receipt status 
			- append 'no receipt' to frequency for no receipt--->
        <cfif pty_tax EQ "no">
			<cfset gift_frequency="#hiddenDonationType# - No Receipt">
        <cfelse>
        	<cfset gift_frequency="#hiddenDonationType#">
        </cfif>
        
        <cfif gift_frequency EQ 'single'>
        	<cfset gift_frequency = 'Single'>
        </cfif>
    
    	<!--- add designation details to notes section --->
        <cfif IsDefined('hiddenDesignation') AND hiddenDesignation NEQ ''>
        
			<cfset gift_notes="designation:#hiddenDesignation# - #gift_notes#">
            
            <!--- for hydro donations - credit to team --->
            <cfif gift_type EQ 'Hydro'>
            
            	<cfif hiddenDesignation EQ 'powerEndow'>
                	<cfset hiddenTeamID = 6141>
                
                <cfelseif hiddenDesignation EQ 'powerAqua'>
                	<cfset hiddenTeamID = 6151>
                
                <cfelseif hiddenDesignation EQ 'powerDefrib'>
                	<cfset hiddenTeamID = 11933>
                
                <cfelseif hiddenDesignation EQ 'powerDrill'>
                	<cfset hiddenTeamID = 12229>
                        
                </cfif>
            
            <cfelseif gift_type EQ 'CrystalBall'>
            <!--- CrystalBall designation could be contained here --->
            
            	<cfif hiddenDesignation EQ '28088'>
                	<cfset hiddenSupID = 28088>
                </cfif>
			
			<cfelseif gift_type EQ 'FOT'>
            <!--- FOT designation could be contained here --->
            
            	<cfif hiddenDesignation EQ '4210'>
                	<cfset hiddenTeamID = 4210>
                
                <cfelseif hiddenDesignation EQ '4211'>
                	<cfset hiddenTeamID = 4211>
                
                <cfelseif hiddenDesignation EQ '4212'>
                	<cfset hiddenTeamID = 4212>
                    
                <cfelseif hiddenDesignation EQ '4213'>
                	<cfset hiddenTeamID = 4213>
                    
                </cfif>
            
            
			
			<cfelseif gift_type EQ 'ChildLife'
				OR gift_type EQ 'CBSA'>
            <!--- ChildLife designation is contained here --->
            
                <cfset hiddenTeamID = hiddenDesignation>
                
                <cfif hiddenTeamID EQ ''>
                	<cfset hiddenTeamID = 0>
                </cfif>
                
                <cfif hiddenSupID EQ ''>
                	<cfset hiddenSupID = 0>
                </cfif>
                
                
                <!--- enter the supporter name in notes --->
                <cfif hiddenSupID EQ 0>
                <cfelse>
                
                <cfquery name="selectName" datasource="bcchf_Superhero">
                SELECT SupFName FROM Hero_Members 
                WHERE SuppID = #hiddenSupID#
                </cfquery>
                
                <cfset gift_notes="#selectName.SupFName# - #gift_notes#">
                
                </cfif>
                
                
                
                <!--- enter the tean name in designation notes --->
                <cfif hiddenTeamID EQ 0>
                
                	<cfset gift_notes="Specific Purpose:Unspecified - #gift_notes#">
                
                <cfelse>
                
                    <cfquery name="selectTeam" datasource="bcchf_Superhero">
                    SELECT TeamName FROM Hero_Team 
                    WHERE TeamID = #hiddenTeamID#
                    </cfquery>
                    
                    <cfset gift_notes="Specific Purpose:#selectTeam.TeamName# - #gift_notes#">
                
                
                </cfif>
                
            
            <cfelseif gift_type EQ 'HSBC'>
            <!--- HSBC designation could be contained here --->	
            	<cfif TransitNumber EQ 35216>
                <!--- other --->
                	<cfset hiddenSupID = 35216>
                    <cfset gift_notes="Other Transit Number:#TransitNumberOther# - #gift_notes#"> 
                <cfelse>
                	<cfset hiddenSupID = TransitNumber>
                    <cfset gift_notes="#gift_notes#"> 
                </cfif>
            
            </cfif>
            
            
        <cfelse>
			<cfset gift_notes="#gift_notes#">
        </cfif>
        
        <!--- DRTV special --->
        <cfif gift_type EQ 'DRTV'>
        	<cfif IsDefined('DRTV_gift')>
            	<cfif DRTV_gift EQ 'Yes'>
                	<cfset gift_notes="Send Bear to Donor - #gift_notes#">
                </cfif>
            </cfif>
        </cfif>
        
        <!--- Jeans Day - record button and pin information provided by user --->
        <cfif gift_type EQ 'JeansDay'>
        
        	<cfset trb_fname = "">
			<cfset trb_lname = "">
            <cfset trb_email = "">
            <cfset trb_address = "">
            <cfset trb_city = "">
            <cfset trb_prov = "">
            <cfset trb_post = "">
            <cfset srp_fname = "">
            <cfset srp_lname = "">
            <cfset trb_cardfrom = "">
            <cfset cleanTrbMessage = "">
            <cfset hiddenTributeType = "">
            <cfset hiddenAWKtype = "">
            <cfset gTribute = "no">
        
        	<cfif runnerPin EQ ''>
        		<cfset pinsPurchased = 0>
                <cfset RunnerPin = 0>
            <cfelse>
            	<cfset pinsPurchased = runnerPin>
                <cfset runnerPin = runnerPin>
            </cfif>
            
            <cfif runnerButton EQ ''>
            	<cfset buttonsPurchased = 0>
                <cfset RunnerButton = 0> 
        	<cfelse>
            	<cfset buttonsPurchased = runnerButton>
				<cfset runnerButton = runnerButton> 
            </cfif>
            
            <cfif runnerBBQ EQ ''>
            	<cfset ticketsPurchased = 0>
				<cfset RunnerBBQ = 0>
            <cfelse>
            	<cfset ticketsPurchased = RunnerBBQ>
				<cfset RunnerBBQ = RunnerBBQ>
            </cfif>
            
            <cfif runnerFriday EQ ''>
            	<cfset CFPurchased = 0>
				<cfset runnerFriday = 0>
            <cfelse>
            	<cfset CFPurchased = runnerFriday>
				<cfset runnerFriday = runnerFriday>
            </cfif>
            
            <cfif IsDefined('hiddenBBCLocation')>
            	<cfset jdBBQl = hiddenBBCLocation>
            <cfelse>
            	<cfset jdBBQl = ''>
            </cfif>
            
            <!---- BBQ tickets not eligable for receipt --->
            <cfif RunnerBBQ GT 0>
            	
                <!--- if only BBQ tickets -> AWK receipt --->
                <cfif runnerBBQTotal EQ gift_onetime_other>
                
                	<cfset receipt_type = 'AWK'>
            
            		<cfset giftAdvantage = gift_onetime_other>
            		<cfset giftTaxable = 0>
                
                <cfelse>
                <!--- some BBQ tickets --->
                
                	<cfset giftAdvantage = runnerBBQTotal>
            		<cfset giftTaxable = gift_onetime_other - runnerBBQTotal>
                
                
                </cfif>
            
            	<!--- set team ID for BBQ team --->
                <cfif hiddenTeamID EQ 0>
	                <cfset hiddenTeamID = 9130>
                </cfif>
                
            
            </cfif>
            
            
        <cfelse>
        
        	<cfset pinsPurchased = 0>
            <cfset buttonsPurchased = 0>
            <cfset ticketsPurchased = 0>
            <cfset RunnerPin = 0>
			<cfset RunnerButton = 0>
            <cfset RunnerBBQ = 0> 
            <cfset CFPurchased = 0>
			<cfset runnerFriday = 0>
            <cfset jdBBQl = ''>
        
        </cfif>
        
        
        <cfif gift_type EQ 'SloPitch' AND hiddenTeamID EQ 8503>
        
        	<cfif IsDefined('FORM.spBBQteam')>
            	<cfif gift_notes EQ ''>
                <cfset gift_notes = "Team: #spBBQteam#">
                <cfelse>
            	<cfset gift_notes = "Team: #spBBQteam#; #gift_notes#">
				</cfif>
            </cfif>
        
        	<cfset noBBQt = gift_onetime_other / 15>
            <cfset gift_notes = "Tickets: #noBBQt#; #gift_notes#">
        
        	<cfset trb_fname = "">
			<cfset trb_lname = "">
            <cfset trb_email = "">
            <cfset trb_address = "">
            <cfset trb_city = "">
            <cfset trb_prov = "">
            <cfset trb_post = "">
            <cfset srp_fname = "">
            <cfset srp_lname = "">
            <cfset trb_cardfrom = "">
            <cfset cleanTrbMessage = "">
            <cfset hiddenTributeType = "">
            <cfset hiddenAWKtype = "">
            <cfset gTribute = "no">
        </cfif>
        
        <!--- AWK receipt for BFK sunshine sponsor --->
        <cfif gift_type EQ 'BFK' AND hiddenTeamID EQ 8020>
        
            <cfset receipt_type = 'AWK'>
            
            <cfset giftAdvantage = post_dollaramount>
            <cfset giftTaxable = 0>
        
        </cfif>
        
        <!--- add to Hero_Donate Token --->
        <!--- I cannot remember why this is here ---
		 AND (hiddenTributeType EQ 'hon-WOT' OR hiddenTributeType EQ 'mem-WOT')
		 --->
        <cfif gift_type EQ 'WOT'>
        	<cfset HeroDonateAdd = 1>
        <cfelseif gift_type EQ 'ICE'>
        	<cfset HeroDonateAdd = 1>
        <cfelseif gift_type EQ 'Welcome'>
        	<cfset HeroDonateAdd = 1>
        <cfelseif gift_type EQ 'JeansDay'>
        	<cfset HeroDonateAdd = 1>
        <cfelseif gift_type EQ 'SloPitch'>
        	<cfset HeroDonateAdd = 1>
        </cfif>
        
        <cfif hiddenTributeType EQ 'event'>
        	<!--- other SHP events --->
        	<cfset HeroDonateAdd = 1>
        </cfif>
        
        <cfif hiddenDonationType EQ 'monthly'>
			<cfset Hero_Donate_Amount = post_dollaramount><!---  * 12 --->
            <cfset GiftFreqM = 1>
        <cfelse>
            <cfset Hero_Donate_Amount = post_dollaramount>
            <cfset GiftFreqM = 0>
        </Cfif> 
        
        <!--- TYS options --->
        <cfif IsDefined('Show')>
            
			<cfif Show EQ 'Yes'>
				<cfset Show = 1>
			<cfelse>
				<cfset Show = 0>
			</cfif>
            
		<cfelse>
            
			<cfset Show = 0>
            
		</cfif>
        
        <!--- we want to insert first as anonymous - 
			donor updates the scroll on confirmation page --->
		<cfset DName = 'Anonymous'>
        <!--- 2013-03-01 Default now shows donor name
			until the donor changes it on the confirmation screen --->
		<cfset DName = '#pty_fname# #pty_lname#'>
        
        <!--- ChildLife Gift Notes copy to 'Message' field --->
		<cfif gift_type EQ 'ChildLife'>
			<cfset Message = gift_notes>
        </cfif>
        
        <cfif gift_type EQ 'General'>
        	<!--- enter donor as anonymous for scroll on new donaton form --->
			<cfset DName = 'Anonymous'>
            <!--- DO NOT ENTER old form donations --->
            <cfset HeroDonateAdd = 0>
        </cfif>
        
        <!--- additional info --->
        <cfif NOT IsDefined("info_securities")><cfset info_securities = ""></cfif>
		<CFIF info_securities EQ ""><CFSET info_securities = " "></CFIF>
        
        <cfif NOT IsDefined("info_will")><cfset info_will = ""></cfif>
        <CFIF info_will EQ ""><CFSET info_will = " "></CFIF>
        
        <cfif NOT IsDefined("info_life")><cfset info_life = ""></cfif>
        <CFIF info_life EQ ""><CFSET info_life = " "></CFIF>
        
        <cfif NOT IsDefined("info_trusts")><cfset info_trusts = ""></cfif>
        <CFIF info_trusts EQ ""><CFSET info_trusts = " "></CFIF>
        
        <cfif NOT IsDefined("info_RRSP")><cfset info_RRSP = ""></cfif>
        <CFIF info_RRSP EQ ""><CFSET info_RRSP = " "></CFIF>
        
        <cfif NOT IsDefined("info_willinclude")><cfset info_willinclude = ""></cfif>
        <CFIF info_willinclude EQ ""><CFSET info_willinclude = " "></CFIF>
        
        <cfif NOT IsDefined("info_lifeinclude")><cfset info_lifeinclude = ""></cfif>
        <CFIF info_lifeinclude EQ ""><CFSET info_lifeinclude = " "></CFIF>
        
        <cfif NOT IsDefined("info_RSPinclude")><cfset info_RSPinclude = ""></cfif>
        <CFIF info_RSPinclude EQ ""><CFSET info_RSPinclude = " "></CFIF>
        
        <cfif NOT IsDefined("news_subscribe")><cfset news_subscribe = ""></cfif>
        <CFIF news_subscribe EQ ""><CFSET news_subscribe = " "></CFIF>
        
        <cfif NOT IsDefined("pty_subscr_r")><cfset pty_subscr_r = ""></cfif>
        <CFIF pty_subscr_r EQ ""><CFSET pty_subscr_r = " "></CFIF>
        
        <!--- if news subscribe is yes - set SOC and AR to yes --->
        <cfif news_subscribe EQ 1>
            <cfset SOC_subscribe = 1>
            <cfset AR_subscribe = 0>
        <cfelse>
            <cfset SOC_subscribe = 0>
            <cfset AR_subscribe = 0>
        </cfif>
        
        <!--- new method --- pty_subscr_r ---->
        <cfif pty_subscr_r EQ 1>
            <cfset SOC_subscribe = 1>
            <cfset news_subscribe = 1>
            <cfset AR_subscribe = 0>
        <cfelse>
            <cfset SOC_subscribe = 0>
            <cfset news_subscribe = 0>
            <cfset AR_subscribe = 0>
        </cfif>
        
        <!--- pledge details --->
        <cfif gift_type EQ 'Pledge'>
        
        	<cfset gPledge = 'Yes'>
            
			<cfif gift_pledge_DonorID EQ ''>
            <!--- no AWK fields have been passed --->
                <cfset gift_pledge_DonorID =''>
            <cfelse>
                <cfset gift_pledge_DonorID = gift_pledge_DonorID>        
            </cfif>
            
        <cfelse>
        
        	<cfif hiddenTributeType EQ 'pledge'>
            
            	<cfif gift_pledge_DonorID EQ ''>
				<!--- no AWK fields have been passed --->
                    <cfset gift_pledge_DonorID =''>
                <cfelse>
                    <cfset gift_pledge_DonorID = gift_pledge_DonorID>        
                </cfif>
            
            	<cfset gPledge = 'Yes'>
            
            <cfelse>
            
            	<cfset gift_pledge_DonorID =''>
            	<cfset gPledge = 'No'>
            
            </cfif>
        
        </cfif>
        
        <!--- tribute info  --->
        <cfif hiddenTributeType EQ 'hon' OR hiddenTributeType EQ 'mem'>
        
        	<cfset gTribute = 'Yes'>
        
			<cfif hiddenAWKtype EQ 'none'>
            <!--- no AWK fields have been passed --->
                <cfset cleanTrbMessage =''>
                <cfset srp_fname =''>
                <cfset srp_lname =''>
                <cfset trb_cardfrom =''>
            <cfelse>
                <cfset cleanTrbMessage = REReplaceNoCase(trb_message,"<[^>]*>","","ALL")>
            </cfif>
        
        <cfelse>
        
        	<cfset gTribute = 'No'>
        	<cfset cleanTrbMessage =''>
        
        </cfif>
        
    <cfcatch type="any">
    
        <cfmail to="ismonitor@bcchf.ca" from="error@bcchf.ca" subject="P2:Error - Scrubbing donation form data in processDonation" type="html" priority="2">
        Error scrubbing donation form data. Priority Level 2.<br />
		A Donation Form was submitted, but some data is not right, which may cause subsequent errors during this transaction.<br />
		Transaction is permitted to proceed; immediate action not required, unless multiple errors of this nature start to be thrown.<br />
        Message: #cfcatch.Message#<br />
        Detail: #cfcatch.Detail#<br />
        <cfdump var="#cfcatch#" label="catch">
        </cfmail>
    
    </cfcatch>
    </cftry>
    
    
    <!--- attempt charge --->
	<cfset chargeAttempt = 1>
    <cfset attemptCharge = 1>
    <cfset returnMSG = 'beginAttempt-charging'>
    
    
	<!--- Trying to record Attempt Record --->
    <cftry>
    
    	<cfset tAttemptRecord = {tDate = pty_date, 
								tUUID = variables.newUUID,
								tDonor = {
									dTitle = pty_title,
									dFname = pty_fname,
									dMname = pty_miname,
									dLname = pty_lname,
									dCname = pty_companyname,
									dTaxTitle = pty_tax_title,
									dTaxFname = pty_tax_fname,
									dTaxMname = pty_miname,
									dTaxLname = pty_tax_lname,
									dTaxCname = pty_tax_companyname,
									dAddress = {
										aOne = ptc_address,
										aTwo = ptc_addTwo,
										aCity = ptc_city,
										aProv = ptc_prov,
										aPost = ptc_post,
										aCountry = ptc_country
									},
									dEmail = ptc_email,
									dPhone = ptc_phone
								},
								tGift = post_dollaramount,
								tGiftAdv = giftAdvantage,
								tGiftTax = giftTaxable,
								tType = gift_type,
								tFreq = gift_frequency,
								tNotes = gift_notes,
								tSource = donation_source,
								eSource = ePhilSRC,
								tBrowser = {
									bUAgent = newBrowser,
									bName = uabrowsername,
									bMajor = uabrowsermajor,
									bVer = uabrowserversion,
									bOSname = uaosname,
									bOSver = uaosversion,
									dDevice = uadevicename,
									bDtype = uadevicetype,
									bDvend = uadevicevendor,
									bIP = newIP
								},
								tTType = pty_tax,
								tFreqDay = gift_day,
								tSHP = {
									tAdd = HeroDonateAdd,
									tToken = hiddenEventToken,
									tCampaign = hiddenEventCurrentYear,
									tTeamID = hiddenTeamID,
									tSupID = hiddenSupID,
									tDname = DName,
									tStype = hiddentype,
									tSmsg = Message,
									tSshow = Show,
									Hero_Donate_Amount = Hero_Donate_Amount
								},
								tJD = {
									Pins = RunnerPin,
									Buttons = RunnerButton,
									BBQ = RunnerBBQ,
									BBQl = jdBBQl,
									cFriday = RunnerFriday
								},
								tFORM = {
									hiddenDonationPCType = hiddenDonationPCType,
									hiddenDonationType = hiddenDonationType,
									hiddenFreqDay = hiddenFreqDay,
									hiddenGiftAmount = hiddenGiftAmount,
									donation_type = donation_type,
									gift_frequency = gift_frequency,
									gift_day = gift_day,
									hiddenTributeType = hiddenTributeType,
									gift_tributeType = gift_tributeType
									
								},
								adInfo = {
									iSecurity = info_securities,
									iWill = info_will,
									iLife = info_life,
									iTrust = info_trusts,
									iRRSP = info_RRSP,
									iWillInclude = info_willinclude,
									iLifeInclude = info_lifeinclude,
									iRSPinclude = info_RSPinclude,
									SOC_subscribe = SOC_subscribe,
									news_subscribe = news_subscribe,
									AR_subscribe = AR_subscribe,
									iWhere = info_where,
									iPastDonor = donated_before,
									gPledgeDet = gift_pledge_det,
									gPledgeDREID = gift_pledge_DonorID,
									gPledge = gPledge
									
								},
								tribInfo = {
									trbFname = trb_fname,
									trbLname = trb_lname,
									trbEmail = trb_email,
									trbAddress = trb_address,
									trbCity = trb_city,
									trbProv = trb_prov,
									trbPost = trb_post,
									srpFname = srp_fname,
									srpLname = srp_lname,
									trbCardfrom = trb_cardfrom,
									trbMsg = cleanTrbMessage,
									tribNotes = hiddenTributeType,
									cardSend = hiddenAWKtype,
									gTribute = gTribute
								}
			} />
            
            <cfset tAttempt = SerializeJSON(tAttemptRecord)>
    	
    		<cfset tATPrec = recordTransAttempt(tAttempt)>
    
    	<cfinclude template="../includes/0log_donation.cfm">
    
    <cfcatch type="any">
    <cfmail to="ismonitor@bcchf.ca" from="error@bcchf.ca" subject="P3: Error - Recording backup data attempt record in processDonation" type="html" priority="3">
    Error recording backup data - trying to record attempt record. Priority Level 3.<br />
	A Donation Form was submitted, but the attemt record was unable to be saved in 0log_donation.<br />
	Transaction is permitted to proceed; immediate action not required.<br />
    Message: #cfcatch.Message#<br />
    Detail: #cfcatch.Detail#<br />
    <cfdump var="#cfcatch#" label="catch">
    </cfmail>
    </cfcatch>
    </cftry>
    
    <!--- try fraudster intercept:
		check for XDS
		check IP on blackList
		check fraudster MO --->
    <cftry>
    
    	<!--- XDS --->
		<cfset goodXDS = checkXDS(APPLICATION.AppVerifyXDS, FORM.App_verifyToken, CGI.HTTP_REFERER)>
        
        <cfif goodXDS EQ 0>
            <cfset attemptCharge = 0>
        </cfif>
        
        
    
		<!--- check IP against blacklist --->
        <cfset goodIP = checkIPaddress(newIP)>
        
        <cfif goodIP EQ 0>
            <cfset attemptCharge = 0>
        </cfif>
    
		<!--- check Fraudster MO --->
        <cfset fradulent = checkFraudsterMO(pty_tax_fname, pty_tax_lname, pty_fname, pty_lname, ptc_email, ptc_country, gift_frequency, post_dollaramount)>
        
        <cfif fradulent EQ 1>
            <cfset attemptCharge = 0>
        </cfif>
    
    <cfcatch type="any">
    <cfset attemptCharge = 0>
    <cfmail to="ismonitor@bcchf.ca" from="error@bcchf.ca" subject="P3: Error - Checking fraud data in processDonation" type="html" priority="3">
    Error checking fraud data. Priority Level 3.<br />
	A Donation Form was submitted, but the processor ws unable to check for fraudulent attempts.<br />
	Transaction is permitted to proceed; immediate action not required.<br />
    Message: #cfcatch.Message#
    Detail: #cfcatch.Detail#
    <cfdump var="#cfcatch#" label="catch">
    </cfmail>
    </cfcatch>
    </cftry>
    
    
    <!--- ---------------------------- start of exact processing -------------------------------------------- --->
    <!--- if we can attempt the charge --->
    <cfif attemptCharge EQ 1>
    
		<!--- trying to process on e-xact --->
        <cftry>
        
			<!--- BCCHF Exact Gobal Vars --->
            <cfinclude template="../includes/e-xact_include_var.cfm">
            
            <cfif post_card_number EQ 4111111111111111
				AND post_cardholdersname EQ 'test'
				AND post_CVV EQ 123><!--- allow testing --->
            
                <!--- Testing Process ---><cfinclude template="../includes/testBlock.cfm"> 
                <!--- UUID used in test approvals 
                <cfinclude template="../includes/e-xact_post_v60.1.cfm">--->
            
            <cfelse>
            
                <!--- Exact Method cfinvoke webservice ---> 
                <cfinclude template="../includes/e-xact_post_v60.1.cfm">
            
            </cfif> 
        
        
        <cfcatch type="any">
        <cfmail to="ismonitor@bcchf.ca" from="error@bcchf.ca" subject="P1: Error - Communicating with e-xact" type="html" priority="1">
        <strong>!!*** ---- error in exact process. Priority Level 1. ---- ***!!</strong><br />
        A Donation Form was submitted, but communication with E-xact failed.<br />
		<strong>Immediate action required</strong>.<br />
        The cause of this error needs to be determined, this type of error could block our ability to process transactions.<br />
		May be caused by a short outage with E-xact, in which case service will return with no further action required, however investigation is required.<br />
        Message: #cfcatch.Message#<br />
        Detail: #cfcatch.Detail#<br />
        <cfdump var="#cfcatch#" label="catch">
        </cfmail>
        </cfcatch>
        </cftry>
        

        <!--- trying to record Recieved Record --->
        <!--- records form data and exact returned vars --->
        <cftry>
        
        	<!--- Update Attempt Record with E-Xact Charge Tokens --->
            <cfset eTransResult = {
				rqst_transaction_approved = rqst_transaction_approved,
				rqst_dollaramount = rqst_dollaramount,
				rqst_CTR = rqst_CTR,
				rqst_authorization_num = rqst_authorization_num,
				rqst_sequenceno = rqst_sequenceno,
				rqst_bank_message = rqst_bank_message,
				rqst_exact_message = rqst_exact_message,
				rqst_formpost_message = rqst_formpost_message,
				rqst_exact_respCode = rqst_exact_respCode,
				rqst_AVS = rqst_AVS
			}/>
            
            
            
            <cfset eXactRes = SerializeJSON(eTransResult)>
            
            <cfset eATPrec = recordExactAttempt(eXactRes, variables.newUUID)>
            
        
            <cfinclude template="../includes/1log_donation.cfm">
        
        <cfcatch type="any">
        <cfmail to="ismonitor@bcchf.ca" from="error@bcchf.ca" subject="P3: Error - Recording backup data in processDonation" type="html" priority="3">
        Error recording backup data - trying to record recieved data. Priority Level 3.<br />
		A Donation Form was submitted - data submitted and recieved from E-xact, but the processor ws unable save the returned E-xact message in 1log_donation.<br />
		Transaction is permitted to proceed; immediate action not required.<br />
        Message: #cfcatch.Message#
        Detail: #cfcatch.Detail#
        <cfdump var="#cfcatch#" label="catch">
        </cfmail>
        </cfcatch>
        </cftry>
    

    <cfelse>
    	<!--- charge not attempted - IP blocked --->
    
    	<cfset rqst_transaction_approved = 0>
        <cfset rqst_exact_respCode = 0>
    	<cfset chargeAproved = 0>
        <cfset exact_respCode = 0>
        <cfset returnMSG = 'Charge Not Attempted'>
    
    </cfif>
    <!--- ---------------------------- end of exact of processing  ------------------------------------- --->
    
    <!--- ---------------------------- start of database processing  -------------------------------------------- --->
    <!--- NOT approved --->
    <cfif rqst_transaction_approved NEQ 1>
    
    	<!--- abort and show messages --->
    	<cfset chargeAproved = 0>
        <cfset exact_respCode = rqst_exact_respCode>
        <cfset returnMSG = 'charging-notapproved'>
        
        
        <!--- track non approvals 
			1. check for past not approved transactions
			2. allow another attempt or abort
		
			multiple non-approvals from the same IP should trigger message and blocking
			---->
        
		<cftry>
		<!--- check decline code - for pick up card or malicious codes, block the IP --->
        <cfif rqst_bank_message EQ 'PICK UP CARD       * CALL BANK          =' 
			OR rqst_bank_message EQ 'HOLD CARD          * CALL               ='>
            <cfset recordIP = blockIP(newIP)>
        </cfif>
		
		
		
		
		
		
		<!--- try to check IP against blacklist --->
        
		<!--- check if this IP has already made a failed attempt  --->
        
        <!--- check IP against list --->
		<cfset recordIP = recordIPaddress(newIP)>
		
        <cfif recordIP EQ 1>
        	<cfset ipBlocker = 1>
        <cfelse>
        	<cfset ipBlocker = 0>
        </cfif>
        
        <cfcatch type="any">
            <cfmail to="ismonitor@bcchf.ca" from="donations@bcchf.ca"  subject="P3: Error - Checking IP data in processDonation" type="html" priority="3">
            Error recording backup data - checking the IP on a failed record. Priority Level 3.<br />
            A Donation Form was submitted, transaction DECLINED, but the processor ws unable to record the IP to check for subsequent fraudulent activity.<br />
            Transaction is completed; immediate action not required.<br />
            Message: #cfcatch.Message#
            Detail: #cfcatch.Detail#
            <cfdump var="#cfcatch#" label="catch">
            <cfdump var="#form#" hide="POST_CARD_NUMBER,POST_CVV,FIELDNAMES,POST_DOLLARAMOUNT,js_bcchf_cardnumber,js_bcchf_cvv" label="transaction">
            </cfmail>
        </cfcatch>
        </cftry>
        
        
		<!--- END of NOT APPROVED AREA --->        
        <!----------------------------------- --------------------------------------> 
        <!--- will return exact message for display to the user ---->   
        
        
    <cfelse>
    <!--- charge approved --->
    
    	<cfset chargeAproved = 1>
        <cfset returnMSG = 'charging-approved'>
        
    	<!--- record transaction information 
			
			1. Dump content of form to txt file
			2. Insert core transaction information into db
				- Transaction Information
				- Donor Information
				- SHP tables if necessary
			3. Update additional information
			4. Update tribute information
		
		--->
        
        <!--- try to remove IP from blocker trace --->
        <cftry>
        
        <cfset removeIP = removeIPaddress(newIP)>
        
        <cfcatch type="any">
        
        <cfmail to="ismonitor@bcchf.ca" from="error@bcchf.ca" subject="P3: Error - Removing IP from blocker trace in processDonation" type="html" priority="3">
        Error removing IP from blocker trace table. Priority Level 3.<br />
        A Donation Form was submitted, transaction APPROVED, but the processor ws unable to update the IP table to check for subsequent fraudulent activity.<br />
        Transaction is completed; immediate action not required.<br />
        Message: #cfcatch.Message#
        Detail: #cfcatch.Detail#
        <cfdump var="#cfcatch#" label="catch">
        <cfdump var="#form#" hide="POST_CARD_NUMBER,POST_CVV,FIELDNAMES,js_bcchf_cardnumber,js_bcchf_cvv,bcchf_cvv,bcchf_cc_number" label="transaction">
        </cfmail>
        
        </cfcatch>
        </cftry>
        
        <!--- try and record the transaction details in a flat txt file --->
        <cftry>
        
			<!--- directories --->
            <cfset monthlyDumpDirectory = DateFormat(Now(), 'mm-yy')>
            <Cfset dailyDumpDirectory = DateFormat(Now(), 'DD')>
            
            <cfset dumpDirectory = "#APPLICATION.WEBLINKS.File.service#\transactions\#monthlyDumpDirectory#\#dailyDumpDirectory#\">
            
            <!--- check if directory exists --->
            <cfif DirectoryExists(dumpDirectory)>
                <!--- directory exists - we are all good --->
            <cfelse>
                <!--- need to create directory --->
                <cfdirectory directory="#dumpDirectory#" action="create">
                        
            </cfif>
            
            <!--- add timestamp to file --->
            <Cfset append = "#DateFormat(Now())#---#TimeFormat(Now(), 'HH-mm-ss.l')#">
            
            <!--- dump form to file --->
            <!--- hide PCI fields --->
            <cfdump var="#form#" output="#dumpDirectory#bcchildren_full_donation_dump_date-#append#.txt" hide="POST_CARD_NUMBER,POST_CVV,FIELDNAMES,POST_DOLLARAMOUNT,js_bcchf_cardnumber,js_bcchf_cvv" type="html">
        
    	<cfcatch type="any">
        
        <cfmail to="ismonitor@bcchf.ca" from="error@bcchf.ca" subject="P3: Error - Recording donation form data in processDonation" type="html" priority="3">
        Error recording backup data - trying to create txt file of transaction. Priority Level 3.<br />
        A Donation Form was submitted, transaction APPROVED, but the donation form record was unable to be saved in dumpDirectory.<br />
        Transaction is permitted to proceed; immediate action not required.<br />
        Message: #cfcatch.Message#
        Detail: #cfcatch.Detail#
        <cfdump var="#cfcatch#" label="catch">
        <cfdump var="#form#" hide="POST_CARD_NUMBER,POST_CVV,FIELDNAMES,js_bcchf_cardnumber,js_bcchf_cvv,bcchf_cvv,bcchf_cc_number" label="transaction">
        </cfmail>
        
        </cfcatch>
        </cftry>
        
        <!--- Parse exact rqst_CTR for exact time --->
        <cftry>
			<cfset DTindex = REFIND("DATE/TIME", rqst_CTR) + 14>
            <cfset DT = Mid(rqst_CTR, DTindex, 18)>
            <cfset exact_odbcDT = CreateODBCDateTime(DT)>
        <cfcatch type="any">
			<cfset exact_odbcDT = pty_Date>
        </cfcatch>
        </cftry>
        
        <!--- Try to Insert Successful Record Into Database --->
        <cftry>
        
        <!--- encrypt card data --->
        <cfset encrptedCardData = encrptCard(post_card_number, hiddenDonationType)>
        
        <!--- Successful Record Struct --->
        <cfset tSuccessRecord = {
			tUUID = variables.newUUID,
			tDollar = post_dollaramount,
			tAdv = giftAdvantage,
			tTax = giftTaxable,
			tRType = receipt_type,
			tSource = donation_source,
			eSource = ePhilSRC,
			tENC = encrptedCardData,
			tCard = {
				cName = post_cardholdersname,
				eXm = post_expiry_month,
				eXy = post_expiry_year
			},
			tDonor = {
				dTitle = pty_title,
				dFname = pty_fname,
				dMname = pty_miname,
				dLname = pty_lname,
				dCname = pty_companyname,
				dTaxTitle = pty_tax_title,
				dTaxFname = pty_tax_fname,
				dTaxMname = pty_miname,
				dTaxLname = pty_tax_lname,
				dTaxCname = pty_tax_companyname,
				dAddress = {
					aOne = ptc_address,
					aTwo = ptc_addTwo,
					aCity = ptc_city,
					aProv = ptc_prov,
					aPost = ptc_post,
					aCountry = ptc_country
				},
				dEmail = ptc_email,
				dPhone = ptc_phone
			},
			tType = gift_type,
			tFreq = gift_frequency,
			tNotes = gift_notes,
			tTType = pty_tax,
			tFreqDay = gift_day,
			tSHP = {
				tAdd = HeroDonateAdd,
				tToken = hiddenEventToken,
				tCampaign = hiddenEventCurrentYear,
				tTeamID = hiddenTeamID,
				tSupID = hiddenSupID,
				tDname = DName,
				tStype = hiddentype,
				tSmsg = Message,
				tSshow = Show
			},
			tJD = {
				Pins = RunnerPin,
				Buttons = RunnerButton,
				BBQ = RunnerBBQ,
				BBQl = jdBBQl,
				cFriday = RunnerFriday
			}
			
		} />
        
        <cfset tSRec = SerializeJSON(tSuccessRecord)>
        
        <cfset tSSUCrec = recordSuccAttempt(tSRec, variables.newUUID)>
        
        
        <!--- DEPRECIATE: bcchf_bcchildren -- transaction data in tblDonation --->
        <CFQUERY datasource="#APPLICATION.DSN.transaction#" name="insert_record" dbtype="ODBC">
        INSERT INTO tblDonation (dtnDate, exact_date, dtnAmt, dtnBenefit, dtnReceiptAmt, dtnReceiptType, dtnBatch, dtnSource, post_cardholdersname, post_card_number, post_expiry_month, post_expiry_year, post_card_type, DEK_ID, post_ExactID, rqst_transaction_approved, rqst_authorization_num, rqst_dollaramount, rqst_CTR, rqst_sequenceno, rqst_bank_message, rqst_exact_message, rqst_formpost_message, rqst_AVS, pge_UUID, dtnIP, dtnBrowser) 
        VALUES (#pty_Date#, #exact_odbcDT#, '#post_dollaramount#', '#giftAdvantage#', '#giftTaxable#', '#receipt_type#', 'Online', '#donation_source#', '#post_cardholdersname#', '#encrptedCardData.ENCDATA#', '#post_expiry_month#', '#post_expiry_year#', '#encrptedCardData.ENCTYPE#', #encrptedCardData.ENCDEKID#, 'A00063-01', '#rqst_transaction_approved#', '#rqst_authorization_num#', '#rqst_dollaramount#', '#rqst_CTR#', '#rqst_sequenceno#', '#rqst_bank_message#', '#rqst_exact_message#', '#rqst_formpost_message#', '#rqst_AVS#', '#variables.newUUID#', '#newIP#', '#newBrowser#') 
        </CFQUERY>
        
        <!--- we want the ID from tblDonation for the tax receipt --->
        <cfquery name="selectID" datasource="#APPLICATION.DSN.transaction#">
        SELECT dtnID FROM tblDonation WHERE pge_UUID = '#variables.newUUID#'
        </cfquery>
        

        <!--- new method for new receipts --->
		<cfif selectID.dtnID GTE 200000>
            <cfset receiptNumber = selectID.dtnID + 1100000>
        <cfelse>
            <cfset receiptNumber = selectID.dtnID + 800000>
        </cfif>
        
        
        <!--- if the try block fails --->
        <!--- send email with details to isbcchf --- log transaction --->
        <cfcatch type="any">
			<cfmail to="ismonitor@bcchf.ca" from="error@bcchf.ca" subject="P2: Error - Recording donation transaction data in processDonation" type="html" priority="2">
            Error recording database data into tblDonation. Priority Level 2.<br />
            A Donation Form was submitted, transaction APPROVED, but the donation was not recorded in the database.<br />
            Transaction is permitted to proceed; immediate action not required, unless multiple errors of this nature start to be thrown.<br />
            Message: #cfcatch.Message#
            Detail: #cfcatch.Detail#
            <cfdump var="#cfcatch#" label="catch">
            <cfdump var="#form#" hide="POST_CARD_NUMBER,POST_CVV,FIELDNAMES,POST_DOLLARAMOUNT,js_bcchf_cardnumber,js_bcchf_cvv">
            </cfmail>
        </cfcatch>
        </cftry>
        
      
        <!--- DEPRECIATE: bcchf_donationGeneral -- donor data in tblGeneral --->
        <cftry>
        
        <cfif gift_type EQ 'REMAX'>
        	<cfif donation_type EQ 'Personal'>
            	<cfset transEventCode = 'TCON-RE/MAX MHP'>
            <cfelseif donation_type EQ 'Corporate'>
            	<cfset transEventCode = 'TCON-RE/MAX Other'>
            <cfelse>
        		<cfset transEventCode = ''>
            </cfif>
        <cfelse>
        	<cfset transEventCode = ''>
        </cfif>
        
        <!--- insert basic info and update later with other info --->
        <!--- donor information --->
        <CFQUERY datasource="#APPLICATION.DSN.general#" name="insert_record">
        INSERT INTO tblGeneral (pty_date, exact_date, pty_title, pty_fname, pty_miname, pty_lname, pty_companyname, ptc_address, ptc_add_two, ptc_city, ptc_prov, ptc_post, ptc_country, ptc_email, ptc_phone, pty_tax_title, pty_tax_fname, pty_tax_lname, pty_tax_companyname, gift, gift_Advantage, gift_Eligible, gift_type, gift_frequency, gift_notes, rqst_authorization_num, pty_tax, POST_REFERENCE_NO, rqst_sequenceno, gift_day, JD_Pin, JD_Button, pge_UUID, receipt_type, EventCode) 
        VALUES (#pty_date#, #exact_odbcDT#, '#pty_title#', '#pty_fname#', '#pty_miname#', '#pty_lname#',  '#pty_companyname#', '#ptc_address#', '#ptc_addTwo#', '#ptc_city#', '#ptc_prov#', '#ptc_post#', '#ptc_country#', '#ptc_email#', '#ptc_phone#', '#pty_tax_title#', '#pty_tax_fname#', '#pty_tax_lname#', '#pty_tax_companyname#', '#post_dollaramount#', '#giftAdvantage#', '#giftTaxable#', '#gift_type#', '#gift_frequency#', '#gift_notes#', '#rqst_authorization_num#', '#pty_tax#', '#rqst_sequenceno#', '#rqst_sequenceno#', '#gift_day#', '#pinsPurchased#',  '#buttonsPurchased#', '#variables.newUUID#', '#ePhilSRC#', '#transEventCode#')
        </CFQUERY>
        
        <!--- if the try block fails --->
        <!--- send email with details to isbcchf --- log transaction --->
        <cfcatch type="any">
			<cfmail to="ismonitor@bcchf.ca" from="error@bcchf.ca" subject="P2: Error - Recording donation transaction data in processDonation" type="html" priority="2">
            Error recording database data into tblGeneral. Priority Level 2.<br />
            A Donation Form was submitted, transaction APPROVED, but the donation was not recorded in the database.<br />
            Transaction is permitted to proceed; immediate action not required, unless multiple errors of this nature start to be thrown.<br />
            Message: #cfcatch.Message#
            Detail: #cfcatch.Detail#
            <cfdump var="#cfcatch#" label="catch">
            <cfdump var="#form#" hide="POST_CARD_NUMBER,POST_CVV,FIELDNAMES,POST_DOLLARAMOUNT,js_bcchf_cardnumber,js_bcchf_cvv">
            </cfmail>
        </cfcatch>
        </cftry>
                
        
        <!--- check URL for email referal --->
        <cftry>
        
        <!--- lookup email and add note that donation has been made --->
        <cfif IsDefined('emailReferal') AND emailReferal NEQ ''>
        
        	<cfset eRefUpdate = checkEmailReff(emailReferal, variables.newUUID)>
        
        </cfif>
        
        <cfcatch type="any">

        </cfcatch>
        </cftry>
        

        <!--- DEPRECIATE: try to Insert into Hero_Donate if necessary --->
		<cftry>
        
        <!--- ANOM Invoice ? --->
        <cfif hiddenTributeType EQ 'invoice'>
        <!--- ANOM Invoice Payment --->
			<cfif hiddenGiftType EQ 'ANOM'>
            
                <!--- ANOM INVOICE --->
                <cftry>
                
                <!--- get the payment ID to update invoice table --->
                <cfquery name="selectTgenTwoID" datasource="#APPLICATION.DSN.general#">
                SELECT generalID FROM tblGeneral WHERE pge_UUID = '#variables.newUUID#'
                </cfquery>
                
                
                <cfquery name="updateInvoice" datasource="#APPLICATION.DSN.Superhero#">
                UPDATE Hero_Registration
                SET 	Reg_auth_num = '#rqst_authorization_num#',
                        Reg_Seq_num = '#rqst_sequenceno#',
                        Reg_MemSuppID = #hiddenSupID#,
                        Reg_tGenTWOID = #selectTgenTwoID.generalID#
                WHERE SupID = #hiddenSupID# AND RegEvent = 'ANOM' AND RegYear = 2013
                </cfquery>
                
                <!--- we need to split the donation amounts --->
                <cfif hiddenTeamID EQ 6077>
                	<!--- sponsor --->
                    <!--- no split - no receipt required --->
                    
                    <!--- Could have an ANOM AWK receipt in this scenario --->
                    <!--- check for hiddenTributeType = 'invoice' --->
                    <cfset receipt_type = 'AWK'>
                    
                    
                <cfelseif hiddenTeamID EQ 6078>
                	<!--- guest --->
                    <!--- split doantion and send receipt --->
                    <!--- ADVANTAGE = #of tickets * 150 --->
                    
                    
                <cfelse>
                </cfif>
                	
                
                <cfcatch type="any">
                
                <cfmail to="csweeting@bcchf.ca" from="donations@bcchf.ca" subject="ANOM invoice update failure">
                
                Error recording ANOM Invoice
                Message: #cfcatch.Message#
                Detail: #cfcatch.Detail#
                <cfdump var="#cfcatch#" label="catch">
                <cfdump var="#form#" hide="POST_CARD_NUMBER,POST_CVV,FIELDNAMES,POST_DOLLARAMOUNT,js_bcchf_cardnumber,js_bcchf_cvv">
                
                </cfmail>
                
                </cfcatch>
                </cftry>
            
            
            
            </cfif>
        </cfif>
        
        
        <cfif HeroDonateAdd EQ 1>
        	<!--- add to hero donate --->
            <!--- multiply monthly amounts * 12 --->
            
            <cfif hiddenDonationType EQ 'monthly'>
				<cfset Hero_Donate_Amount = rqst_dollaramount><!---  * 12 --->
            <cfelse>
				<cfset Hero_Donate_Amount = rqst_dollaramount>
            </Cfif> 
                        
            
            <!--- insert into hero_donate 
            <cfquery name="insertHeroDonation" datasource="#APPLICATION.DSN.Superhero#">
            INSERT INTO Hero_Donate (Event, Campaign, TeamID, Name, Type, Message, Show, DonTitle, DonFName, DonLName, DonCompany, Email, don_date, rqst_authorization_num, Amount, SupID, POST_REFERENCE_NO, JDPins, JDButtons, pge_UUID, AddDate, UserAdd, LastChange, LastUser) 
            VALUES ('#hiddenEventToken#', #hiddenEventCurrentYear#, #hiddenTeamID#, '#DName#', '#hiddentype#', '#Message#', #Show#, '#pty_title#', '#pty_fname#', '#pty_lname#', '#pty_companyname#', '#ptc_email#', #pty_Date#, '#rqst_authorization_num#', #Hero_Donate_Amount#, #hiddenSupID#, '#rqst_sequenceno#', #RunnerPin#, #RunnerButton#, '#variables.newUUID#', #pty_Date#, 'Online', #pty_Date#, 'Online')
            </cfquery>--->
                   
        </cfif>
        
        
        <!--- if the try block fails --->
        <!--- send email with details to isbcchf --- log transaction --->
        <cfcatch type="any">
			<cfmail to="csweeting@bcchf.ca" from="error@bcchf.ca" subject="error recording transaction data" type="html">
            Error recording database data into Hero_Donate
            Message: #cfcatch.Message#
            Detail: #cfcatch.Detail#
            <cfdump var="#cfcatch#" label="catch">
            </cfmail>
        </cfcatch>
        </cftry>
        
        
        <!--- try and update the rest of the transaction details --->
        <!--- Additional Information --->
        <cftry>
            
            <cfset adInfo = {
				iSecurity = info_securities,
				iWill = info_will,
				iLife = info_life,
				iTrust = info_trusts,
				iRRSP = info_RRSP,
				iWillInclude = info_willinclude,
				iLifeInclude = info_lifeinclude,
				iRSPinclude = info_RSPinclude,
				SOC_subscribe = SOC_subscribe,
				news_subscribe = news_subscribe,
				AR_subscribe = AR_subscribe,
				iWhere = info_where,
				iPastDonor = donated_before,
				gPledgeDet = gift_pledge_det
				
			} />
            
            <cfset addInfo = SerializeJSON(adInfo)>
            
            <cfset tSSUCadd = recordSuccAdd(addInfo, variables.newUUID)>
            
            
            <!--- addadditional information section --->
            <cfquery name="updateAddInfo" datasource="#APPLICATION.DSN.general#">
            UPDATE tblGeneral
            SET	info_where = '#info_where#', 
                donated_before = '#donated_before#',
                TeamID = #hiddenTeamID#,
                SupID = #hiddenSupID#,
                JD_Pin = #RunnerPin#,
                JD_Button = #RunnerButton#,
                info_securities = '#info_securities#',
                info_will = '#info_will#', 
                info_life = '#info_life#', 
                info_RRSP = '#info_RRSP#', 
                info_trusts = '#info_trusts#', 
                info_willinclude = '#info_willinclude#', 
                info_lifeinclude = '#info_lifeinclude#', 
                info_RSPinclude = '#info_RSPinclude#',
                ptc_subscribe = '#news_subscribe#',
				SOC_subscribe = '#SOC_subscribe#', 
				AR_subscribe = '#AR_subscribe#', 
                gift_pledge_det = '#gift_pledge_det#'
            WHERE pge_UUID = '#variables.newUUID#'
            </cfquery>
        <!------>
        <cfcatch type="any">
        	<!--- allow continue --->
            <cfmail to="ismonitor@bcchf.ca" from="donations@bcchf.ca"  subject="P3: Error - Recording Additional Transaction Details in processDonation" type="html" priority="3">
            Error updating database data into tblGeneral. Priority Level 3.<br />
            A Donation Form was submitted, transaction APPROVED, critical transaction details recorded, but the processor ws unable to record the additional transaction details.<br />
            Transaction is completed; immediate action not required.<br />
            Message: #cfcatch.Message#
            Detail: #cfcatch.Detail#
            <cfdump var="#cfcatch#" label="catch">
            <cfdump var="#form#" hide="POST_CARD_NUMBER,POST_CVV,FIELDNAMES,POST_DOLLARAMOUNT,js_bcchf_cardnumber,js_bcchf_cvv" label="transaction">
            </cfmail>
                        
        </cfcatch>
        </cftry>
        
        
        <!--- pledge information --->
        <cftry>
        
        <!--- update donation general with appropriate info --->
        <cfif gPledge EQ 'Yes'>
        
        	<cfset plInfo = {
				pledge = 'yes',
				pDetail = gift_pledge_det,
				pDREID = gift_pledge_DonorID
			}/ >
            
            <cfset plInfoJSON = SerializeJSON(plInfo)>
            
            <cfset tSSUCpl = recordSuccPledge(plInfoJSON, variables.newUUID)>        
        
			<!--- update tblGeneral with tribute data --->
            <cfquery name="updatePledgeData" datasource="#APPLICATION.DSN.general#">
            UPDATE tblGeneral
            SET	ConstitID = '#gift_pledge_DonorID#',
            gift_pledge = 'yes'
            WHERE pge_UUID = '#variables.newUUID#'
            </cfquery>
        
        
        </cfif>
        
        
        <!--- if the try block fails --->
        <!--- send email with details to isbcchf --- log transaction --->
        <cfcatch type="any">
        	<!--- allow continue --->
            <cfmail to="ismonitor@bcchf.ca" from="donations@bcchf.ca"  subject="P3: Error - Recording Pledge Details in processDonation" type="html" priority="3">
            Error updating pledge data into tblGeneral. Priority Level 3.<br />
            A Donation Form was submitted, transaction APPROVED, critical transaction details recorded, but the processor ws unable to record the pledge details.<br />
            Transaction is completed; immediate action not required.<br />
            Message: #cfcatch.Message#
            Detail: #cfcatch.Detail#
            <cfdump var="#cfcatch#" label="catch">
            <cfdump var="#form#" hide="POST_CARD_NUMBER,POST_CVV,FIELDNAMES,POST_DOLLARAMOUNT,js_bcchf_cardnumber,js_bcchf_cvv" label="transaction">
            </cfmail>
        </cfcatch>
        </cftry>
                
                
        <!--- tribute information --->
        <cftry>
        
        <!--- update donation general with appropriate info --->
        <cfif hiddenTributeType EQ 'hon' OR hiddenTributeType EQ 'mem'>
        
        
        <cfset tribInfo = {
				trbFname = trb_fname,
				trbLname = trb_lname,
				trbEmail = trb_email,
				trbAddress = trb_address,
				trbCity = trb_city,
				trbProv = trb_prov,
				trbPost = trb_post,
				srpFname = srp_fname,
				srpLname = srp_lname,
				trbCardfrom = trb_cardfrom,
				trbMsg = cleanTrbMessage,
				tribNotes = hiddenTributeType,
				cardSend = hiddenAWKtype
				
			} />
            
            <cfset tribInfoJSON = SerializeJSON(tribInfo)>
            
            <!--- <cfset tSSUCtrib = recordSuccTrib(tribInfoJSON, variables.newUUID)> --->
        
        <!--- update tblGeneral with tribute data --->
        <cfquery name="updateTributeData" datasource="#APPLICATION.DSN.general#">
        UPDATE tblGeneral
        SET	gift_tribute = 'yes',
        	trb_fname = '#trb_fname#',
        	trb_lname = '#trb_lname#', 
            <cfif hiddenAWKtype EQ 'email'>
            trb_email = '#trb_email#', 
            <cfelseif hiddenAWKtype EQ 'mail'>
            trb_address = '#trb_address#',
            <!--- trb_address two ?? --->
            trb_city = '#trb_city#',
            trb_prov = '#trb_prov#', 
            trb_postal = '#trb_post#',
            </cfif> 
            srp_fname = '#srp_fname#', 
            srp_lname = '#srp_lname#', 
            trb_cardfrom = '#trb_cardfrom#', 
            trb_msg = '#cleanTrbMessage#', 
            trib_notes = '#hiddenTributeType#',
            card_send = '#hiddenAWKtype#'
        WHERE pge_UUID = '#variables.newUUID#'
        </cfquery>
        
        
        </cfif>
        
        
        <!--- if the try block fails --->
        <!--- send email with details to isbcchf --- log transaction --->
        <cfcatch type="any">
        	<!--- allow continue --->
            <cfmail to="ismonitor@bcchf.ca" from="donations@bcchf.ca"  subject="P3: Error - Recording Tribute Details in processDonation" type="html" priority="3">
            Error updating tribute data into tblGeneral. Priority Level 3.<br />
            A Donation Form was submitted, transaction APPROVED, critical transaction details recorded, but the processor ws unable to record the tribute details.<br />
            Transaction is completed; immediate action not required.<br />
            Message: #cfcatch.Message#
            Detail: #cfcatch.Detail#
            <cfdump var="#cfcatch#" label="catch">
            <cfdump var="#form#" hide="POST_CARD_NUMBER,POST_CVV,FIELDNAMES,POST_DOLLARAMOUNT,js_bcchf_cardnumber,js_bcchf_cvv" label="transaction">
            </cfmail>
        </cfcatch>
        </cftry>
        
        
        <!--- try and setup ecard --->
        <cftry>
        <cfif gift_type EQ 'eCard'>
        <!--- get E card message info for tribute --->
        
        	<!--- ecard date --->
            <cftry>
            <cfset sendECardDate = CreateODBCDate(cardSend_date)>
            <cfcatch type="any">
            <cfset sendECardDate = pty_date>
            </cfcatch>
            </cftry>
            
            <!--- parse the sending date --->
			<cfset sendYear = DateFormat(sendECardDate, 'YYYY')>
			<cfset sendMonth = DateFormat(sendECardDate, 'MM')>
            <cfset sendDay = DateFormat(sendECardDate, 'DD')>
        
        	
			<!--- insert into ecard tables --->
            <CFQUERY datasource="#APPLICATION.DSN.Superhero#" name="insert_card">
            INSERT INTO eCard (CARDCREATEDATE, sendDate, sendYear, sendMonth, sendDay, sender, sendersemail, recipient, recipientsemail, message, card, occasion, sendActive, pge_UUID) 
            VALUES (#pty_date#, #sendECardDate#, #sendYear#, #sendMonth#, #sendDay#, '#cardSend_fname# #cardSend_lname#', '#cardSend_email#', '#cardRec_fname# #cardRec_lname#', '#cardRec_email#', '#URLEncodedFormat(eCardMessagehidden)#', '#eCard_image#', '#eCard_occasion#', 1, '#variables.newUUID#') 
            </CFQUERY>
    
    		<!--- strip html for download ---->
            <cfset cleanEcardMessage = REReplaceNoCase(eCardMessage,"<[^>]*>","","ALL")>
            
            <!--- update tblGeneral with ecard info --->
            <cfquery name="updateEcardData" datasource="#APPLICATION.DSN.general#">
            UPDATE tblGeneral
            SET	gift_tribute = 'yes',
                trb_fname = '#cardRec_fname#',
                trb_lname = '#cardRec_lname#', 
                trb_address = '#cardRec_email#', 
                srp_fname = '', 
                srp_lname = '', 
                trb_cardfrom = '#cardSend_fname# #cardSend_lname# #cardSend_email#', 
                trb_msg = '#cleanEcardMessage#', 
                trib_notes = 'eCard',
                card_send = 'eCard'
            WHERE pge_UUID = '#variables.newUUID#'
            </cfquery>
            
            
            <cfif eCard_image EQ 'holiday7.png'
				OR eCard_image EQ 'holiday8.png'
				OR eCard_image EQ 'holiday9.png'>
            	
                <cfset TeamID = 7666>
            <cfelse>
            	<cfset TeamID = 0>
            </cfif>
            
            <!--- also, insert into hero_Donate --->
        	<cfquery name="insertHeroDonation" datasource="#APPLICATION.DSN.Superhero#">
            INSERT INTO Hero_Donate (Event, Campaign, TeamID, Name, Type, Message, Show, DonTitle, DonFName, DonLName, Email, don_date, rqst_authorization_num, Amount, SupID, POST_REFERENCE_NO, pge_UUID, AddDate, UserAdd, LastChange, LastUser) 
            VALUES ('eCard', 0, #TeamID#, '#cardSend_fname# #cardSend_lname#', '#eCard_occasion#', '#eCard_image#', 0, '#pty_title#', '#pty_fname#', '#pty_lname#', '#ptc_email#', #pty_Date#, '#rqst_authorization_num#', #rqst_dollaramount#, 0, '#rqst_sequenceno#', '#variables.newUUID#', #pty_Date#, 'Online', #pty_Date#, 'Online')
            </cfquery>
        
        
        
        
        </cfif>
        
        
        <!--- if the try block fails --->
        <!--- send email with details to isbcchf --- log transaction --->
        <cfcatch type="any">
        	<!--- allow continue --->
            <cfmail to="ismonitor@bcchf.ca" from="donations@bcchf.ca"  subject="P2: Error - Recording eCard Details in processDonation" type="html" priority="2">
            Error recording eCard data into tblGeneral. Priority Level 2.<br />
            A Donation Form was submitted, transaction APPROVED, critical transaction details recorded, but the processor was unable to record the eCard details.<br />
            Transaction is completed; immediate action not required.<br />
            ecard details need to be reinserted for completion of donor requested ecard.<br />
            Message: #cfcatch.Message#
            Detail: #cfcatch.Detail#
            <cfdump var="#cfcatch#" label="catch">
            <cfdump var="#form#" hide="POST_CARD_NUMBER,POST_CVV,FIELDNAMES,POST_DOLLARAMOUNT,js_bcchf_cardnumber,js_bcchf_cvv" label="transaction">
            </cfmail>
        </cfcatch>
        </cftry>
        
        
        <!--- ---------------------------- end of database processing -------------------------------------------- --->
        <!--- ---------------------------- confirmation email process -------------------------------------------- --->
        <cftry>
        

        <!--- 
			1. Transaction info to DS/IS 
				- include aahui@bcchf.ca if pledge
				- include asafy@bcchf.ca,lmador@bcchf.ca if GT 10K
				
			2. Notification to Donor (may need to load event template)
				This email and receipt is now sent from confirmation page....
				the donor email gets activated once the confirmationpage has been served
				
			3. if Tribute - Tribute Notification email
			
			4. if ICE - Notification to 
				1. Supporter 
				2. Team Captain (Event Org) 
				3. TODO: ?? R.M. (cherie / jessica /...)
				
			5. if WOT - Notification to 
				1. Supporter (Team Captain)
				2. Honouree (Team Member) 
				3. NOK (Team Member)
				4. R.M. - include jjhooty@bcchf.ca;jclark@bcchf.ca
					2013-01-07 add acrowther, remove jjhooty
					2014-03-03 remove jclark
			
			6. if Jeans Day - Notification to 
				1. Champion
				--- if general or large amount purchased
					2. RM (jeansday@bcchf.ca)
				--- If donation meets criteria for receipt follow up
					3. DS
			
			
			7. if SHP - Notification to 
				1. Supporter 
				2. Team Captain 
				3. R.M. & Event Orgs
				
			8. if eCard - Notification to R.M.
			--->
        
        
        <!---- 1. FIRST TO FOUNDATION IN ALL CASES --->
        <cfset FDNnotifyEmail = FDNnotifyEmail(variables.newUUID)>
		
        <!---- 2. donation confirmation message 
		message being triggered from completed donation page ---------
		<cfset DonorEmailThanks = DonorEmailThanks(variables.newUUID)> --->
        
		<!--- 3. if Tribute - Tribute Notification email --->
        <cfif hiddenAWKtype EQ 'email' 
			AND (hiddenTributeType EQ 'hon' OR hiddenTributeType EQ 'mem')>
        
        	<cfset TribAwkEmail = TribAwkEmail(variables.newUUID)>
        
        </cfif>
    
    
		<!--- 	4. if ICE - Notification to 
			1. Supporter 3
			2. Team Captain (Event Org)   
			TODO: RM: (cherie - jessica ...) --->
        <cfif gift_type EQ 'ICE'>
        
        	<cfset ICEnotifyEmail = ICEnotifyEmail(variables.newUUID)>
        
        </cfif>
        
        
        <!--- 	5. if WOT - Notification to 
			1. Supporter (Team Captain)
			2. Honouree (Team Member) 
			3. NOK (Team Member)
			4. R.M. - include acrowther@bcchf.ca;jclark@bcchf.ca
			 --->
        <cfif gift_type EQ 'WOT' AND (hiddenTributeType EQ 'hon-WOT' OR hiddenTributeType EQ 'mem-WOT')>
        
        	<cfset WOTnotifyEmail = WOTnotifyEmail(variables.newUUID)>
        
        </cfif>
        
        
        <!--- 	6. if Jeans Day - notification to
			1. Champion
			2. RM (jeansday@bcchf.ca)
			3. DS --->
			
        <cfif gift_type EQ 'JeansDay'>
        
        	<cfset JeansDayNotifyEmail = JeansDayNotifyEmail(variables.newUUID)>
        
        </cfif>
        
        
        <!--- 	7. if SHP - Notification to 
			1. Supporter 
			2. Team Captain 
			3. Event Orgs --->
        <!--- select Member and selectEventName are located in step 2 --->
        <cfif hiddenTributeType EQ 'event'>
        
			<!--- Send notification email to supporter --->
            <cfset supNotifyEmail = SHPnotifyEmail(variables.newUUID)>
        
        </cfif>
        
        
        <!--- 8. ecard notification to Angela --->
        <cfif gift_type EQ 'eCard'>
        
            <cfmail to="jyoung@bcchf.ca, tkilloran@bcchf.ca" from="bcchfds@bcchf.ca" subject="Ecard Purchase Made" type="html">
            An ecard purchase was just made online.<br />
            Details:<br />
            Occasion: #eCard_occasion#<br />
            Card: #eCard_image#<br />
            Send Date: #sendECardDate#<br />
            To: #cardRec_fname# #cardRec_lname#<br />
            From: #cardSend_fname# #cardSend_lname#<br />
            Purchase Amount: #DollarFormat(rqst_dollaramount)#<br />
            <br />
            <br />
            </cfmail>
        
        <!--- Set a marker ---
		<cfset frapi.trace( "Email to eCard RMs complete" )>--->
        </cfif>
       
       
		<cfcatch type="any">
        	
            <cfmail to="ismonitor@bcchf.ca" from="error@bcchf.ca" subject="P2: Error - Sending Donor Triggered Emails in processDonation" type="html" priority="2">
            Error sending donation emails. Priority Level 2.<br />
            A Donation Form was submitted, transaction APPROVED, but some of the donation emails were not sent.<br />
            There should be a specific message about which email failed<br />
            Transaction is complete; immediate action not required, unless multiple errors of this nature start to be thrown.<br />
            Message: #cfcatch.Message#
            Detail: #cfcatch.Detail#
            <cfdump var="#cfcatch#" label="catch">
            <cfdump var="#form#" hide="POST_CARD_NUMBER,POST_CVV,FIELDNAMES,POST_DOLLARAMOUNT,js_bcchf_cardnumber,js_bcchf_cvv">
            </cfmail>
            
        </cfcatch>
        </cftry>	
			
		<!--- ---------------------------- end of email processing    -------------------------------------------- --->

        <!--- send return message to browser window that the transaction is complete --->
        
        
        <!--- message about frequency  --->
        <cfset chargeMSG = gift_frequency>
        <!--- after inserting in DB and sending emails --->
        <cfset returnSuccess = 1>
        
    </cfif>
    <!--- ---------------------------- end of if charging approved  -------------------------------------------- --->


	<cftry>
	<cfif gift_type EQ 'Stories'>
		<cfset hiddenEventToken = 'Stories'>
    </cfif>
	<cfcatch type="any">
    </cfcatch>
    </cftry>
    
    <!--- return message --->
    <cfset ChargeAttmpt = {
		cAttempted = chargeAttempt,
		cApproved = chargeAproved,
		cMSG = chargeMSG,
		exact_respCode = exact_respCode,
		ipBlocker = ipBlocker,
		goodXDS = goodXDS
		} />

	<!--- this is the structure of the return message --->
    <cfset SHPdonationReturnMSG = {
	Success = returnSuccess,
	ChargeAttmpt = ChargeAttmpt,
	Message = returnMSG,
	EventToken = hiddenEventToken,
	UUID = variables.newUUID,
	tGenTwoID = tGenTwoID
	} />
    
    <cfreturn SHPdonationReturnMSG>


</cffunction>
<!--- End of main form processor ---- --------------------------------------------------------->



<!---- MOBILE FORM Processor ------------------------------------------------------------------------------>
<!--- some validation occurs before we hit this step --->
<!--- high level validation not required at this time --->
<!--- mixed results with this ... --- verifyClient="yes" --->
<cffunction name="submitMobileDonationForm" access="remote" >
    
	<!--- donor information --->
    <cfargument name="js_bcchf_firstname" type="string" required="yes">
    <cfargument name="js_bcchf_lastname" type="string" required="yes">
    
    <cfargument name="js_bcchf_corpo_name" type="string" required="yes">
    
    <cfargument name="js_bcchf_address" type="string" required="yes">
    <cfargument name="ptc_addTwo" type="string" required="no">
    <cfargument name="js_bcchf_city" type="string" required="yes">
    <cfargument name="js_bcchf_country" type="string" required="yes">
    <cfargument name="js_bcchf_province" type="string" required="yes">
    <cfargument name="js_bcchf_postal" type="string" required="yes">
    <cfargument name="js_bcchf_email" type="string" required="yes">
    <cfargument name="js_bcchf_phone" type="string" required="no">
    
    <!--- tribute information --->
    <cfargument name="js_bcchf_honour" type="string" required="no">
    <cfargument name="js_bcchf_send_email" type="string" required="no">
    <cfargument name="js_bcchf_recepient_email" type="string" required="no">
    <cfargument name="trb_message" type="string" required="no">
    <cfargument name="trb_cardfrom" type="string" required="no">
    
    <!--- SHP event scroll details --->
    <cfargument name="hiddenEventToken" type="string" required="no">
    <cfargument name="hiddenEventCurrentYear" type="string" required="no">
    <cfargument name="hiddenTeamID" type="string" required="no">
    <cfargument name="hiddenSupID" type="string" required="no">
    <cfargument name="DName" type="string" required="no">
    <cfargument name="hiddentype" type="string" required="no">
    <cfargument name="Message" type="string" required="no">
    <cfargument name="Show" type="string" required="no">
    <cfargument name="ShowAnonymous" type="string" required="no">
    
    <!--- additional details --->
    <cfargument name="js_bcchf_gift_details" type="string" required="no">
    <cfargument name="info_where" type="string" required="no">
    
    <!--- subscriptions --->
    <cfargument name="news_subscribe" type="string" required="no">
    
    <!--- pledge details --->
    <cfargument name="gift_pledge_det" type="string" required="no">
    <cfargument name="js_bcchf_pledge_id" type="string" required="no"><!---  --->
    
    <!--- donation information --->
    <!--- gift type --->
    <cfargument name="hiddenGiftType" type="string" required="yes">
    <cfargument name="hiddenTributeType" type="string" required="yes">
	<!--- gift amount --->
    <cfargument name="hiddenGiftAmount" type="string" required="yes">
    <!--- Personal or Corporate - set tax values with this info --->
    <cfargument name="js_bcchf_donate_type" type="string" required="yes">
    <!--- indicated frequency --->
    <cfargument name="hiddenDonationType" type="string" required="yes">
    <!--- monthly day  not required for single --->
    <cfargument name="js_bcchf_bill_cycle" type="string" required="no">
    <!--- tribute type --->
    <!--- eCard for eCards - Pledge for Pledge --->
    <cfargument name="js_bcchf_gift_type" type="string" required="yes">
    
    <!--- tax receipt information --->
    <cfargument name="pty_tax" type="string" required="yes">
    <cfargument name="pty_ink" type="string" required="no">
    
    
    <!--- cardholder data --->
    <cfargument name="post_card_number" type="string" required="no">
    <cfargument name="post_expiry_month" type="string" required="no">
    <cfargument name="post_expiry_year" type="string" required="no">
    <cfargument name="post_cardholdersname" type="string" required="no">
    <cfargument name="post_CVV" type="string" required="no">
    
    <!--- email referal conditions --->
    <cfargument name="emailReferal" type="string" required="no">
    
    <!--- JeansDay Information --->
    <cfargument name="runnerPin" type="string" required="no">
    <cfargument name="runnerButton" type="string" required="no">
    
    
    <!--- SERVER Date at submission --->
    <cfif NOT IsDefined("pty_date")><cfset pty_date= "#Now()#"></cfif>
    
    <!--- create UUID to access info --->
    <cfset variables.newUUID=createUUID()>
    <!--- Recording IP Addresses  and Browser info of these transactions --->
	<cfset newIP = CGI.REMOTE_ADDR>
	<cfset newBrowser = CGI.HTTP_USER_AGENT> 
    <cfset ipBlocker = 0>
    
    <!--- set the source --->
	<cfset donation_source = 'Mobile Donation Form'>
    
    <!--- read ePhil Source --->
    <cfif IsDefined('ePhilanthropySource')>
    	<cfset ePhilSRC = ePhilanthropySource>
    <cfelse>
    	<cfset ePhilSRC = ''>
    </cfif>
    
    <!--- set transaction amount --->
    <cfset hiddenGiftAmount = REREPlace(hiddenGiftAmount, '[^0-9.]','','all')>
    <cfset post_dollaramount = hiddenGiftAmount>
    
    <!--- default setting is not adding to hero donate ---> 
    <cfset HeroDonateAdd = 0>
    
    <!--- successful variables --->
    <cfset chargeSuccess = 0>
    <cfset donationSuccess = 0>
    <cfset chargeAttempt = 0>
    <cfset chargeAproved = 0>
    <cfset chargeMSG = "">
    <cfset tGenTwoID = 0>
    
    <!--- construct return message --->
    <cfset returnSuccess = 0>
    <cfset returnMSG = 'beginAttempt'>
    <cfset exact_respCode = 0>
    
    <cfset PTY_TAX_ISSUER = 'BCCHF'>
    
    <cfset pty_tax_title = ''>
    <cfset pty_tax_fname = TRIM(js_bcchf_firstname)>
	<cfset pty_tax_lname = TRIM(js_bcchf_lastname)>
	<cfset pty_tax_companyname = TRIM(js_bcchf_corpo_name)>
    
    <!--- set gift type on form pre load --->
    <cfset gift_type = hiddenGiftType>
	
    <cfset pty_title = ''> 
	<cfset pty_fname = pty_tax_fname>
    <cfset pty_miname = ''>
    <cfset pty_lname = pty_tax_lname>
    
    <cfset pty_companyname = pty_tax_companyname>
    <cfset ptc_email = js_bcchf_email>
    
    <cfset ptc_address = js_bcchf_address>
    <cfset ptc_addtwo = ''>
    <cfset ptc_city = js_bcchf_city>
    <cfset ptc_post = js_bcchf_postal>
    <cfset ptc_prov = js_bcchf_province>
    <cfset ptc_country = js_bcchf_country>
    <cfset ptc_phone = js_bcchf_phone>
    
    <cfif hiddenDonationType EQ 'once'>
    	<cfset gift_frequency = 'Single'>
    <cfelse>
    	<cfset gift_frequency = 'Monthly'>
    </cfif>
    
    <cfif gift_frequency EQ 'once'>
    	<cfset gift_frequency = 'Single'>
    </cfif>
    
    <cfset gift_notes = js_bcchf_gift_details>
    
	<cfset post_expiry_date = '#post_expiry_month#/#post_expiry_year#'>
    
    <cfset trb_msgType =''>
    
    <!--- scrub some variables for db loading --->    
    <cftry>
    
    	<!--- corp / personal tax settings --->
		<cfif hiddenDonationPCType EQ 'corporate'>
            <!--- corporate donation --->
            <cfset pty_tax_title = "">
            <cfset pty_tax_fname = "">
            <cfset pty_tax_lname = "">
            <cfset pty_companyname = pty_tax_companyname>
        <cfelse>
            <!--- personal donation fields --->
            <cfset pty_title = pty_tax_title>
            <cfset pty_fname = pty_tax_fname>
            <cfset pty_lname = pty_tax_lname>
            <cfset pty_tax_companyname = "">
        </cfif>
            
        <!--- determine gift Day --->
        <cfif gift_frequency EQ 'monthly'>
            <cfif IsDefined('js_bcchf_bill_cycle')>
                <cfset gift_day = js_bcchf_bill_cycle>
            <cfelse>
                <cfset gift_day = 1>
            </cfif>
        <cfelse>
            <cfset gift_day = "">
        </cfif>
    	
        <!--- Tax Receipt options for processor ---->
        <!--- use receipt type for Ink/No Ink --->
        <!--- TODO: HK receipting options --->
        <!--- receipt types
			TAX = TAX RECEIPT
			AWK = AWKNOWLEDGMENT RECEIPT
			TAX-HK = Hong Kong 
			TAX-IF = Ink Friendly
			TAX-ANNUAL = Annual Receipt for monthly gift
			TAX-HK-ANNUAL = Annual Receipt for monthly gift on HK page
			NONE = None requested / ineligible
			--->
		
		<cfif pty_tax_issuer EQ 'BCCHF'>
        
			<cfif gift_frequency EQ 'Single'>
                <cfif pty_tax EQ "no">
                    <cfset receipt_type = 'NONE'>
                <cfelse>
                	<cfif IsDefined('pty_ink')>
                    	<cfif pty_ink EQ 'yes'>
                        	<cfset receipt_type = 'TAX-IF'>
                    	<cfelse>
                        	<cfset receipt_type = 'TAX'>
                    	</cfif>
                    <cfelse>
                    	<cfset receipt_type = 'TAX'>
                    </cfif>
                </cfif>
            <cfelse>
                <cfif pty_tax EQ "no">
                    <cfset receipt_type = 'NONE'>
                <cfelse>
                    <cfset receipt_type = 'TAX-ANNUAL'>
                </cfif>        
            </cfif>
        
        </cfif>

		<!--- legacy: receipt generator method
			- check for receipt status 
			- append 'no receipt' to frequency for no receipt--->
        <cfif pty_tax EQ "no">
			<cfset gift_frequency="#gift_frequency# - No Receipt">
        <cfelse>
        	<cfset gift_frequency="#gift_frequency#">
        </cfif>
        
        <cfif gift_frequency EQ 'single'>
        	<cfset gift_frequency = 'Single'>
        </cfif>
        
        <!--- FREQUENCY --->
        <cfif IsDefined('js_bcchf_bill_cycle')>
        	<cfset js_bcchf_bill_cycle = js_bcchf_bill_cycle>
        <cfelse>
        	<cfset js_bcchf_bill_cycle = ''>
        </cfif>
        
        
        <!--- add designation details to notes section --->
        <cfif IsDefined('hiddenDesignation') AND hiddenDesignation NEQ ''>
        
			<cfset gift_notes="designation:#hiddenDesignation# - #gift_notes#">
            
            <cfif gift_type EQ 'FOT'>
            <!--- FOT designation could be contained here --->
            
            	<cfif hiddenDesignation EQ '4210'>
                	<cfset hiddenTeamID = 4210>
                
                <cfelseif hiddenDesignation EQ '4211'>
                	<cfset hiddenTeamID = 4211>
                
                <cfelseif hiddenDesignation EQ '4212'>
                	<cfset hiddenTeamID = 4212>
                    
                <cfelseif hiddenDesignation EQ '4213'>
                	<cfset hiddenTeamID = 4213>
                    
                </cfif>
            
            
            <cfelseif gift_type EQ 'ChildLife'>
            <!--- ChildLife designation is contained here --->
            
                <cfset hiddenTeamID = hiddenDesignation>
                
                <cfif hiddenTeamID EQ ''>
                	<cfset hiddenTeamID = 0>
                </cfif>
                
                <cfif hiddenSupID EQ ''>
                	<cfset hiddenSupID = 0>
                </cfif>
                
                
                <!--- enter the supporter name in notes --->
                <cfif hiddenSupID EQ 0>
                <cfelse>
                
                <cfquery name="selectName" datasource="bcchf_Superhero">
                SELECT SupFName FROM Hero_Members 
                WHERE SuppID = #hiddenSupID#
                </cfquery>
                
                <cfset gift_notes="#selectName.SupFName# - #gift_notes#">
                
                </cfif>
                
                
                
                <!--- enter the tean name in designation notes --->
                <cfif hiddenTeamID EQ 0>
                
                	<cfset gift_notes="Specific Purpose:Unspecified - #gift_notes#">
                
                <cfelse>
                
                    <cfquery name="selectTeam" datasource="bcchf_Superhero">
                    SELECT TeamName FROM Hero_Team 
                    WHERE TeamID = #hiddenTeamID#
                    </cfquery>
                    
                    <cfset gift_notes="Specific Purpose:#selectTeam.TeamName# - #gift_notes#">
                
                
                </cfif>
                
            
            <cfelseif gift_type EQ 'HSBC'>
            <!--- HSBC designation could be contained here --->	
            	<cfif TransitNumber EQ 35216>
                <!--- other --->
                	<cfset hiddenSupID = 35216>
                    <cfset gift_notes="Other Transit Number:#TransitNumberOther# - #gift_notes#"> 
                <cfelse>
                	<cfset hiddenSupID = TransitNumber>
                    <cfset gift_notes="#gift_notes#"> 
                </cfif>
            
            </cfif>
            
            
        <cfelse>
			<cfset gift_notes="#gift_notes#">
        </cfif>
        
        <!--- Event Specific Database Actions --->
        <!--- Jeans Day - record button and pin information provided by user --->
        <cfif gift_type EQ 'JeansDay'>
        
        	<cfif runnerPin EQ ''>
        		<cfset pinsPurchased = 0>
            <cfelse>
            	<cfset pinsPurchased = runnerPin>
            </cfif>
            
            <cfif runnerButton EQ ''>
            	<cfset buttonsPurchased = 0>
        	<cfelse>
            	<cfset buttonsPurchased = runnerButton>
            </cfif>
            
        <cfelse>
        
        	<cfset pinsPurchased = 0>
            <cfset buttonsPurchased = 0>
        
        </cfif>
        
        <!--- Jeans Day - record button and pin information provided by user --->
        <cfif gift_type EQ 'JeansDay'>
        
        	<cfif runnerPin EQ ''>
        		<cfset pinsPurchased = 0>
                <cfset RunnerPin = 0>
            <cfelse>
            	<cfset pinsPurchased = runnerPin>
                <cfset runnerPin = runnerPin>
            </cfif>
            
            <cfif runnerButton EQ ''>
            	<cfset buttonsPurchased = 0>
                <cfset RunnerButton = 0> 
        	<cfelse>
            	<cfset buttonsPurchased = runnerButton>
				<cfset runnerButton = runnerButton> 
            </cfif>
            
            <cfset ticketsPurchased = 0>
			<cfset RunnerBBQ = 0>
            
        <cfelse>
        
        	<cfset pinsPurchased = 0>
            <cfset buttonsPurchased = 0>
            <cfset ticketsPurchased = 0>
            <cfset RunnerPin = 0>
			<cfset RunnerButton = 0>
            <cfset RunnerBBQ = 0> 
        
        </cfif>
        
        <!--- AWK receipt for BFK sunshine sponsor --->
        <cfif gift_type EQ 'BFK' AND hiddenTeamID EQ 8020>
        
            <cfset receipt_type = 'AWK'>
            
            <cfset giftAdvantage = post_dollaramount>
            <cfset giftTaxable = 0>
        
        <cfelse>
        
			<cfset giftAdvantage = 0>
            <cfset giftTaxable = post_dollaramount>
        
        </cfif>
		
        <!--- add to Hero_Donate Token --->
        <!--- I cannot remember why this is here ---
		 AND (hiddenTributeType EQ 'hon-WOT' OR hiddenTributeType EQ 'mem-WOT')
		 --->
        <cfif gift_type EQ 'WOT'>
        	<cfset HeroDonateAdd = 1>
        <cfelseif gift_type EQ 'ICE'>
        	<cfset HeroDonateAdd = 1>
        </cfif>
        
        <cfif hiddenTributeType EQ 'JeansDay'>
        	<cfset HeroDonateAdd = 1>
        <cfelseif hiddenTributeType EQ 'event'>
        	<!--- other SHP events --->
        	<cfset HeroDonateAdd = 1>
        </cfif>
        
        <!--- TYS options --->
        <cfif IsDefined('Show')>
            
			<cfif Show EQ 'Yes'>
				<cfset Show = 1>
			<cfelse>
				<cfset Show = 0>
			</cfif>
            
		<cfelse>
            
			<cfset Show = 0>
            
		</cfif>
        
        <!--- we want to insert first as anonymous - 
			donor updates the scroll on confirmation page --->
		<cfset DName = 'Anonymous'>
        <!--- 2013-03-01 Default now shows donor name
			until the donor changes it on the confirmation screen --->
		<cfset DName = '#pty_fname# #pty_lname#'>
        
        <!--- ChildLife Gift Notes copy to 'Message' field --->
		<cfif gift_type EQ 'ChildLife'>
			<cfset Message = gift_notes>
        </cfif>
        
        <cfif gift_type EQ 'General'>
        	<!--- enter donor as anonymous for scroll on new donaton form --->
			<cfset DName = 'Anonymous'>
        </cfif>
        
        <cfif gift_frequency EQ 'monthly' OR gift_frequency EQ 'monthly - no receipt'>
			<cfset Hero_Donate_Amount = post_dollaramount><!---  * 12 --->
        <cfelse>
            <cfset Hero_Donate_Amount = post_dollaramount>
        </Cfif> 

		<!--- additional info --->
        <cfif NOT IsDefined("js_bcchf_allow_email")><cfset js_bcchf_allow_email = ""></cfif>
		<CFIF js_bcchf_allow_email EQ ""><CFSET js_bcchf_allow_email = " "></CFIF>
            
		<!--- if news subscribe is yes - set SOC and AR to yes --->
		<cfif js_bcchf_allow_email EQ 1>
			<cfset SOC_subscribe = 1>
            <cfset news_subscribe = 1>
            <cfset AR_subscribe = 0>
        <cfelse>
         	<cfset SOC_subscribe = 0>
            <cfset news_subscribe = 0>
            <cfset AR_subscribe = 0>
        </cfif>

		<!--- pledge details --->
        <cfif gift_type EQ 'Pledge'>
        
        	<cfset gPledge = 'Yes'>
            <cfset gift_pledge_DonorID =''>
            <cfset gPledgeDeatil = js_bcchf_pledge_id>
            
        <cfelse>
        
        	<cfif js_bcchf_gift_type EQ 'pledge'>
            
            	<cfset gPledge = 'Yes'>
				<cfset gift_pledge_DonorID =''>
                <cfset gPledgeDeatil = js_bcchf_pledge_id>
                            
            <cfelse>
            
            	<cfset gPledgeDeatil = ''>
            	<cfset gift_pledge_DonorID =''>
            	<cfset gPledge = 'No'>
            
            </cfif>
        
        </cfif>

		<!--- tribute details --->
        <cfif JS_BCCHF_GIFT_TYPE EQ 'honour' OR JS_BCCHF_GIFT_TYPE EQ 'memory'>
            
            <cfset gTribute = 'yes'>
            
			<cfif JS_BCCHF_GIFT_TYPE EQ 'honour'>
                <cfset hiddenTributeType = 'hon'>
            <cfelseif JS_BCCHF_GIFT_TYPE EQ 'memory'>
                <cfset hiddenTributeType = 'mem'>
            </cfif>
            
            <cfif IsDefined('JS_BCCHF_SEND_EMAIL')>
            
				<cfif JS_BCCHF_SEND_EMAIL EQ 'no'>
                    <cfset hiddenAWKtype ='No'>
                <cfelse>
                    <cfset hiddenAWKtype ='email'>       
                </cfif>
            
            <cfelse>
            
            	<cfset hiddenAWKtype ='No'>
            
            </cfif>
            
            <cfset trb_fname = ''>
            <cfset trb_lname = '#JS_BCCHF_HONOUR#'>
            <cfset trb_email = '#js_bcchf_recepient_email#'>
            <cfset trb_cardfrom = '#pty_fname# #pty_lname#'>
           
            
        <cfelse>
        	
            <cfset hiddenAWKtype ='No'>
            <!--- <cfset hiddenTributeType = JS_BCCHF_GIFT_TYPE> --->
            <cfset hiddenTributeType = hiddenTributeType>
            <cfset trb_fname = ''>
            <cfset trb_lname = ''>
            <cfset trb_email = ''>
            <cfset trb_cardfrom = ''>
        	<cfset gTribute = 'no'>
                
		</cfif>

	<cfcatch type="any">
    
    <cfmail to="csweeting@bcchf.ca" from="error@bcchf.ca" subject="error scrubbing donation form data" type="html">
    Error scrubbing donation form data
    Message: #cfcatch.Message#
    Detail: #cfcatch.Detail#
    <cfdump var="#cfcatch#" label="catch">
    <cfdump var="#form#" hide="POST_CARD_NUMBER,POST_CVV,FIELDNAMES,js_bcchf_cardnumber,js_bcchf_cvv,bcchf_cvv,bcchf_cc_number" label="transaction">
    </cfmail>
    
    </cfcatch>
    </cftry>
    
    
    <!--- begin processing transaction --->
    
    <!--- attempt charge --->
	<cfset chargeAttempt = 1>
    <cfset attemptCharge = 1>
    <cfset returnMSG = 'beginAttempt-charging'>
    
    
    <!--- Trying to record - Attempt Record --->
    <cftry>
    
    	<cfset tAttemptRecord = {tDate = pty_date, 
								tUUID = variables.newUUID,
								tDonor = {
									dTitle = pty_title,
									dFname = pty_fname,
									dMname = pty_miname,
									dLname = pty_lname,
									dCname = pty_companyname,
									dTaxTitle = pty_tax_title,
									dTaxFname = pty_tax_fname,
									dTaxMname = pty_miname,
									dTaxLname = pty_tax_lname,
									dTaxCname = pty_tax_companyname,
									dAddress = {
										aOne = ptc_address,
										aTwo = ptc_addTwo,
										aCity = ptc_city,
										aProv = ptc_prov,
										aPost = ptc_post,
										aCountry = ptc_country
									},
									dEmail = ptc_email,
									dPhone = ptc_phone
								},
								tGift = post_dollaramount,
								tGiftAdv = giftAdvantage,
								tGiftTax = giftTaxable,
								tType = gift_type,
								tFreq = gift_frequency,
								tNotes = gift_notes,
								tSource = donation_source,
								eSource = ePhilSRC,
								tBrowser = {
									bUAgent = newBrowser,
									bName = uabrowsername,
									bMajor = uabrowsermajor,
									bVer = uabrowserversion,
									bOSname = uaosname,
									bOSver = uaosversion,
									dDevice = uadevicename,
									bDtype = uadevicetype,
									bDvend = uadevicevendor,
									bIP = newIP
								},
								tTType = pty_tax,
								tFreqDay = gift_day,
								tSHP = {
									tAdd = HeroDonateAdd,
									tToken = hiddenEventToken,
									tCampaign = hiddenEventCurrentYear,
									tTeamID = hiddenTeamID,
									tSupID = hiddenSupID,
									tDname = DName,
									tStype = hiddentype,
									tSmsg = Message,
									tSshow = Show,
									Hero_Donate_Amount = Hero_Donate_Amount
								},
								tJD = {
									Pins = RunnerPin,
									Buttons = RunnerButton,
									BBQ = RunnerBBQ,
									BBQl = '',
									cFriday = 0
								},
								tFORM = {
									hiddenDonationPCType = js_bcchf_donate_type,
									hiddenDonationType = gift_frequency,
									hiddenFreqDay = hiddenFreqDay,
									hiddenGiftAmount = hiddenGiftAmount,
									donation_type = js_bcchf_donate_type,
									gift_frequency = js_bcchf_donation_frequency,
									gift_day = js_bcchf_bill_cycle,
									hiddenTributeType = hiddenTributeType,
									gift_tributeType = js_bcchf_gift_type
									
								},
								adInfo = {
									iSecurity = '',
									iWill = '',
									iLife = '',
									iTrust = '',
									iRRSP = '',
									iWillInclude = '',
									iLifeInclude = '',
									iRSPinclude = '',
									SOC_subscribe = SOC_subscribe,
									news_subscribe = news_subscribe,
									AR_subscribe = AR_subscribe,
									iWhere = '',
									iPastDonor = '',
									gPledgeDet = gPledgeDeatil,
									gPledgeDREID = gift_pledge_DonorID,
									gPledge = gPledge
								},
								tribInfo = {
									trbFname = trb_fname,
									trbLname = trb_lname,
									trbEmail = trb_email,
									trbAddress = '',
									trbCity = '',
									trbProv = '',
									trbPost = '',
									srpFname = '',
									srpLname = '',
									trbCardfrom = trb_cardfrom,
									trbMsg = '',
									tribNotes = hiddenTributeType,
									cardSend = hiddenAWKtype,
									gTribute = gTribute
								}
			} />
            
            <cfset tAttempt = SerializeJSON(tAttemptRecord)>
    	
    		<cfset tATPrec = recordTransAttempt(tAttempt)>
    
    
    
    	<cfinclude template="../includes/0log_donation.cfm">
    
    <cfcatch type="any">
    <cfmail to="csweeting@bcchf.ca" from="error@bcchf.ca" subject="error recording backup data" type="html">
    Error recording backup data - trying to record attempt record.
    Message: #cfcatch.Message#
    Detail: #cfcatch.Detail#
    <cfdump var="#cfcatch#" label="catch">
    <cfdump var="#form#" hide="POST_CARD_NUMBER,POST_CVV,FIELDNAMES,POST_DOLLARAMOUNT,js_bcchf_cardnumber,js_bcchf_cvv" label="transaction">
    </cfmail>
    </cfcatch>
    </cftry>
    
	
    <!--- check for XDS,IP, and Fraud MO --->
    <cftry>
    
    <!--- XDS --->
    <cfset goodXDS = checkXDS(APPLICATION.AppVerifyXDS, FORM.App_verifyToken, CGI.HTTP_REFERER)>
    
    <cfif goodXDS EQ 0>
    	<cfset attemptCharge = 0>
    </cfif>
    
    <!--- check IP method --->
    <cfset goodIP = checkIPaddress(newIP)>
    
    <cfif goodIP EQ 0>
    	<cfset attemptCharge = 0>
    </cfif>
    
    <!--- check Fraudster MO --->
    <cfset fradulent = checkFraudsterMO(pty_tax_fname, pty_tax_lname, pty_fname, pty_lname, ptc_email, ptc_country, gift_frequency, post_dollaramount)>
    
    <cfif fradulent EQ 1>
    	<cfset attemptCharge = 0>
    </cfif>
    
    
    <cfcatch type="any">
    <cfset attemptCharge = 0>
    <cfmail to="csweeting@bcchf.ca" from="error@bcchf.ca" subject="error checking for Fraud" type="html">
    Error checking for fraud
    Message: #cfcatch.Message#
    Detail: #cfcatch.Detail#
    <cfdump var="#cfcatch#" label="catch">
    <cfdump var="#form#" hide="POST_CARD_NUMBER,POST_CVV,FIELDNAMES,POST_DOLLARAMOUNT,js_bcchf_cardnumber,js_bcchf_cvv" label="transaction">
    </cfmail>
    </cfcatch>
    </cftry>
    
    
    <!--- if we can attempt the charge --->
    <cfif attemptCharge EQ 1>
    
		<!--- trying to process on e-xact --->
        <cftry>
        <!--- BCCHF Exact Gobal Vars --->
        <cfinclude template="../includes/e-xact_include_var.cfm">
        
        <cfif post_card_number EQ 4111111111111111><!--- allow testing --->
        
            <!--- Testing Process ---><cfinclude template="../includes/testBlock.cfm"> 
            <!--- UUID used in test approvals --->
        
        <cfelse>
        
            <!--- Exact Method cfinvoke webservice ---> 
            <cfinclude template="../includes/e-xact_post_v60.1.cfm">
        
        </cfif> 
        
        
        <cfcatch type="any">
        <cfmail to="csweeting@bcchf.ca" from="error@bcchf.ca" subject="error in exact process" type="html">
        error in exact process
        Message: #cfcatch.Message#
        Detail: #cfcatch.Detail#
        <cfdump var="#cfcatch#" label="catch">
        <cfdump var="#form#" hide="POST_CARD_NUMBER,POST_CVV,FIELDNAMES,POST_DOLLARAMOUNT,js_bcchf_cardnumber,js_bcchf_cvv" label="transaction">
        </cfmail>
        </cfcatch>
        </cftry>
        
        <!--- trying to record Recieved Record --->
        <cftry>
        
        	<!--- Update Attempt Record with E-Xact Charge Tokens --->
            <cfset eTransResult = {
				rqst_transaction_approved = rqst_transaction_approved,
				rqst_dollaramount = rqst_dollaramount,
				rqst_CTR = rqst_CTR,
				rqst_authorization_num = rqst_authorization_num,
				rqst_sequenceno = rqst_sequenceno,
				rqst_bank_message = rqst_bank_message,
				rqst_exact_message = rqst_exact_message,
				rqst_formpost_message = rqst_formpost_message,
				rqst_exact_respCode = rqst_exact_respCode,
				rqst_AVS = rqst_AVS
			}/>
            
            
            
            <cfset eXactRes = SerializeJSON(eTransResult)>
            
            <cfset eATPrec = recordExactAttempt(eXactRes, variables.newUUID)>
        
            <cfinclude template="../includes/1log_donation.cfm">
        
        <cfcatch type="any">
        <cfmail to="csweeting@bcchf.ca" from="error@bcchf.ca" subject="error recording backup data" type="html">
        Error recording backup data - trying to record recieved data
        Message: #cfcatch.Message#
        Detail: #cfcatch.Detail#
        <cfdump var="#cfcatch#" label="catch">
        <cfdump var="#form#" hide="POST_CARD_NUMBER,POST_CVV,FIELDNAMES,POST_DOLLARAMOUNT,js_bcchf_cardnumber,js_bcchf_cvv" label="transaction">
        </cfmail>
        </cfcatch>
        </cftry>
    
    
    <cfelse>
    	<!--- charge not attempted - IP blocked --->
    
    	<cfset rqst_transaction_approved = 0>
        <cfset rqst_exact_respCode = 0>
    	<cfset chargeAproved = 0>
        <cfset exact_respCode = 0>
        <cfset returnMSG = 'Charge Not Attempted'>
    
    </cfif>
    
    
    
    <!--- NOT approved --->
    <cfif rqst_transaction_approved NEQ 1>
    
    	<!--- abort and show messages --->
    	<cfset chargeAproved = 0>
        <cfset exact_respCode = rqst_exact_respCode>
        <cfset returnMSG = 'charging-notapproved'>
        
        <!--- track non approvals 
			1. check for past not approved transactions
			2. allow another attempt or abort
		
			---->
            <cftry>
        <!--- multiple non-approvals from the same IP should trigger message and blocking --->
        <!--- record the failed attempt so we can block IP if necessary --->
        <cfif rqst_bank_message EQ 'PICK UP CARD       * CALL BANK          =' 
			OR rqst_bank_message EQ 'HOLD CARD          * CALL               ='>
            <cfset recordIP = blockIP(newIP)>
        </cfif>
		
        
		<!--- check if this IP has already made a failed attempt  --->

		<!--- check IP against list --->
		<cfset recordIP = recordIPaddress(newIP)>
		
        <cfif recordIP EQ 1>
        	<cfset ipBlocker = 1>
        <cfelse>
        	<cfset ipBlocker = 0>
        </cfif>
        
        <cfcatch type="any">
            <cfmail to="csweeting@bcchf.ca" from="donations@bcchf.ca" subject="Online Donation Error" type="html">
            Error recording backup data - checking the IP on a failed record.
            Message: #cfcatch.Message#
            Detail: #cfcatch.Detail#
            <cfdump var="#cfcatch#" label="catch">
            <cfdump var="#form#" hide="POST_CARD_NUMBER,POST_CVV,FIELDNAMES,POST_DOLLARAMOUNT,js_bcchf_cardnumber,js_bcchf_cvv" label="transaction">
            </cfmail>
        </cfcatch>
        </cftry>
        
		<!--- END of NOT APPROVED AREA --->        
        <!----------------------------------- --------------------------------------> 
        <!--- will return exact message for display to the user ---->   
        
        
        
    <cfelse>
    <!--- charge approved --->
    
    	<cfset chargeAproved = 1>
        <cfset returnMSG = 'charging-approved'>
            
    	<!--- record transaction information 
			
			1. Dump content of form to txt file
			2. Insert core transaction information into db
				- Transaction Information
				- Donor Information
				- SHP tables if necessary
			3. Update additional information
			4. Update tribute information
			5. Add eCard Information
			6. 
		
		
		--->
        
        <!--- remove IP from blocker trace --->
        <cftry>
        
        <cfset removeIP = removeIPaddress(newIP)>
        
        <cfcatch type="any">
        
        <cfmail to="csweeting@bcchf.ca" from="error@bcchf.ca" subject="error removing IP from blocker trace" type="html">
        Error removing IP from blocker trace table
        Message: #cfcatch.Message#
        Detail: #cfcatch.Detail#
        <cfdump var="#cfcatch#" label="catch">
        <cfdump var="#form#" hide="POST_CARD_NUMBER,POST_CVV,FIELDNAMES,js_bcchf_cardnumber,js_bcchf_cvv,bcchf_cvv,bcchf_cc_number" label="transaction">
        </cfmail>
        
        </cfcatch>
        </cftry>
        
        
        <!--- try and record the transaction details in a flat txt file --->
        <cftry>
        
			<!--- directories --->
            <cfset monthlyDumpDirectory = DateFormat(Now(), 'mm-yy')>
            <Cfset dailyDumpDirectory = DateFormat(Now(), 'DD')>
            
            <cfset dumpDirectory = "#APPLICATION.WEBLINKS.File.service#\transactions\#monthlyDumpDirectory#\#dailyDumpDirectory#\">
            
            <!--- check if directory exists --->
            <cfif DirectoryExists(dumpDirectory)>
                <!--- directory exists - we are all good --->
            <cfelse>
                <!--- need to create directory --->
                <cfdirectory directory="#dumpDirectory#" action="create">
                        
            </cfif>
            
            <!--- add timestamp to file --->
            <Cfset append = "#DateFormat(Now())#---#TimeFormat(Now(), 'HH-mm-ss.l')#">
            
            <!--- dump form to file --->
            <!--- hide PCI fields --->
            <cfdump var="#form#" output="#dumpDirectory#bcchildren_full_donation_dump_date-#append#.txt" hide="POST_CARD_NUMBER,POST_CVV,FIELDNAMES,POST_DOLLARAMOUNT,js_bcchf_cardnumber,js_bcchf_cvv" type="html">
        
    	<cfcatch type="any">
        
        <cfmail to="csweeting@bcchf.ca" from="error@bcchf.ca" subject="error recording backup data" type="html">
        Error recording backup data - trying to create txt file of transaction
        Message: #cfcatch.Message#
        Detail: #cfcatch.Detail#
        <cfdump var="#cfcatch#" label="catch">
        <cfdump var="#form#" hide="POST_CARD_NUMBER,POST_CVV,FIELDNAMES,js_bcchf_cardnumber,js_bcchf_cvv,bcchf_cvv,bcchf_cc_number" label="transaction">
        </cfmail>
        
        </cfcatch>
        </cftry>
        
        
        <!--- Parse exact rqst_CTR for exact time --->
        <cftry>
			<cfset DTindex = REFIND("DATE/TIME", rqst_CTR) + 14>
            <cfset DT = Mid(rqst_CTR, DTindex, 18)>
            <cfset exact_odbcDT = CreateODBCDateTime(DT)>
        <cfcatch type="any">
			<cfset exact_odbcDT = pty_Date>
        </cfcatch>
        </cftry>
        
        
        <!--- Try to Insert Record Into Database --->
        <cftry>
        
        
        <!--- encrypt card data --->
        <cfset encrptedCardData = encrptCard(post_card_number, gift_frequency)>
        
        <!--- Successful Record Struct --->
        <cfset tSuccessRecord = {
			tUUID = variables.newUUID,
			tDollar = post_dollaramount,
			tAdv = giftAdvantage,
			tTax = giftTaxable,
			tRType = receipt_type,
			tSource = donation_source,
			eSource = ePhilSRC,
			tENC = encrptedCardData,
			tCard = {
				cName = post_cardholdersname,
				eXm = post_expiry_month,
				eXy = post_expiry_year
			},
			tDonor = {
				dTitle = pty_title,
				dFname = pty_fname,
				dMname = pty_miname,
				dLname = pty_lname,
				dCname = pty_companyname,
				dTaxTitle = pty_tax_title,
				dTaxFname = pty_tax_fname,
				dTaxMname = pty_miname,
				dTaxLname = pty_tax_lname,
				dTaxCname = pty_tax_companyname,
				dAddress = {
					aOne = ptc_address,
					aTwo = ptc_addTwo,
					aCity = ptc_city,
					aProv = ptc_prov,
					aPost = ptc_post,
					aCountry = ptc_country
				},
				dEmail = ptc_email,
				dPhone = ptc_phone
			},
			tType = gift_type,
			tFreq = gift_frequency,
			tNotes = gift_notes,
			tTType = pty_tax,
			tFreqDay = gift_day,
			tSHP = {
				tAdd = HeroDonateAdd,
				tToken = hiddenEventToken,
				tCampaign = hiddenEventCurrentYear,
				tTeamID = hiddenTeamID,
				tSupID = hiddenSupID,
				tDname = DName,
				tStype = hiddentype,
				tSmsg = Message,
				tSshow = Show
			},
			tJD = {
				Pins = RunnerPin,
				Buttons = RunnerButton,
				BBQ = RunnerBBQ,
				BBQl = '',
				cFriday = 0
			}
			
		} />
        
        <cfset tSRec = SerializeJSON(tSuccessRecord)>
        
        <cfset tSSUCrec = recordSuccAttempt(tSRec, variables.newUUID)>
        
        
        <!--- DEPRECIATE: bcchf_bcchildren -- transaction data in tblDonation --->
        <CFQUERY datasource="#APPLICATION.DSN.transaction#" name="insert_record" dbtype="ODBC">
        INSERT INTO tblDonation (dtnDate, exact_date, dtnAmt, dtnReceiptAmt, dtnReceiptType, dtnBatch, dtnSource, post_cardholdersname, post_card_number, post_expiry_month, post_expiry_year, post_card_type, DEK_ID, post_ExactID, rqst_transaction_approved, rqst_authorization_num, rqst_dollaramount, rqst_CTR, rqst_sequenceno, rqst_bank_message, rqst_exact_message, rqst_formpost_message, rqst_AVS, pge_UUID, dtnIP, dtnBrowser) 
        VALUES (#pty_Date#, #exact_odbcDT#, '#post_dollaramount#', '#post_dollaramount#', '#receipt_type#', 'Online', '#donation_source#', '#post_cardholdersname#', '#encrptedCardData.ENCDATA#', '#post_expiry_month#', '#post_expiry_year#', '#encrptedCardData.ENCTYPE#', #encrptedCardData.ENCDEKID#, 'A00063-01', '#rqst_transaction_approved#', '#rqst_authorization_num#', '#rqst_dollaramount#', '#rqst_CTR#', '#rqst_sequenceno#', '#rqst_bank_message#', '#rqst_exact_message#', '#rqst_formpost_message#', '#rqst_AVS#', '#variables.newUUID#', '#newIP#', '#newBrowser#') 
        </CFQUERY>
        
        <!--- we want the ID from tblDonation for the tax receipt --->
        <cfquery name="selectID" datasource="#APPLICATION.DSN.transaction#">
        SELECT dtnID FROM tblDonation WHERE pge_UUID = '#variables.newUUID#'
        </cfquery>
        

        <!--- new method for new receipts --->
		<cfif selectID.dtnID GTE 200000>
            <cfset receiptNumber = selectID.dtnID + 1100000>
        <cfelse>
            <cfset receiptNumber = selectID.dtnID + 800000>
        </cfif>
        
        
        <!--- if the try block fails --->
        <!--- send email with details to isbcchf --- log transaction --->
        <cfcatch type="any">
			<cfmail to="csweeting@bcchf.ca" from="error@bcchf.ca" subject="error recording transaction data" type="html">
            Error recording database data into tblDonation
            Message: #cfcatch.Message#
            Detail: #cfcatch.Detail#
            <cfdump var="#cfcatch#" label="catch">
            <cfdump var="#form#" hide="POST_CARD_NUMBER,POST_CVV,FIELDNAMES,POST_DOLLARAMOUNT,js_bcchf_cardnumber,js_bcchf_cvv">
            </cfmail>
        </cfcatch>
        </cftry>
        
      
         
        <!--- DEPRECIATE: bcchf_donationGeneral -- donor data in tblGeneral --->
        <cftry>
        
        <!--- insert basic info and update later with other info --->
        <!--- donor information --->
        <CFQUERY datasource="#APPLICATION.DSN.general#" name="insert_record">
        INSERT INTO tblGeneral (pty_date, exact_date, pty_title, pty_fname, pty_miname, pty_lname, pty_companyname, ptc_address, ptc_add_two, ptc_city, ptc_prov, ptc_post, ptc_country, ptc_email, ptc_phone, pty_tax_title, pty_tax_fname, pty_tax_lname, pty_tax_companyname, gift, gift_Eligible, gift_type, gift_frequency, gift_notes, rqst_authorization_num, pty_tax, POST_REFERENCE_NO, rqst_sequenceno, gift_day, JD_Pin, JD_Button, pge_UUID, receipt_type) 
        VALUES (#pty_date#, #exact_odbcDT#, '#pty_title#', '#pty_fname#', '#pty_miname#', '#pty_lname#',  '#pty_companyname#', '#ptc_address#', '#ptc_addTwo#', '#ptc_city#', '#ptc_prov#', '#ptc_post#', '#ptc_country#', '#ptc_email#', '#ptc_phone#', '#pty_tax_title#', '#pty_tax_fname#', '#pty_tax_lname#', '#pty_tax_companyname#', '#post_dollaramount#', '#post_dollaramount#', '#gift_type#', '#gift_frequency#', '#gift_notes#', '#rqst_authorization_num#', '#pty_tax#', '#rqst_sequenceno#', '#rqst_sequenceno#', '#gift_day#', '#pinsPurchased#',  '#buttonsPurchased#', '#variables.newUUID#', '#ePhilSRC#')
        </CFQUERY>
        
        <!--- if the try block fails --->
        <!--- send email with details to isbcchf --- log transaction --->
        <cfcatch type="any">
			<cfmail to="csweeting@bcchf.ca" from="error@bcchf.ca" subject="error recording transaction data" type="html">
            Error recording database data into tblGeneral
            Message: #cfcatch.Message#
            Detail: #cfcatch.Detail#
            <cfdump var="#cfcatch#" label="catch">
            <cfdump var="#form#" hide="POST_CARD_NUMBER,POST_CVV,FIELDNAMES,POST_DOLLARAMOUNT,js_bcchf_cardnumber,js_bcchf_cvv">
            </cfmail>
        </cfcatch>
        </cftry>
        
        
        <!--- check URL for email referal --->
        <cftry>
        
        <!--- lookup email and add note that donation has been made --->
        <cfif IsDefined('emailReferal') AND emailReferal NEQ ''>
            
            <cfset eRefUpdate = checkEmailReff(emailReferal, variables.newUUID)>
            
        </cfif>
        
        <cfcatch type="any">
        	<!--- do nothing --->
        </cfcatch>
        </cftry>
        
        
        <!--- DEPRECIATE: try to Insert into Hero_Donate if necessary --->
		<cftry>
        
        
            
            <!--- insert into hero_donate 
            <cfquery name="insertHeroDonation" datasource="#APPLICATION.DSN.Superhero#">
            INSERT INTO Hero_Donate (Event, Campaign, TeamID, Name, Type, Message, Show, DonTitle, DonFName, DonLName, DonCompany, Email, don_date, rqst_authorization_num, Amount, SupID, POST_REFERENCE_NO, JDPins, JDButtons, pge_UUID, AddDate, UserAdd, LastChange, LastUser) 
            VALUES ('#hiddenEventToken#', #hiddenEventCurrentYear#, #hiddenTeamID#, '#DName#', '#hiddentype#', '#Message#', #Show#, '#pty_title#', '#pty_fname#', '#pty_lname#', '#pty_companyname#', '#ptc_email#', #pty_Date#, '#rqst_authorization_num#', #Hero_Donate_Amount#, #hiddenSupID#, '#rqst_sequenceno#', #RunnerPin#, #RunnerButton#, '#variables.newUUID#', #pty_Date#, 'Online', #pty_Date#, 'Online')
            </cfquery>--->
                   
        
        
        <!--- if the try block fails --->
        <!--- send email with details to isbcchf --- log transaction --->
        <cfcatch type="any">
			<cfmail to="csweeting@bcchf.ca" from="error@bcchf.ca" subject="error recording transaction data" type="html">
            Error recording database data into Hero_Donate
            Message: #cfcatch.Message#
            Detail: #cfcatch.Detail#
            <cfdump var="#cfcatch#" label="catch">
            <cfdump var="#form#" hide="POST_CARD_NUMBER,POST_CVV,FIELDNAMES,POST_DOLLARAMOUNT,js_bcchf_cardnumber,js_bcchf_cvv">
            </cfmail>
        </cfcatch>
        </cftry>
        
		<!--- try and update the rest of the transaction details --->
        <!--- Additional Information --->
        <cftry>
            
            <cfif NOT IsDefined("js_bcchf_allow_email")><cfset js_bcchf_allow_email = ""></cfif>
            <CFIF js_bcchf_allow_email EQ ""><CFSET js_bcchf_allow_email = " "></CFIF>
            
            <!--- if news subscribe is yes - set SOC and AR to yes --->
            <cfif js_bcchf_allow_email EQ 1>
            	<cfset SOC_subscribe = 1>
                <cfset news_subscribe = 1>
                <cfset AR_subscribe = 0>
            <cfelse>
            	<cfset SOC_subscribe = 0>
                <cfset news_subscribe = 0>
                <cfset AR_subscribe = 0>
            </cfif>
            
            <cfset adInfo = {
				iSecurity = '',
				iWill = '',
				iLife = '',
				iTrust = '',
				iRRSP = '',
				iWillInclude = '',
				iLifeInclude = '',
				iRSPinclude = '',
				SOC_subscribe = SOC_subscribe,
				news_subscribe = news_subscribe,
				AR_subscribe = AR_subscribe,
				iWhere = '',
				iPastDonor = '',
				gPledgeDet = ''
				
			} />
            
            <cfset addInfo = SerializeJSON(adInfo)>
            
            <cfset tSSUCadd = recordSuccAdd(addInfo, variables.newUUID)>
    
            
            <!--- addadditional information section --->
            <cfquery name="updateAddInfo" datasource="#APPLICATION.DSN.general#">
            UPDATE tblGeneral
            SET	TeamID = #hiddenTeamID#,
                SupID = #hiddenSupID#,
                ptc_subscribe = '#js_bcchf_allow_email#',
				SOC_subscribe = '#SOC_subscribe#', 
				AR_subscribe = '#AR_subscribe#'
            WHERE pge_UUID = '#variables.newUUID#'
            </cfquery>
        <!------>
        <cfcatch type="any">
        	<!--- allow continue --->
            
            <cfmail to="csweeting@bcchf.ca" from="error@bcchf.ca" subject="error recording transaction data" type="html">
            Error updating database data into tblGeneral
            Message: #cfcatch.Message#
            Detail: #cfcatch.Detail#
            <cfdump var="#cfcatch#" label="catch">
            <cfdump var="#form#" hide="POST_CARD_NUMBER,POST_CVV,FIELDNAMES,POST_DOLLARAMOUNT,js_bcchf_cardnumber,js_bcchf_cvv">
            </cfmail>
            
        </cfcatch>
        </cftry>

        <!--- update donation general with pledge information --->
        <cftry>
        
			<cfif JS_BCCHF_GIFT_TYPE EQ 'Pledge'>
            
            <cfset plInfo = {
				pledge = 'yes',
				pDetail = js_bcchf_pledge_id,
				pDREID = ''
			}/ >
            
            <cfset plInfoJSON = SerializeJSON(plInfo)>
            
            <cfset tSSUCpl = recordSuccPledge(plInfoJSON, variables.newUUID)>
            
            
            <!--- update tblGeneral with pledge data --->
            <cfquery name="updatePledgeData" datasource="#APPLICATION.DSN.general#">
            UPDATE tblGeneral
            SET	gift_pledge_det = '#js_bcchf_pledge_id#',
            gift_pledge = 'yes'
            WHERE pge_UUID = '#variables.newUUID#'
            </cfquery>
            
            </cfif>
            
        
        <!--- FAIL EMAIL --->
        <cfcatch type="any">
			<cfmail to="csweeting@bcchf.ca" from="error@bcchf.ca" subject="error recording transaction data" type="html">
            Error updating pledge data in tblGeneral
            Message: #cfcatch.Message#
            Detail: #cfcatch.Detail#
            <cfdump var="#cfcatch#" label="catch">
            <cfdump var="#form#" hide="POST_CARD_NUMBER,POST_CVV,FIELDNAMES,POST_DOLLARAMOUNT,js_bcchf_cardnumber,js_bcchf_cvv">
            </cfmail>
        </cfcatch>
        </cftry>
        
        <!--- update donation general with tribute information --->
        <cftry>
            
            <cfif JS_BCCHF_GIFT_TYPE EQ 'honour' OR JS_BCCHF_GIFT_TYPE EQ 'memory'>
            
            <cfset tribInfo = {
				  trbFname = trb_fname,
				  trbLname = trb_lname,
				  trbEmail = trb_email,
				  trbAddress = '',
				  trbCity = '',
				  trbProv = '',
				  trbPost = '',
				  srpFname = '',
				  srpLname = '',
				  trbCardfrom = trb_cardfrom,
				  trbMsg = '',
				  tribNotes = hiddenTributeType,
				  cardSend = hiddenAWKtype,
				  gTribute = gTribute
			} />
            
            <cfset tribInfoJSON = SerializeJSON(tribInfo)>
            
            <!--- <cfset tSSUCtrib = recordSuccTrib(tribInfoJSON, variables.newUUID)> --->
            
            
            <!--- update tblGeneral with tribute data --->
            <cfquery name="updateTributeData" datasource="#APPLICATION.DSN.general#">
            UPDATE tblGeneral
            SET	gift_tribute = 'yes',
                trb_fname = '',
                trb_lname = '#JS_BCCHF_HONOUR#', 
                trb_email = '#js_bcchf_recepient_email#', 
                trb_cardfrom = '#pty_fname# #pty_lname#', 
                trib_notes = '#hiddenTributeType#',
                card_send = '#trb_msgType#'
            WHERE pge_UUID = '#variables.newUUID#'
            </cfquery>
            
            
            </cfif>
        
        
        <!--- if the try block fails --->
        <!--- send email with details to isbcchf --- log transaction --->
        <cfcatch type="any">
			<cfmail to="csweeting@bcchf.ca" from="error@bcchf.ca" subject="error recording transaction data" type="html">
            Error updating hom/mem data in tblGeneral
            Message: #cfcatch.Message#
            Detail: #cfcatch.Detail#
            <cfdump var="#cfcatch#" label="catch">
            <cfdump var="#form#" hide="POST_CARD_NUMBER,POST_CVV,FIELDNAMES,POST_DOLLARAMOUNT,js_bcchf_cardnumber,js_bcchf_cvv">
            </cfmail>
        </cfcatch>
        </cftry>
                
        
        
        <!--- end of database processing --->
        
        <!---- send the confirmation emails ---->
        <cftry>
        
        
        <!--- 1. Content of E-mail to Foundation --->
        <cfset FDNnotifyEmail = FDNnotifyEmail(variables.newUUID)>

		<!---- 2. donation confirmation message - triggered on confirmation page ----
		<cfset DonorEmailThanks = DonorEmailThanks(variables.newUUID)> --->
        
		<!--- 3. if Tribute - Tribute Notification email --->
        <cfif trb_msgType EQ 'email' 
			AND (hiddenTributeType EQ 'hon' OR hiddenTributeType EQ 'mem')>
        
        	<cfset TribAwkEmail = TribAwkEmail(variables.newUUID)>
        
        </cfif>

		<!--- 4. SHP Notifications -
			ICE ---->
    	<cfif gift_type EQ 'ICE'>
        	<cfset ICEnotifyEmail = ICEnotifyEmail(variables.newUUID)>
        </cfif>
        
        
        <!--- other Events --->
        <cfif hiddenTributeType EQ 'event'>
			<!--- Send notification email to supporter --->
            <cfset supNotifyEmail = SHPnotifyEmail(variables.newUUID)>
        </cfif>


        <cfcatch type="any">
        
        <cfmail to="csweeting@bcchf.ca" from="error@bcchf.ca" subject="error sending mobile donation emails" type="html">
            Error sending donation emails
            Message: #cfcatch.Message#
            Detail: #cfcatch.Detail#
            <cfdump var="#cfcatch#">
            <cfdump var="#form#" hide="POST_CARD_NUMBER,POST_CVV,FIELDNAMES,POST_DOLLARAMOUNT,js_bcchf_cardnumber,js_bcchf_cvv">
            </cfmail>
            
        </cfcatch>
        </cftry>


        <!--- send return message to browser window that the transaction is complete --->
        
        <!--- message about frequency  --->
        <cfset chargeMSG = gift_frequency>
        <!--- after inserting in DB and sending emails --->
        <cfset returnSuccess = 1>
        
    	</cfif><!--- end of if charging approved --->


    
    <cfset ChargeAttmpt = {
		cAttempted = chargeAttempt,
		cApproved = chargeAproved,
		cMSG = chargeMSG,
		exact_respCode = exact_respCode,
		ipBlocker = ipBlocker,
		goodXDS = goodXDS
		} />

	<!--- this is the structure of the return message --->
    <cfset SHPdonationReturnMSG = {
	Success = returnSuccess,
	ChargeAttmpt = ChargeAttmpt,
	Message = returnMSG,
	EventToken = hiddenEventToken,
	UUID = variables.newUUID,
	tGenTwoID = tGenTwoID
	} />
    
    
    <cfreturn SHPdonationReturnMSG>



</cffunction>









<cffunction name="submitDonationFormPayPal" access="remote" >
    
	<!--- donor information --->
    <cfargument name="pty_title" type="string" required="yes">
    <cfargument name="pty_fname" type="string" required="yes">
    <cfargument name="pty_MIname" type="string" required="no">
    <cfargument name="pty_lname" type="string" required="yes">
    
    <cfargument name="pty_tax_title" type="string" required="yes">
    <cfargument name="pty_tax_fname" type="string" required="yes">
    <cfargument name="pty_tax_MIname" type="string" required="no">
    <cfargument name="pty_tax_lname" type="string" required="yes">
    
    <cfargument name="pty_companyname" type="string" required="yes">
    <cfargument name="pty_tax_companyname" type="string" required="yes">
    
    <cfargument name="ptc_address" type="string" required="yes">
    <cfargument name="ptc_addTwo" type="string" required="yes">
    <cfargument name="ptc_city" type="string" required="yes">
    <cfargument name="ptc_country" type="string" required="yes">
    <cfargument name="ptc_prov" type="string" required="yes">
    <cfargument name="ptc_post" type="string" required="yes">
    <cfargument name="ptc_email" type="string" required="yes">
    <cfargument name="pty_subscr_r" type="string" required="no">
    <cfargument name="ptc_phone" type="string" required="yes">
    
    
    <!--- tribute information --->
    <cfargument name="trb_fname" type="string" required="no">
    <cfargument name="trb_lname" type="string" required="no">
    <cfargument name="hiddenAWKtype" type="string" required="no">
    <cfargument name="srp_fname" type="string" required="no">
    <cfargument name="srp_lname" type="string" required="no">
    <cfargument name="trb_address" type="string" required="no">
	<cfargument name="trb_addtwo" type="string" required="no">
	<cfargument name="trb_city" type="string" required="no">
	<cfargument name="trb_prov" type="string" required="no">
    <cfargument name="trb_post" type="string" required="no">
    <cfargument name="trb_country" type="string" required="no">
    <cfargument name="trb_email" type="string" required="no">
    <cfargument name="trb_message" type="string" required="no">
    <cfargument name="trb_cardfrom" type="string" required="no">
    
    <!--- eCard Information --->
    <cfargument name="cardRec_fname" type="string" required="no">
    <cfargument name="cardRec_lname" type="string" required="no">
    <cfargument name="cardRec_email" type="string" required="no">
    <cfargument name="cardSend_fname" type="string" required="no">
    <cfargument name="cardSend_lname" type="string" required="no">
    <cfargument name="cardSend_email" type="string" required="no">
    <cfargument name="eCardMessage" type="string" required="no">
    <cfargument name="eCard_image" type="string" required="no">
    <cfargument name="eCard_occasion" type="string" required="no">
    <cfargument name="cardSend_date" type="string" required="no">
    <cfargument name="eCardMessagehidden" type="string" required="no">
    
    
    <!--- SHP event scroll details --->
    <cfargument name="hiddenEventToken" type="string" required="no">
    <cfargument name="hiddenEventCurrentYear" type="string" required="no">
    <cfargument name="hiddenTeamID" type="string" required="no">
    <cfargument name="hiddenSupID" type="string" required="no">
    <cfargument name="DName" type="string" required="no">
    <cfargument name="hiddentype" type="string" required="no">
    <cfargument name="Message" type="string" required="no">
    <cfargument name="Show" type="string" required="no">
    <cfargument name="ShowAnonymous" type="string" required="no">
    
    
    <!--- additional details --->
    <cfargument name="gift_notes" type="string" required="no">
    <cfargument name="info_where" type="string" required="no">
    <cfargument name="donated_before" type="string" required="no">
	<!--- info about securities --->
    <cfargument name="info_securities" type="string" required="no">
    <!--- included in will --->
    <cfargument name="info_willinclude" type="string" required="no">
    <!--- included in life --->
    <cfargument name="info_lifeinclude" type="string" required="no">
    <!--- included in RSP --->
    <cfargument name="info_RSPinclude" type="string" required="no">
    <!--- send more info --->
    <cfargument name="info_will" type="string" required="no">
    <cfargument name="info_life" type="string" required="no">
    <cfargument name="info_RRSP" type="string" required="no">
    <cfargument name="info_trusts" type="string" required="no">
    
    <!--- subscriptions --->
    <cfargument name="news_subscribe" type="string" required="no">
    <cfargument name="SOC_subscribe" type="string" required="no">
    <cfargument name="AR_subscribe" type="string" required="no">
    
    <!--- pledge details --->
    <cfargument name="gift_pledge_det" type="string" required="no">
    <cfargument name="gift_pledge_DonorID" type="string" required="no"><!---  --->
    
    
    <!--- donation information --->
    <!--- gift type --->
    <cfargument name="hiddenGiftType" type="string" required="yes">
	<!--- gift amount --->
    <cfargument name="hiddenGiftAmount" type="string" required="yes">
    <!--- Personal or Corporate - set tax values with this info --->
    <cfargument name="hiddenDonationPCType" type="string" required="yes">
    <!--- indicated frequency --->
    <cfargument name="hiddenDonationType" type="string" required="yes">
    <!--- monthly day  not required for single --->
    <cfargument name="hiddenFreqDay" type="string" required="no">
    <!--- tribute type --->
    <!--- eCard for eCards - Pledge for Pledge --->
    <cfargument name="hiddenTributeType" type="string" required="yes">
    
    
    <!--- tax receipt information --->
    <cfargument name="pty_tax" type="string" required="yes">
    <cfargument name="pty_ink" type="string" required="no">
    <cfargument name="pty_tax_issuer" type="string" required="yes">
    <!--- TO ADD tax type for HK receipts --->
    
    
    <!--- cardholder data --->
    <cfargument name="post_card_number" type="string" required="no">
    <cfargument name="post_expiry_date" type="string" required="no">
    <cfargument name="post_cardholdersname" type="string" required="no">
    <cfargument name="post_CVV" type="string" required="no">
    
    <!--- email referal conditions --->
    <cfargument name="emailReferal" type="string" required="no">
    
    <!--- JeansDay Information --->
    <cfargument name="runnerPin" type="string" required="no">
    <cfargument name="runnerButton" type="string" required="no">
    
    <!--- HSBC Information --->
    <cfargument name="TransitNumber" type="string" required="no">
    <cfargument name="TransitNumberOther" type="string" required="no">
    
    
    <!--- SERVER Date at submission --->
    <cfif NOT IsDefined("pty_date")><cfset pty_date= "#Now()#"></cfif>
    
    <!--- DENY XXS attack --->
    <cfif CGI.REMOTE_ADDR EQ '58.187.162.122'>
    <cfthrow message="toast" type="error">
    </cfif>
    
    <!--- BCCHF sandbox 
	<cfset ClientID = 'AU7JuxDyWHnqy5vngOapa6_ndHU-0NfJP37DZtG-x6E_KPjH9KiKetcSb9AY'>
    <cfset clientPass = 'EGSdMhC9MagPgmY8QwOs_yzMFZ69QSNb4Y4ytGqv0HE0SB-QqOl9C7rTdCmJ'>
	<cfset apiendPoint = 'https://api.sandbox.paypal.com/'>--->
    
    
    <!--- BCCLF LIVE --->
	<cfset ClientID = 'AUQ0kRD4EXX6hhe3nQ4Uu78Q18Ea2F2_hHTAL5LsrHgIRvk1xtYvsq-TvH8p'>
    <cfset clientPass = 'ENnkbRA4zr4vQ84FJvB1WV-vV8CgAL-BpiF22pejC_m6C2AMudlH5RvbrtsD'>
        
    <cfset apiendPoint = 'https://api.paypal.com/'>
    <cfset secureBCCHF = 'https://secure.bcchf.ca/'>
    
    <!--- create UUID to access info --->
    <cfset variables.newUUID=createUUID()>
    <!--- collect IP address of remote requestor --->
	<cfset newIP = CGI.REMOTE_ADDR>
	<cfset newBrowser = CGI.HTTP_USER_AGENT>
    <cfset ipBlocker = 0>
    
    <!--- set transaction amount --->
    <cfset hiddenGiftAmount = REREPlace(hiddenGiftAmount, '[^0-9.]','','all')>
    <cfset post_dollaramount = hiddenGiftAmount>
    
    <!--- default setting is not adding to hero donate ---> 
    <cfset HeroDonateAdd = 0>
    
    <!--- successful variables --->
    <cfset chargeSuccess = 0>
    <cfset donationSuccess = 0>
    <cfset chargeAttempt = 0>
    <cfset chargeAproved = 0>
    <cfset chargeMSG = "">
    <cfset tGenTwoID = 0>
    
    <!--- construct return message --->
    <cfset returnSuccess = 0>
    <cfset returnMSG = 'beginAttempt'>
    <cfset exact_respCode = 0>
    
    <cfset pty_tax_fname = TRIM(pty_tax_fname)>
	<cfset pty_tax_lname = TRIM(pty_tax_lname)>
	<cfset pty_companyname = TRIM(pty_companyname)>
    
    <cfif pty_companyname EQ ' '>
		<cfset pty_companyname = ''>
    </cfif>
    
    <!--- set gift type on form pre load --->
    <cfset gift_type = hiddenGiftType>
        
	<!--- set the source --->
	<cfset donation_source = 'New Donation Form'>
    
	<!--- read ePhil Source --->
    <cfif IsDefined('ePhilanthropySource')>
    	<cfset ePhilSRC = ePhilanthropySource>
    <cfelse>
    	<cfset ePhilSRC = ''>
    </cfif>    
    
    <cfset rdrLnk = ''>
    <cfset payPalPaymentID = ''>
    
    <!--- scrub some variables for db loading --->
    <cftry>
        
        <!--- corp / personal tax settings --->
		<cfif hiddenDonationPCType EQ 'corporate'>
            <!--- corporate donation --->
            <cfset pty_tax_title = "">
            <cfset pty_tax_fname = "">
            <cfset pty_tax_lname = "">
            <cfset pty_companyname = pty_tax_companyname>
        <cfelse>
            <!--- personal donation fields --->
            <cfset pty_title = pty_tax_title>
            <cfset pty_fname = pty_tax_fname>
            <cfset pty_lname = pty_tax_lname>
            <cfset pty_tax_companyname = "">
        </cfif>
    
    	<!--- determine gift Day --->
		<cfif hiddenDonationType EQ 'monthly'>
            <cfif IsDefined('hiddenFreqDay')>
                <cfset gift_day = hiddenFreqDay>
            <cfelse>
                <cfset gift_day = 1>
            </cfif>
        <cfelse>
            <cfset gift_day = "">
        </cfif>
    
    	<!--- TAX receipt options for processor ---->
        <!--- use receipt type for Ink/No Ink --->
        <!--- TODO: HK receipting options --->
        <!--- receipt types
			TAX = TAX RECEIPT
			AWK = AWKNOWLEDGMENT RECEIPT
			TAX-HK = Hong Kong 
			TAX-IF = Ink Friendly
			TAX-ANNUAL = Annual Receipt for monthly gift
			TAX-HK-ANNUAL = Annual Receipt for monthly gift on HK page
			NONE = None requested / ineligible
			--->
		
		<cfif pty_tax_issuer EQ 'BCCHF'>
        
			<cfif gift_frequency EQ 'single'>
                <cfif pty_tax EQ "no">
                    <cfset receipt_type = 'NONE'>
                <cfelse>
                	<cfif IsDefined('pty_ink')>
                    	<cfif pty_ink EQ 'yes'>
                        	<cfset receipt_type = 'TAX-IF'>
                    	<cfelse>
                        	<cfset receipt_type = 'TAX'>
                    	</cfif>
                    <cfelse>
                    	<cfset receipt_type = 'TAX'>
                    </cfif>
                </cfif>
            <cfelse>
                <cfif pty_tax EQ "no">
                    <cfset receipt_type = 'NONE'>
                <cfelse>
                    <cfset receipt_type = 'TAX-ANNUAL'>
                </cfif>        
            </cfif>
        
        <cfelseif pty_tax_issuer EQ 'HK'>
        
        	<cfif gift_frequency EQ 'single'>
                <cfif pty_tax EQ "no">
                    <cfset receipt_type = 'NONE'>
                <cfelse>
                    <cfset receipt_type = 'TAX-HK'>
                </cfif>
            <cfelse>
                <cfif pty_tax EQ "no">
                    <cfset receipt_type = 'NONE'>
                <cfelse>
                    <cfset receipt_type = 'TAX-HK-ANNUAL'>
                </cfif>        
            </cfif>
                
        <cfelse>
        </cfif>
    
    	<!--- legacy: receipt generator method
			- check for receipt status 
			- append 'no receipt' to frequency for no receipt--->
        <cfif pty_tax EQ "no">
			<cfset gift_frequency="#hiddenDonationType# - No Receipt">
        <cfelse>
        	<cfset gift_frequency="#hiddenDonationType#">
        </cfif>
        
        <cfif gift_frequency EQ 'single'>
        	<cfset gift_frequency = 'Single'>
        </cfif>
    
    	<!--- add designation details to notes section --->
        <cfif IsDefined('hiddenDesignation') AND hiddenDesignation NEQ ''>
        
			<cfset gift_notes="designation:#hiddenDesignation# - #gift_notes#">
            
            <!--- for hydro donations - credit to team --->
            <cfif gift_type EQ 'Hydro'>
            
            	<cfif hiddenDesignation EQ 'powerEndow'>
                	<cfset hiddenTeamID = 6141>
                
                <cfelseif hiddenDesignation EQ 'powerAqua'>
                	<cfset hiddenTeamID = 6151>
                
                <cfelseif hiddenDesignation EQ 'powerDefrib'>
                	<cfset hiddenTeamID = 11933>
                    
                <cfelseif hiddenDesignation EQ 'powerDrill'>
                	<cfset hiddenTeamID = 12229>
                    
                </cfif>
            
            
            <cfelseif gift_type EQ 'FOT'>
            <!--- FOT designation could be contained here --->
            
            	<cfif hiddenDesignation EQ '4210'>
                	<cfset hiddenTeamID = 4210>
                
                <cfelseif hiddenDesignation EQ '4211'>
                	<cfset hiddenTeamID = 4211>
                
                <cfelseif hiddenDesignation EQ '4212'>
                	<cfset hiddenTeamID = 4212>
                    
                <cfelseif hiddenDesignation EQ '4213'>
                	<cfset hiddenTeamID = 4213>
                    
                </cfif>
            
            
			
			<cfelseif gift_type EQ 'ChildLife'
				OR gift_type EQ 'CBSA'>
            <!--- ChildLife designation is contained here --->
            
                <cfset hiddenTeamID = hiddenDesignation>
                
                <cfif hiddenTeamID EQ ''>
                	<cfset hiddenTeamID = 0>
                </cfif>
                
                <cfif hiddenSupID EQ ''>
                	<cfset hiddenSupID = 0>
                </cfif>
                
                
                <!--- enter the supporter name in notes --->
                <cfif hiddenSupID EQ 0>
                <cfelse>
                
                <cfquery name="selectName" datasource="bcchf_Superhero">
                SELECT SupFName FROM Hero_Members 
                WHERE SuppID = #hiddenSupID#
                </cfquery>
                
                <cfset gift_notes="#selectName.SupFName# - #gift_notes#">
                
                </cfif>
                
                
                
                <!--- enter the tean name in designation notes --->
                <cfif hiddenTeamID EQ 0>
                
                	<cfset gift_notes="Specific Purpose:Unspecified - #gift_notes#">
                
                <cfelse>
                
                    <cfquery name="selectTeam" datasource="bcchf_Superhero">
                    SELECT TeamName FROM Hero_Team 
                    WHERE TeamID = #hiddenTeamID#
                    </cfquery>
                    
                    <cfset gift_notes="Specific Purpose:#selectTeam.TeamName# - #gift_notes#">
                
                
                </cfif>
                
            
            <cfelseif gift_type EQ 'HSBC'>
            <!--- HSBC designation could be contained here --->	
            	<cfif TransitNumber EQ 35216>
                <!--- other --->
                	<cfset hiddenSupID = 35216>
                    <cfset gift_notes="Other Transit Number:#TransitNumberOther# - #gift_notes#"> 
                <cfelse>
                	<cfset hiddenSupID = TransitNumber>
                    <cfset gift_notes="#gift_notes#"> 
                </cfif>
            
            </cfif>
            
            
        <cfelse>
			<cfset gift_notes="#gift_notes#">
        </cfif>
        
        <!--- DRTV special --->
        <cfif gift_type EQ 'DRTV'>
        	<cfif IsDefined('DRTV_gift')>
            	<cfif DRTV_gift EQ 'Yes'>
                	<cfset gift_notes="Send Bear to Donor - #gift_notes#">
                </cfif>
            </cfif>
        </cfif>
        
        <!--- Jeans Day - record button and pin information provided by user --->
        <cfif gift_type EQ 'JeansDay'>
        
        	<cfif runnerPin EQ ''>
        		<cfset pinsPurchased = 0>
                <cfset RunnerPin = 0>
            <cfelse>
            	<cfset pinsPurchased = runnerPin>
                <cfset runnerPin = runnerPin>
            </cfif>
            
            <cfif runnerButton EQ ''>
            	<cfset buttonsPurchased = 0>
                <cfset RunnerButton = 0> 
        	<cfelse>
            	<cfset buttonsPurchased = runnerButton>
				<cfset runnerButton = runnerButton> 
            </cfif>
            
            <cfset ticketsPurchased = 0>
			<cfset RunnerBBQ = 0>
            
        <cfelse>
        
        	<cfset pinsPurchased = 0>
            <cfset buttonsPurchased = 0>
            <cfset ticketsPurchased = 0>
            <cfset RunnerPin = 0>
			<cfset RunnerButton = 0>
            <cfset RunnerBBQ = 0> 
        
        </cfif>
        
        <!--- AWK receipt for BFK sunshine sponsor --->
        <cfif gift_type EQ 'BFK' AND hiddenTeamID EQ 8020>
        
            <cfset receipt_type = 'AWK'>
            
            <cfset giftAdvantage = post_dollaramount>
            <cfset giftTaxable = 0>
        
        <cfelse>
        
			<cfset giftAdvantage = 0>
            <cfset giftTaxable = post_dollaramount>
        
        </cfif>
        
        <!--- add to Hero_Donate Token --->
        <!--- I cannot remember why this is here ---
		 AND (hiddenTributeType EQ 'hon-WOT' OR hiddenTributeType EQ 'mem-WOT')
		 --->
        <cfif gift_type EQ 'WOT'>
        	<cfset HeroDonateAdd = 1>
        <cfelseif gift_type EQ 'ICE'>
        	<cfset HeroDonateAdd = 1>
        </cfif>
        
        <cfif hiddenTributeType EQ 'JeansDay'>
        	<cfset HeroDonateAdd = 1>
        <cfelseif hiddenTributeType EQ 'event'>
        	<!--- other SHP events --->
        	<cfset HeroDonateAdd = 1>
        </cfif>
        
        <cfif hiddenDonationType EQ 'monthly'>
			<cfset Hero_Donate_Amount = post_dollaramount><!---  * 12 --->
        <cfelse>
            <cfset Hero_Donate_Amount = post_dollaramount>
        </Cfif> 
        
        <!--- TYS options --->
        <cfif IsDefined(Show)>
            
			<cfif Show EQ 'Yes'>
				<cfset Show = 1>
			<cfelse>
				<cfset Show = 0>
			</cfif>
            
		<cfelse>
            
			<cfset Show = 0>
            
		</cfif>
        
        <!--- we want to insert first as anonymous - 
			donor updates the scroll on confirmation page --->
		<cfset DName = 'Anonymous'>
        <!--- 2013-03-01 Default now shows donor name
			until the donor changes it on the confirmation screen --->
		<cfset DName = '#pty_fname# #pty_lname#'>
        
        <!--- ChildLife Gift Notes copy to 'Message' field --->
		<cfif gift_type EQ 'ChildLife'>
			<cfset Message = gift_notes>
        </cfif>
        
        <cfif gift_type EQ 'General'>
        	<!--- enter donor as anonymous for scroll on new donaton form --->
			<cfset DName = 'Anonymous'>
        </cfif>
        
        <!--- additional info --->
        <cfif NOT IsDefined("info_securities")><cfset info_securities = ""></cfif>
		<CFIF info_securities EQ ""><CFSET info_securities = " "></CFIF>
        
        <cfif NOT IsDefined("info_will")><cfset info_will = ""></cfif>
        <CFIF info_will EQ ""><CFSET info_will = " "></CFIF>
        
        <cfif NOT IsDefined("info_life")><cfset info_life = ""></cfif>
        <CFIF info_life EQ ""><CFSET info_life = " "></CFIF>
        
        <cfif NOT IsDefined("info_trusts")><cfset info_trusts = ""></cfif>
        <CFIF info_trusts EQ ""><CFSET info_trusts = " "></CFIF>
        
        <cfif NOT IsDefined("info_RRSP")><cfset info_RRSP = ""></cfif>
        <CFIF info_RRSP EQ ""><CFSET info_RRSP = " "></CFIF>
        
        <cfif NOT IsDefined("info_willinclude")><cfset info_willinclude = ""></cfif>
        <CFIF info_willinclude EQ ""><CFSET info_willinclude = " "></CFIF>
        
        <cfif NOT IsDefined("info_lifeinclude")><cfset info_lifeinclude = ""></cfif>
        <CFIF info_lifeinclude EQ ""><CFSET info_lifeinclude = " "></CFIF>
        
        <cfif NOT IsDefined("info_RSPinclude")><cfset info_RSPinclude = ""></cfif>
        <CFIF info_RSPinclude EQ ""><CFSET info_RSPinclude = " "></CFIF>
        
        <cfif NOT IsDefined("news_subscribe")><cfset news_subscribe = ""></cfif>
        <CFIF news_subscribe EQ ""><CFSET news_subscribe = " "></CFIF>
        
        <cfif NOT IsDefined("pty_subscr_r")><cfset pty_subscr_r = ""></cfif>
        <CFIF pty_subscr_r EQ ""><CFSET pty_subscr_r = " "></CFIF>
        
        <!--- if news subscribe is yes - set SOC and AR to yes --->
        <cfif news_subscribe EQ 1>
            <cfset SOC_subscribe = 1>
            <cfset AR_subscribe = 0>
        <cfelse>
            <cfset SOC_subscribe = 0>
            <cfset AR_subscribe = 0>
        </cfif>
        
        <!--- new method --- pty_subscr_r ---->
        <cfif pty_subscr_r EQ 1>
            <cfset SOC_subscribe = 1>
            <cfset news_subscribe = 1>
            <cfset AR_subscribe = 0>
        <cfelse>
            <cfset SOC_subscribe = 0>
            <cfset news_subscribe = 0>
            <cfset AR_subscribe = 0>
        </cfif>
        
        <!--- pledge details --->
        <cfif gift_type EQ 'Pledge'>
        
        	<cfset gPledge = 'Yes'>
            
			<cfif gift_pledge_DonorID EQ ''>
            <!--- no AWK fields have been passed --->
                <cfset gift_pledge_DonorID =''>
            <cfelse>
                <cfset gift_pledge_DonorID = gift_pledge_DonorID>        
            </cfif>
            
        <cfelse>
        
        	<cfif hiddenTributeType EQ 'pledge'>
            
            	<cfif gift_pledge_DonorID EQ ''>
				<!--- no AWK fields have been passed --->
                    <cfset gift_pledge_DonorID =''>
                <cfelse>
                    <cfset gift_pledge_DonorID = gift_pledge_DonorID>        
                </cfif>
            
            	<cfset gPledge = 'Yes'>
            
            <cfelse>
            
            	<cfset gift_pledge_DonorID =''>
            	<cfset gPledge = 'No'>
            
            </cfif>
        
        </cfif>
        
        <!--- tribute info  --->
        <cfif hiddenTributeType EQ 'hon' OR hiddenTributeType EQ 'mem'>
        
        	<cfset gTribute = 'Yes'>
        
			<cfif hiddenAWKtype EQ 'none'>
            <!--- no AWK fields have been passed --->
                <cfset cleanTrbMessage =''>
                <cfset srp_fname =''>
                <cfset srp_lname =''>
                <cfset trb_cardfrom =''>
            <cfelse>
                <cfset cleanTrbMessage = REReplaceNoCase(trb_message,"<[^>]*>","","ALL")>
            </cfif>
        
        <cfelse>
        
        	<cfset gTribute = 'No'>
        	<cfset cleanTrbMessage =''>
        
        </cfif>
        
    <cfcatch type="any">
    
    <cfmail to="csweeting@bcchf.ca" from="error@bcchf.ca" subject="error scrubbing donation form data" type="html">
    Error scrubbing donation form data
    Message: #cfcatch.Message#
    Detail: #cfcatch.Detail#
    <cfdump var="#cfcatch#" label="catch">
    <cfdump var="#form#" hide="POST_CARD_NUMBER,POST_CVV,FIELDNAMES,js_bcchf_cardnumber,js_bcchf_cvv,bcchf_cvv,bcchf_cc_number" label="transaction">
    </cfmail>
    
    </cfcatch>
    </cftry>
        
    
    <!--- attempt charge --->
	<cfset chargeAttempt = 1>
    <cfset attemptCharge = 1>
    <cfset returnMSG = 'beginAttempt-charging'>
    
    
	<!--- Trying to record - Attempt Record --->
    <!--- records a copy of form submission --->
    <cftry>
    
    	<cfset tAttemptRecord = {tDate = pty_date, 
								tUUID = variables.newUUID,
								tDonor = {
									dTitle = pty_title,
									dFname = pty_fname,
									dMname = pty_miname,
									dLname = pty_lname,
									dCname = pty_companyname,
									dTaxTitle = pty_tax_title,
									dTaxFname = pty_tax_fname,
									dTaxMname = pty_miname,
									dTaxLname = pty_tax_lname,
									dTaxCname = pty_tax_companyname,
									dAddress = {
										aOne = ptc_address,
										aTwo = ptc_addTwo,
										aCity = ptc_city,
										aProv = ptc_prov,
										aPost = ptc_post,
										aCountry = ptc_country
									},
									dEmail = ptc_email,
									dPhone = ptc_phone
								},
								tGift = post_dollaramount,
								tGiftAdv = giftAdvantage,
								tGiftTax = giftTaxable,
								tType = gift_type,
								tFreq = gift_frequency,
								tNotes = gift_notes,
								tSource = donation_source,
								eSource = ePhilSRC,
								tBrowser = {
									bUAgent = newBrowser,
									bName = uabrowsername,
									bMajor = uabrowsermajor,
									bVer = uabrowserversion,
									bOSname = uaosname,
									bOSver = uaosversion,
									dDevice = uadevicename,
									bDtype = uadevicetype,
									bDvend = uadevicevendor,
									bIP = newIP
								},
								tTType = pty_tax,
								tFreqDay = gift_day,
								tSHP = {
									tAdd = HeroDonateAdd,
									tToken = hiddenEventToken,
									tCampaign = hiddenEventCurrentYear,
									tTeamID = hiddenTeamID,
									tSupID = hiddenSupID,
									tDname = DName,
									tStype = hiddentype,
									tSmsg = Message,
									tSshow = Show,
									Hero_Donate_Amount = Hero_Donate_Amount
								},
								tJD = {
									Pins = RunnerPin,
									Buttons = RunnerButton,
									BBQ = RunnerBBQ,
									BBQl = '',
									cFriday = 0
								},
								tFORM = {
									hiddenDonationPCType = hiddenDonationPCType,
									hiddenDonationType = hiddenDonationType,
									hiddenFreqDay = hiddenFreqDay,
									hiddenGiftAmount = hiddenGiftAmount,
									donation_type = donation_type,
									gift_frequency = gift_frequency,
									gift_day = gift_day,
									hiddenTributeType = hiddenTributeType,
									gift_tributeType = gift_tributeType
									
								},
								adInfo = {
									iSecurity = info_securities,
									iWill = info_will,
									iLife = info_life,
									iTrust = info_trusts,
									iRRSP = info_RRSP,
									iWillInclude = info_willinclude,
									iLifeInclude = info_lifeinclude,
									iRSPinclude = info_RSPinclude,
									SOC_subscribe = SOC_subscribe,
									news_subscribe = news_subscribe,
									AR_subscribe = AR_subscribe,
									iWhere = info_where,
									iPastDonor = donated_before,
									gPledgeDet = gift_pledge_det,
									gPledgeDREID = gift_pledge_DonorID,
									gPledge = gPledge
									
								},
								tribInfo = {
									trbFname = trb_fname,
									trbLname = trb_lname,
									trbEmail = trb_email,
									trbAddress = trb_address,
									trbCity = trb_city,
									trbProv = trb_prov,
									trbPost = trb_post,
									srpFname = srp_fname,
									srpLname = srp_lname,
									trbCardfrom = trb_cardfrom,
									trbMsg = cleanTrbMessage,
									tribNotes = hiddenTributeType,
									cardSend = hiddenAWKtype,
									gTribute = gTribute
								}
			} />
            
            <cfset tAttempt = SerializeJSON(tAttemptRecord)>
            
            <cfset bDetail = SerializeJSON(tAttemptRecord.tBrowser)>
    	
    		<cfset tATPrec = recordTransAttempt(tAttempt)>
    
    
    	<cfinclude template="../includes/0log_donation.cfm">
    
    <cfcatch type="any">
    <cfmail to="csweeting@bcchf.ca" from="error@bcchf.ca" subject="error recording backup data" type="html">
    Error recording backup data - trying to record attempt record.
    Message: #cfcatch.Message#
    Detail: #cfcatch.Detail#
    <cfdump var="#cfcatch#" label="catch">
    <cfdump var="#form#" hide="POST_CARD_NUMBER,POST_CVV,FIELDNAMES,POST_DOLLARAMOUNT,js_bcchf_cardnumber,js_bcchf_cvv" label="transaction">
    </cfmail>
    </cfcatch>
    </cftry>
    
    <!--- check for XDS --->
    <cftry>
    <cfset goodXDS = checkXDS(APPLICATION.AppVerifyXDS, FORM.App_verifyToken, CGI.HTTP_REFERER)>
    
    <cfif goodXDS EQ 0>
    	<cfset attemptCharge = 0>
    </cfif>
    
    <!--- check IP against list --->
    <cfset goodIP = checkIPaddress(newIP)>
    
    <cfif goodIP EQ 0>
    	<cfset attemptCharge = 0>
    </cfif>
    
    <!--- check Fraudster MO --->
    <cfset fradulent = checkFraudsterMO(pty_tax_fname, pty_tax_lname, pty_fname, pty_lname, ptc_email, ptc_country, gift_frequency, post_dollaramount)>
    
    <cfif fradulent EQ 1>
    	<cfset attemptCharge = 0>
    </cfif>
    
    <cfcatch type="any">
    <cfset attemptCharge = 0>
    <cfmail to="csweeting@bcchf.ca" from="error@bcchf.ca" subject="error checking fraud data" type="html">
    Error checking fraud data
    Message: #cfcatch.Message#
    Detail: #cfcatch.Detail#
    <cfdump var="#cfcatch#" label="catch">
    <cfdump var="#form#" hide="POST_CARD_NUMBER,POST_CVV,FIELDNAMES,POST_DOLLARAMOUNT,js_bcchf_cardnumber,js_bcchf_cvv" label="transaction">
    </cfmail>
    </cfcatch>
    </cftry>
    
    
    
    <!--- if we can attempt to post to PayPal --->
    <cfif attemptCharge EQ 1>
    
		<!--- trying to post to PayPal--->
        <cftry>
        
        <!--- a monthly transaction requires a billing pland and subsequent approval of the billing agreement.
		one time gift requires a regular 'payment'
		--->
		
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
 
			<cfset SHPevent = DeserializeJSON(toString( result.fileContent ))>
        
            <!--- auth token --->
            <cfset requestToken='#SHPevent.token_type# #SHPevent.access_token#'>
            
            
            <cfset payDetail["intent"] = "sale">
			<cfset payDetail["payer"] = {}>
            <cfset payDetail.payer["payment_method"] = 'paypal' />
            <cfset payDetail["transactions"] = ArrayNew(1)>
            <cfset payDetail.transactions[1]["amount"] = {}>
            <cfset payDetail.transactions[1].amount["currency"] = 'CAD'>
            <cfset payDetail.transactions[1].amount["total"] = NumberFormat(post_dollaramount, 9.00)>
            <cfset payDetail.transactions[1]["description"] = '#DollarFormat(post_dollaramount)# #gift_type# Donation'>
            <cfset payDetail.transactions[1]["invoice_number"] = variables.newUUID>
            <cfset payDetail.transactions[1]["soft_descriptor"] = "BCCHF">
            <cfset payDetail["redirect_urls"] = {}>
            <cfset payDetail.redirect_urls["return_url"] = '#secureBCCHF#/donate/completeDonation-PayPal.cfm?Event=#gift_type#&UUID=#variables.newUUID#'>
            <cfset payDetail.redirect_urls["cancel_url"] = '#secureBCCHF#/donate/donation.cfm?DtnID=#variables.newUUID#&PayPalCancel=Yes&#CGI.QUERY_STRING#'>
            
            
            
            <cfhttp 
            result="result"
            method="post"
            url="#apiendPoint#v1/payments/payment" 
            >
                <cfhttpparam type="header" name="Content-Type" value="application/json" />
                <cfhttpparam type="header" name="Authorization" value="#requestToken#" />
                <cfhttpparam type="body" value="#serializeJSON(payDetail)#">
            </cfhttp>

 			<!--- check result header for 201 status code --->
			<cfif result.responseheader.status_code EQ 201>
 				
                <!--- payment has been 'created' on PayPal --->
                <!--- parse response --->
				<cfset SHPevent = DeserializeJSON(toString( result.fileContent ))>
    
				<cfset i = 0>
    			<cfset rdrLinkFnd = 0>
    			
    			
                <!--- check for execution link --->
    			<cfloop condition = "rdrLinkFnd EQUALS 0">
    				<cfset i = i + 1>
    
					<cfif StructKeyExists(SHPevent.links[i], 'method') 
                        AND SHPevent.links[i].method EQ 'REDIRECT'>
                        <cfset rdrLinkFnd = 1>
                        <cfset rdrLnk = SHPevent.links[i].href>
                    </cfif>
                    
				</cfloop>
                
                <!---- OK to proceed with PayPal Payment ID --->
				<cfset rqst_transaction_approved = 1>
				<cfset payPalPaymentID = SHPevent.id>

    
			<cfelse>
                
                <!--- non 201 code response - indicate error --->
                <cfset rqst_exact_respCode = '#result.responseheader.status_code# Error Connectiong to PayPal.'>
                <cfset rqst_transaction_approved = 0>
                
                <cfmail to="csweeting@bcchf.ca" from="error@bcchf.ca" subject="payPal Response error result" type="html">
                Response other than 201 when creating transaction
                <cfdump var="#result#" label="catch">
                <cfdump var="#form#" hide="POST_CARD_NUMBER,POST_CVV,FIELDNAMES,POST_DOLLARAMOUNT,js_bcchf_cardnumber,js_bcchf_cvv" label="transaction">
                </cfmail>

			</cfif>
            
            
            
    
    	<cfelse>
        
        	<!--- PayPal login failure --->
			<cfset rqst_transaction_approved = 0>
            <cfset rqst_exact_respCode = 'Error Connectiong to PayPal.'>
            
            <cfmail to="csweeting@bcchf.ca" from="error@bcchf.ca" subject="payPal Login error result" type="html">
            Login Failure
            <cfdump var="#result#" label="catch">
            <cfdump var="#form#" hide="POST_CARD_NUMBER,POST_CVV,FIELDNAMES,POST_DOLLARAMOUNT,js_bcchf_cardnumber,js_bcchf_cvv" label="transaction">
            </cfmail>
        
        </cfif>


        <cfcatch type="any">
        <cfmail to="csweeting@bcchf.ca" from="error@bcchf.ca" subject="error in paypal creation process" type="html">
        error in exact process
        Message: #cfcatch.Message#
        Detail: #cfcatch.Detail#
        <cfdump var="#cfcatch#" label="catch">
        <cfdump var="#form#" hide="POST_CARD_NUMBER,POST_CVV,FIELDNAMES,POST_DOLLARAMOUNT,js_bcchf_cardnumber,js_bcchf_cvv" label="transaction">
        </cfmail>
        </cfcatch>
        </cftry>
            

    <cfelse>
    	<!--- charge not attempted - IP blocked --->
    
    	<cfset rqst_transaction_approved = 0>
        <cfset rqst_exact_respCode = 0>
    	<cfset chargeAproved = 0>
        <cfset exact_respCode = 0>
        <cfset returnMSG = 'Charge Not Attempted'>
    
    </cfif>
    
    
    
    <!--- NOT recorded in PayPal --->
    <cfif rqst_transaction_approved NEQ 1>
    
    	<!--- abort and show messages --->
    	<cfset chargeAproved = 0>
        <cfset exact_respCode = rqst_exact_respCode>
        <cfset returnMSG = 'charging-notapproved'>

		<!--- END of NOT APPROVED AREA --->        
        <!----------------------------------- --------------------------------------> 
        <!--- will return exact message for display to the user ---->   
        
        
        
    <cfelse>
    <!--- transaction created in PayPal --->
    
    	<cfset chargeAproved = 1>
        <cfset returnMSG = 'charging-approved'>
        
    	<!--- record transaction information 
			
			1. Dump content of form to txt file
			2. Insert core transaction information into db
				- Transaction Information
				- Donor Information
				- SHP tables if necessary
			3. Update additional information
			4. Update tribute information
		
		--->
        
        <!--- try and record the transaction details in a flat txt file --->
        <cftry>
        
			<!--- directories --->
            <cfset monthlyDumpDirectory = DateFormat(Now(), 'mm-yy')>
            <Cfset dailyDumpDirectory = DateFormat(Now(), 'DD')>
            
            <cfset dumpDirectory = "#APPLICATION.WEBLINKS.File.service#\transactions\#monthlyDumpDirectory#\#dailyDumpDirectory#\">
            
            <!--- check if directory exists --->
            <cfif DirectoryExists(dumpDirectory)>
                <!--- directory exists - we are all good --->
            <cfelse>
                <!--- need to create directory --->
                <cfdirectory directory="#dumpDirectory#" action="create">
                        
            </cfif>
            
            <!--- add timestamp to file --->
            <Cfset append = "#DateFormat(Now())#---#TimeFormat(Now(), 'HH-mm-ss.l')# - paypal">
            
            <!--- dump form to file --->
            <!--- hide PCI fields --->
            <cfdump var="#form#" output="#dumpDirectory#bcchildren_full_donation_dump_date-#append#.txt" hide="POST_CARD_NUMBER,POST_CVV,FIELDNAMES,POST_DOLLARAMOUNT,js_bcchf_cardnumber,js_bcchf_cvv" type="html">
        
    	<cfcatch type="any">
        
        <cfmail to="csweeting@bcchf.ca" from="error@bcchf.ca" subject="error recording backup data" type="html">
        Error recording backup data - trying to create txt file of transaction
        Message: #cfcatch.Message#
        Detail: #cfcatch.Detail#
        <cfdump var="#cfcatch#" label="catch">
        <cfdump var="#form#" hide="POST_CARD_NUMBER,POST_CVV,FIELDNAMES,js_bcchf_cardnumber,js_bcchf_cvv,bcchf_cvv,bcchf_cc_number" label="transaction">
        </cfmail>
        
        </cfcatch>
        </cftry>
        
    	
        <!--- exact date from server --->
		<cfset exact_odbcDT = pty_Date>
        
        
        <!--- Try to Insert PayPal Created Payment Record Into Database --->
        <cftry>
       
        
        
        <!--- transaction information--->
        <CFQUERY datasource="#APPLICATION.DSN.Superhero#" name="insert_record" dbtype="ODBC">
        INSERT INTO tblPayPal (dtnDate, exact_date, dtnAmt, dtnBenefit, dtnReceiptAmt, dtnReceiptType, dtnBatch, dtnSource, rqst_dollaramount, pge_UUID, dtnIP, dtnBrowser, payPalPaymentID, payPalEXE) 
        VALUES (#pty_Date#, #exact_odbcDT#, '#post_dollaramount#', '#giftAdvantage#', '#giftTaxable#', '#receipt_type#', 'Online', '#donation_source#', '#post_dollaramount#', '#variables.newUUID#', '#newIP#', '#bDetail#', '#payPalPaymentID#', '#rdrLnk#') 
        </CFQUERY>
                
        
        <!--- if the try block fails --->
        <!--- send email with details to isbcchf --- log transaction --->
        <cfcatch type="any">
			<cfmail to="csweeting@bcchf.ca" from="error@bcchf.ca" subject="error recording transaction data" type="html">
            Error recording database data into tblTransaction
            Message: #cfcatch.Message#
            Detail: #cfcatch.Detail#
            <cfdump var="#cfcatch#" label="catch">
            <cfdump var="#form#" hide="POST_CARD_NUMBER,POST_CVV,FIELDNAMES,POST_DOLLARAMOUNT,js_bcchf_cardnumber,js_bcchf_cvv">
            </cfmail>
        </cfcatch>
        </cftry>
        
        
        <!--- check URL for email referal --->
        <cftry>
        
        <!--- lookup email and add note that donation has been made --->
        <cfif IsDefined('emailReferal') AND emailReferal NEQ ''>
        
            <cfset eRefUpdate = checkEmailReff(emailReferal, variables.newUUID)>
        
        </cfif>
        
        
        <cfcatch type="any">
        	<!--- do nothing --->
        </cfcatch>
        </cftry>

                
        <!--- try and setup ecard --->
        <cftry>
        
        
        <cfif gift_type EQ 'eCard'>
        <!--- get E card message info for tribute --->
        
        	<!--- ecard date --->
            <cftry>
            <cfset sendECardDate = CreateODBCDate(cardSend_date)>
            <cfcatch type="any">
            <cfset sendECardDate = pty_date>
            </cfcatch>
            </cftry>
            
            <!--- parse the sending date --->
			<cfset sendYear = DateFormat(sendECardDate, 'YYYY')>
			<cfset sendMonth = DateFormat(sendECardDate, 'MM')>
            <cfset sendDay = DateFormat(sendECardDate, 'DD')>
        
        	
			<!--- insert into ecard tables --->
            <CFQUERY datasource="#APPLICATION.DSN.Superhero#" name="insert_card">
            INSERT INTO eCard (CARDCREATEDATE, sendDate, sendYear, sendMonth, sendDay, sender, sendersemail, recipient, recipientsemail, message, card, occasion, sendActive, pge_UUID) 
            VALUES (#pty_date#, #sendECardDate#, #sendYear#, #sendMonth#, #sendDay#, '#cardSend_fname# #cardSend_lname#', '#cardSend_email#', '#cardRec_fname# #cardRec_lname#', '#cardRec_email#', '#URLEncodedFormat(eCardMessagehidden)#', '#eCard_image#', '#eCard_occasion#', 0, '#variables.newUUID#') 
            </CFQUERY>
    
    		<!--- strip html for download ---->
            <cfset cleanEcardMessage = REReplaceNoCase(eCardMessage,"<[^>]*>","","ALL")>
            
            <!--- update tblGeneral with ecard info --->
            <cfquery name="updateEcardData" datasource="#APPLICATION.DSN.Superhero#">
            UPDATE tblAttempt
            SET	gift_tribute = 'yes',
                trb_fname = '#cardRec_fname#',
                trb_lname = '#cardRec_lname#', 
                trb_address = '#cardRec_email#', 
                srp_fname = '', 
                srp_lname = '', 
                trb_cardfrom = '#cardSend_fname# #cardSend_lname# #cardSend_email#', 
                trb_msg = '#cleanEcardMessage#', 
                trib_notes = 'eCard',
                card_send = 'eCard'
            WHERE pge_UUID = '#variables.newUUID#'
            </cfquery>
            
            
            <cfif eCard_image EQ 'holiday7.png'
				OR eCard_image EQ 'holiday8.png'
				OR eCard_image EQ 'holiday9.png'>
            	
                <cfset TeamID = 7666>
            <cfelse>
            	<cfset TeamID = 0>
            </cfif>
            
            <!--- also, insert into hero_Donate 
        	<cfquery name="insertHeroDonation" datasource="#APPLICATION.DSN.Superhero#">
            INSERT INTO Hero_Donate (Event, Campaign, TeamID, Name, Type, Message, Show, DonTitle, DonFName, DonLName, Email, don_date, rqst_authorization_num, Amount, SupID, POST_REFERENCE_NO, pge_UUID) 
            VALUES ('eCard', 0, #TeamID#, '#cardSend_fname# #cardSend_lname#', '#eCard_occasion#', '#eCard_image#', 0, '#pty_title#', '#pty_fname#', '#pty_lname#', '#ptc_email#', #pty_Date#, '#rqst_authorization_num#', #rqst_dollaramount#, 0, '#rqst_sequenceno#', '#variables.newUUID#')
            </cfquery>--->
        
        
        
        
        
        </cfif>
        
        
        <!--- if the try block fails --->
        <!--- send email with details to isbcchf --- log transaction --->
        <cfcatch type="any">
			<cfmail to="csweeting@bcchf.ca" from="error@bcchf.ca" subject="error recording transaction data" type="html">
            Error recording database data into eCard
            Message: #cfcatch.Message#
            Detail: #cfcatch.Detail#
            <cfdump var="#cfcatch#" label="catch">
            <cfdump var="#form#" hide="POST_CARD_NUMBER,POST_CVV,FIELDNAMES,POST_DOLLARAMOUNT,js_bcchf_cardnumber,js_bcchf_cvv">
            </cfmail>
        </cfcatch>
        </cftry>
        
        
        <!--- ---------------------------- end of database processing -------------------------------------------- --->

		<!--- no emails required at this time for a created paypal trasaction
			- user will be pseed to paypal to confirm details of transaction
			- user will be passed back to us to execute transaction on completeDonation-PayPal.cfm
			--->
        
        <!--- message about frequency  --->
        <cfset chargeMSG = gift_frequency>
        <!--- after inserting in DB and sending emails --->
        <cfset returnSuccess = 1>
        
	</cfif><!--- end of if created in paypal --->


	<cftry>
	<cfif gift_type EQ 'Stories'>
		<cfset hiddenEventToken = 'Stories'>
    </cfif>
	<cfcatch type="any">
    </cfcatch>
    </cftry>
    
    <!--- return message --->
    <cfset ChargeAttmpt = {
		cAttempted = chargeAttempt,
		cApproved = chargeAproved,
		cMSG = chargeMSG,
		exact_respCode = exact_respCode,
		ipBlocker = ipBlocker,
		goodXDS = goodXDS,
		ppEXURL = rdrLnk,
		ppID = payPalPaymentID 
		} />

	<!--- this is the structure of the return message --->
    <cfset SHPdonationReturnMSG = {
	Success = returnSuccess,
	ChargeAttmpt = ChargeAttmpt,
	Message = returnMSG,
	EventToken = hiddenEventToken,
	UUID = variables.newUUID,
	tGenTwoID = tGenTwoID
	} />
    
    
    <cfreturn SHPdonationReturnMSG>


</cffunction>
<!--- End of main form processor ---- --------------------------------------------------------->





<!---- MOBILE FORM Processor ------------------------------------------------------------------------------>
<!--- some validation occurs before we hit this step --->
<!--- high level validation not required at this time --->
<!--- mixed results with this ... --- verifyClient="yes" --->
<cffunction name="submitMobileDonationFormPayPal" access="remote" >
    
	<!--- donor information --->
    <cfargument name="js_bcchf_firstname" type="string" required="yes">
    <cfargument name="js_bcchf_lastname" type="string" required="yes">
    
    <cfargument name="js_bcchf_corpo_name" type="string" required="yes">
    
    <cfargument name="js_bcchf_address" type="string" required="yes">
    <cfargument name="ptc_addTwo" type="string" required="no">
    <cfargument name="js_bcchf_city" type="string" required="yes">
    <cfargument name="js_bcchf_country" type="string" required="yes">
    <cfargument name="js_bcchf_province" type="string" required="yes">
    <cfargument name="js_bcchf_postal" type="string" required="yes">
    <cfargument name="js_bcchf_email" type="string" required="yes">
    <cfargument name="js_bcchf_phone" type="string" required="no">
    
    <!--- tribute information --->
    <cfargument name="js_bcchf_honour" type="string" required="no">
    <cfargument name="js_bcchf_send_email" type="string" required="no">
    <cfargument name="js_bcchf_recepient_email" type="string" required="no">
    <cfargument name="trb_message" type="string" required="no">
    <cfargument name="trb_cardfrom" type="string" required="no">
    
    <!--- SHP event scroll details --->
    <cfargument name="hiddenEventToken" type="string" required="no">
    <cfargument name="hiddenEventCurrentYear" type="string" required="no">
    <cfargument name="hiddenTeamID" type="string" required="no">
    <cfargument name="hiddenSupID" type="string" required="no">
    <cfargument name="DName" type="string" required="no">
    <cfargument name="hiddentype" type="string" required="no">
    <cfargument name="Message" type="string" required="no">
    <cfargument name="Show" type="string" required="no">
    <cfargument name="ShowAnonymous" type="string" required="no">
    
    <!--- additional details --->
    <cfargument name="js_bcchf_gift_details" type="string" required="no">
    <cfargument name="info_where" type="string" required="no">
    
    <!--- subscriptions --->
    <cfargument name="news_subscribe" type="string" required="no">
    
    <!--- pledge details --->
    <cfargument name="gift_pledge_det" type="string" required="no">
    <cfargument name="js_bcchf_pledge_id" type="string" required="no"><!---  --->
    
    <!--- donation information --->
    <!--- gift type --->
    <cfargument name="hiddenGiftType" type="string" required="yes">
    <cfargument name="hiddenTributeType" type="string" required="yes">
	<!--- gift amount --->
    <cfargument name="hiddenGiftAmount" type="string" required="yes">
    <!--- Personal or Corporate - set tax values with this info --->
    <cfargument name="js_bcchf_donate_type" type="string" required="yes">
    <!--- indicated frequency --->
    <cfargument name="hiddenDonationType" type="string" required="yes">
    <!--- monthly day  not required for single --->
    <cfargument name="js_bcchf_bill_cycle" type="string" required="no">
    <!--- tribute type --->
    <!--- eCard for eCards - Pledge for Pledge --->
    <cfargument name="js_bcchf_gift_type" type="string" required="yes">
    
    <!--- tax receipt information --->
    <cfargument name="pty_tax" type="string" required="yes">
    <cfargument name="pty_ink" type="string" required="no">
    
    
    <!--- cardholder data --->
    <cfargument name="post_card_number" type="string" required="no">
    <cfargument name="post_expiry_month" type="string" required="no">
    <cfargument name="post_expiry_year" type="string" required="no">
    <cfargument name="post_cardholdersname" type="string" required="no">
    <cfargument name="post_CVV" type="string" required="no">
    
    <!--- email referal conditions --->
    <cfargument name="emailReferal" type="string" required="no">
    
    <!--- JeansDay Information --->
    <cfargument name="runnerPin" type="string" required="no">
    <cfargument name="runnerButton" type="string" required="no">
    
    <!--- BCCHF sandbox 
	<cfset ClientID = 'AU7JuxDyWHnqy5vngOapa6_ndHU-0NfJP37DZtG-x6E_KPjH9KiKetcSb9AY'>
    <cfset clientPass = 'EGSdMhC9MagPgmY8QwOs_yzMFZ69QSNb4Y4ytGqv0HE0SB-QqOl9C7rTdCmJ'>
	<cfset apiendPoint = 'https://api.sandbox.paypal.com/'>
    <cfset secureBCCHF = 'http://test.secure.bcchf.ca/'>--->
    
    
    <!--- BCCLF LIVE --->
	<cfset ClientID = 'AUQ0kRD4EXX6hhe3nQ4Uu78Q18Ea2F2_hHTAL5LsrHgIRvk1xtYvsq-TvH8p'>
    <cfset clientPass = 'ENnkbRA4zr4vQ84FJvB1WV-vV8CgAL-BpiF22pejC_m6C2AMudlH5RvbrtsD'>
        
    <cfset apiendPoint = 'https://api.paypal.com/'>
    <cfset secureBCCHF = 'https://secure.bcchf.ca/'>
    
    <!--- SERVER Date at submission --->
    <cfif NOT IsDefined("pty_date")><cfset pty_date= "#Now()#"></cfif>
    
    <!--- create UUID to access info --->
    <cfset variables.newUUID=createUUID()>
    <!--- Recording IP Addresses  and Browser info of these transactions --->
	<cfset newIP = CGI.REMOTE_ADDR>
	<cfset newBrowser = CGI.HTTP_USER_AGENT> 
    <cfset ipBlocker = 0>
    
    <!--- set the source --->
	<cfset donation_source = 'Mobile Donation Form'>
    
    <!--- read ePhil Source --->
    <cfif IsDefined('ePhilanthropySource')>
    	<cfset ePhilSRC = ePhilanthropySource>
    <cfelse>
    	<cfset ePhilSRC = ''>
    </cfif>
    
    <!--- set transaction amount --->
    <cfset hiddenGiftAmount = REREPlace(hiddenGiftAmount, '[^0-9.]','','all')>
    <cfset post_dollaramount = hiddenGiftAmount>
    
    <!--- default setting is not adding to hero donate ---> 
    <cfset HeroDonateAdd = 0>
    
    <!--- successful variables --->
    <cfset chargeSuccess = 0>
    <cfset donationSuccess = 0>
    <cfset chargeAttempt = 0>
    <cfset chargeAproved = 0>
    <cfset chargeMSG = "">
    <cfset tGenTwoID = 0>
    
    <!--- construct return message --->
    <cfset returnSuccess = 0>
    <cfset returnMSG = 'beginAttempt'>
    <cfset exact_respCode = 0>
    
    <cfset PTY_TAX_ISSUER = 'BCCHF'>
    
    <cfset pty_tax_title = ''>
    <cfset pty_tax_fname = TRIM(js_bcchf_firstname)>
	<cfset pty_tax_lname = TRIM(js_bcchf_lastname)>
	<cfset pty_tax_companyname = TRIM(js_bcchf_corpo_name)>
    
    <!--- set gift type on form pre load --->
    <cfset gift_type = hiddenGiftType>
	
    <cfset pty_title = ''> 
	<cfset pty_fname = pty_tax_fname>
    <cfset pty_miname = ''>
    <cfset pty_lname = pty_tax_lname>
    
    <cfset pty_companyname = pty_tax_companyname>
    <cfset ptc_email = js_bcchf_email>
    
    <cfset ptc_address = js_bcchf_address>
    <cfset ptc_addtwo = ''>
    <cfset ptc_city = js_bcchf_city>
    <cfset ptc_post = js_bcchf_postal>
    <cfset ptc_prov = js_bcchf_province>
    <cfset ptc_country = js_bcchf_country>
    <cfset ptc_phone = js_bcchf_phone>
    
    <cfif hiddenDonationType EQ 'once'>
    	<cfset gift_frequency = 'Single'>
    <cfelse>
    	<cfset gift_frequency = 'Monthly'>
    </cfif>
    
    <cfif gift_frequency EQ 'once'>
    	<cfset gift_frequency = 'Single'>
    </cfif>
    
    <cfset gift_notes = js_bcchf_gift_details>
    
	<cfset post_expiry_date = '#post_expiry_month#/#post_expiry_year#'>
    
    <cfset trb_msgType =''>
    
    <!--- scrub some variables for db loading --->    
    <cftry>
    
    	<!--- corp / personal tax settings --->
		<cfif hiddenDonationPCType EQ 'corporate'>
            <!--- corporate donation --->
            <cfset pty_tax_title = "">
            <cfset pty_tax_fname = "">
            <cfset pty_tax_lname = "">
            <cfset pty_companyname = pty_tax_companyname>
        <cfelse>
            <!--- personal donation fields --->
            <cfset pty_title = pty_tax_title>
            <cfset pty_fname = pty_tax_fname>
            <cfset pty_lname = pty_tax_lname>
            <cfset pty_tax_companyname = "">
        </cfif>
            
        <!--- determine gift Day --->
        <cfif gift_frequency EQ 'monthly'>
            <cfif IsDefined('js_bcchf_bill_cycle')>
                <cfset gift_day = js_bcchf_bill_cycle>
            <cfelse>
                <cfset gift_day = 1>
            </cfif>
        <cfelse>
            <cfset gift_day = "">
        </cfif>
    	
        <!--- Tax Receipt options for processor ---->
        <!--- use receipt type for Ink/No Ink --->
        <!--- TODO: HK receipting options --->
        <!--- receipt types
			TAX = TAX RECEIPT
			AWK = AWKNOWLEDGMENT RECEIPT
			TAX-HK = Hong Kong 
			TAX-IF = Ink Friendly
			TAX-ANNUAL = Annual Receipt for monthly gift
			TAX-HK-ANNUAL = Annual Receipt for monthly gift on HK page
			NONE = None requested / ineligible
			--->
		
		<cfif pty_tax_issuer EQ 'BCCHF'>
        
			<cfif gift_frequency EQ 'Single'>
                <cfif pty_tax EQ "no">
                    <cfset receipt_type = 'NONE'>
                <cfelse>
                	<cfif IsDefined('pty_ink')>
                    	<cfif pty_ink EQ 'yes'>
                        	<cfset receipt_type = 'TAX-IF'>
                    	<cfelse>
                        	<cfset receipt_type = 'TAX'>
                    	</cfif>
                    <cfelse>
                    	<cfset receipt_type = 'TAX'>
                    </cfif>
                </cfif>
            <cfelse>
                <cfif pty_tax EQ "no">
                    <cfset receipt_type = 'NONE'>
                <cfelse>
                    <cfset receipt_type = 'TAX-ANNUAL'>
                </cfif>        
            </cfif>
        
        </cfif>

		<!--- legacy: receipt generator method
			- check for receipt status 
			- append 'no receipt' to frequency for no receipt--->
        <cfif pty_tax EQ "no">
			<cfset gift_frequency="#gift_frequency# - No Receipt">
        <cfelse>
        	<cfset gift_frequency="#gift_frequency#">
        </cfif>
        
        <cfif gift_frequency EQ 'single'>
        	<cfset gift_frequency = 'Single'>
        </cfif>
        
        <!--- FREQUENCY --->
        <cfif IsDefined('js_bcchf_bill_cycle')>
        	<cfset js_bcchf_bill_cycle = js_bcchf_bill_cycle>
        <cfelse>
        	<cfset js_bcchf_bill_cycle = ''>
        </cfif>
        
        
        <!--- add designation details to notes section --->
        <cfif IsDefined('hiddenDesignation') AND hiddenDesignation NEQ ''>
        
			<cfset gift_notes="designation:#hiddenDesignation# - #gift_notes#">
            
            <cfif gift_type EQ 'FOT'>
            <!--- FOT designation could be contained here --->
            
            	<cfif hiddenDesignation EQ '4210'>
                	<cfset hiddenTeamID = 4210>
                
                <cfelseif hiddenDesignation EQ '4211'>
                	<cfset hiddenTeamID = 4211>
                
                <cfelseif hiddenDesignation EQ '4212'>
                	<cfset hiddenTeamID = 4212>
                    
                <cfelseif hiddenDesignation EQ '4213'>
                	<cfset hiddenTeamID = 4213>
                    
                </cfif>
            
            
            <cfelseif gift_type EQ 'ChildLife'>
            <!--- ChildLife designation is contained here --->
            
                <cfset hiddenTeamID = hiddenDesignation>
                
                <cfif hiddenTeamID EQ ''>
                	<cfset hiddenTeamID = 0>
                </cfif>
                
                <cfif hiddenSupID EQ ''>
                	<cfset hiddenSupID = 0>
                </cfif>
                
                
                <!--- enter the supporter name in notes --->
                <cfif hiddenSupID EQ 0>
                <cfelse>
                
                <cfquery name="selectName" datasource="bcchf_Superhero">
                SELECT SupFName FROM Hero_Members 
                WHERE SuppID = #hiddenSupID#
                </cfquery>
                
                <cfset gift_notes="#selectName.SupFName# - #gift_notes#">
                
                </cfif>
                
                
                
                <!--- enter the tean name in designation notes --->
                <cfif hiddenTeamID EQ 0>
                
                	<cfset gift_notes="Specific Purpose:Unspecified - #gift_notes#">
                
                <cfelse>
                
                    <cfquery name="selectTeam" datasource="bcchf_Superhero">
                    SELECT TeamName FROM Hero_Team 
                    WHERE TeamID = #hiddenTeamID#
                    </cfquery>
                    
                    <cfset gift_notes="Specific Purpose:#selectTeam.TeamName# - #gift_notes#">
                
                
                </cfif>
                
            
            <cfelseif gift_type EQ 'HSBC'>
            <!--- HSBC designation could be contained here --->	
            	<cfif TransitNumber EQ 35216>
                <!--- other --->
                	<cfset hiddenSupID = 35216>
                    <cfset gift_notes="Other Transit Number:#TransitNumberOther# - #gift_notes#"> 
                <cfelse>
                	<cfset hiddenSupID = TransitNumber>
                    <cfset gift_notes="#gift_notes#"> 
                </cfif>
            
            </cfif>
            
            
        <cfelse>
			<cfset gift_notes="#gift_notes#">
        </cfif>
        
        <!--- Event Specific Database Actions --->
        <!--- Jeans Day - record button and pin information provided by user --->
        <cfif gift_type EQ 'JeansDay'>
        
        	<cfif runnerPin EQ ''>
        		<cfset pinsPurchased = 0>
            <cfelse>
            	<cfset pinsPurchased = runnerPin>
            </cfif>
            
            <cfif runnerButton EQ ''>
            	<cfset buttonsPurchased = 0>
        	<cfelse>
            	<cfset buttonsPurchased = runnerButton>
            </cfif>
            
        <cfelse>
        
        	<cfset pinsPurchased = 0>
            <cfset buttonsPurchased = 0>
        
        </cfif>
        
        <!--- Jeans Day - record button and pin information provided by user --->
        <cfif gift_type EQ 'JeansDay'>
        
        	<cfif runnerPin EQ ''>
        		<cfset pinsPurchased = 0>
                <cfset RunnerPin = 0>
            <cfelse>
            	<cfset pinsPurchased = runnerPin>
                <cfset runnerPin = runnerPin>
            </cfif>
            
            <cfif runnerButton EQ ''>
            	<cfset buttonsPurchased = 0>
                <cfset RunnerButton = 0> 
        	<cfelse>
            	<cfset buttonsPurchased = runnerButton>
				<cfset runnerButton = runnerButton> 
            </cfif>
            
            <cfset ticketsPurchased = 0>
			<cfset RunnerBBQ = 0>
            
        <cfelse>
        
        	<cfset pinsPurchased = 0>
            <cfset buttonsPurchased = 0>
            <cfset ticketsPurchased = 0>
            <cfset RunnerPin = 0>
			<cfset RunnerButton = 0>
            <cfset RunnerBBQ = 0> 
        
        </cfif>
        
        <!--- AWK receipt for BFK sunshine sponsor --->
        <cfif gift_type EQ 'BFK' AND hiddenTeamID EQ 8020>
        
            <cfset receipt_type = 'AWK'>
            
            <cfset giftAdvantage = post_dollaramount>
            <cfset giftTaxable = 0>
        
        <cfelse>
        
			<cfset giftAdvantage = 0>
            <cfset giftTaxable = post_dollaramount>
        
        </cfif>
		
        <!--- add to Hero_Donate Token --->
        <!--- I cannot remember why this is here ---
		 AND (hiddenTributeType EQ 'hon-WOT' OR hiddenTributeType EQ 'mem-WOT')
		 --->
        <cfif gift_type EQ 'WOT'>
        	<cfset HeroDonateAdd = 1>
        <cfelseif gift_type EQ 'ICE'>
        	<cfset HeroDonateAdd = 1>
        </cfif>
        
        <cfif hiddenTributeType EQ 'JeansDay'>
        	<cfset HeroDonateAdd = 1>
        <cfelseif hiddenTributeType EQ 'event'>
        	<!--- other SHP events --->
        	<cfset HeroDonateAdd = 1>
        </cfif>
        
        <!--- TYS options --->
        <cfif IsDefined('Show')>
            
			<cfif Show EQ 'Yes'>
				<cfset Show = 1>
			<cfelse>
				<cfset Show = 0>
			</cfif>
            
		<cfelse>
            
			<cfset Show = 0>
            
		</cfif>
        
        <!--- we want to insert first as anonymous - 
			donor updates the scroll on confirmation page --->
		<cfset DName = 'Anonymous'>
        <!--- 2013-03-01 Default now shows donor name
			until the donor changes it on the confirmation screen --->
		<cfset DName = '#pty_fname# #pty_lname#'>
        
        <!--- ChildLife Gift Notes copy to 'Message' field --->
		<cfif gift_type EQ 'ChildLife'>
			<cfset Message = gift_notes>
        </cfif>
        
        <cfif gift_type EQ 'General'>
        	<!--- enter donor as anonymous for scroll on new donaton form --->
			<cfset DName = 'Anonymous'>
        </cfif>
        
        <cfif gift_frequency EQ 'monthly' OR gift_frequency EQ 'monthly - no receipt'>
			<cfset Hero_Donate_Amount = post_dollaramount><!---  * 12 --->
        <cfelse>
            <cfset Hero_Donate_Amount = post_dollaramount>
        </Cfif> 

		<!--- additional info --->
        <cfif NOT IsDefined("js_bcchf_allow_email")><cfset js_bcchf_allow_email = ""></cfif>
		<CFIF js_bcchf_allow_email EQ ""><CFSET js_bcchf_allow_email = " "></CFIF>
            
		<!--- if news subscribe is yes - set SOC and AR to yes --->
		<cfif js_bcchf_allow_email EQ 1>
			<cfset SOC_subscribe = 1>
            <cfset news_subscribe = 1>
            <cfset AR_subscribe = 0>
        <cfelse>
         	<cfset SOC_subscribe = 0>
            <cfset news_subscribe = 0>
            <cfset AR_subscribe = 0>
        </cfif>

		<!--- pledge details --->
        <cfif gift_type EQ 'Pledge'>
        
        	<cfset gPledge = 'Yes'>
            <cfset gift_pledge_DonorID =''>
            <cfset gPledgeDeatil = js_bcchf_pledge_id>
            
        <cfelse>
        
        	<cfif js_bcchf_gift_type EQ 'pledge'>
            
            	<cfset gPledge = 'Yes'>
				<cfset gift_pledge_DonorID =''>
                <cfset gPledgeDeatil = js_bcchf_pledge_id>
                            
            <cfelse>
            
            	<cfset gPledgeDeatil = ''>
            	<cfset gift_pledge_DonorID =''>
            	<cfset gPledge = 'No'>
            
            </cfif>
        
        </cfif>

		<!--- tribute details --->
        <cfif JS_BCCHF_GIFT_TYPE EQ 'honour' OR JS_BCCHF_GIFT_TYPE EQ 'memory'>
            
            <cfset gTribute = 'yes'>
            
			<cfif JS_BCCHF_GIFT_TYPE EQ 'honour'>
                <cfset hiddenTributeType = 'hon'>
            <cfelseif JS_BCCHF_GIFT_TYPE EQ 'memory'>
                <cfset hiddenTributeType = 'mem'>
            </cfif>
            
            <cfif IsDefined('JS_BCCHF_SEND_EMAIL')>
            
				<cfif JS_BCCHF_SEND_EMAIL EQ 'no'>
                    <cfset hiddenAWKtype ='No'>
                <cfelse>
                    <cfset hiddenAWKtype ='email'>       
                </cfif>
            
            <cfelse>
            
            	<cfset hiddenAWKtype ='No'>
            
            </cfif>
            
            <cfset trb_fname = ''>
            <cfset trb_lname = '#JS_BCCHF_HONOUR#'>
            <cfset trb_email = '#js_bcchf_recepient_email#'>
            <cfset trb_cardfrom = '#pty_fname# #pty_lname#'>
           
            
        <cfelse>
        	
            <cfset hiddenAWKtype ='No'>
            <cfset hiddenTributeType = JS_BCCHF_GIFT_TYPE>
            <cfset trb_fname = ''>
            <cfset trb_lname = ''>
            <cfset trb_email = ''>
            <cfset trb_cardfrom = ''>
        	<cfset gTribute = 'no'>
                
		</cfif>

	<cfcatch type="any">
    
    <cfmail to="csweeting@bcchf.ca" from="error@bcchf.ca" subject="error scrubbing donation form data" type="html">
    Error scrubbing donation form data
    Message: #cfcatch.Message#
    Detail: #cfcatch.Detail#
    <cfdump var="#cfcatch#" label="catch">
    <cfdump var="#form#" hide="POST_CARD_NUMBER,POST_CVV,FIELDNAMES,js_bcchf_cardnumber,js_bcchf_cvv" label="transaction">
    </cfmail>
    
    </cfcatch>
    </cftry>
    
    
    <!--- begin processing transaction --->
    
    <!--- attempt charge --->
	<cfset chargeAttempt = 1>
    <cfset attemptCharge = 1>
    <cfset returnMSG = 'beginAttempt-charging'>
    
    
    <!--- Trying to record - Attempt Record --->
    <cftry>
    
    	<cfset tAttemptRecord = {tDate = pty_date, 
								tUUID = variables.newUUID,
								tDonor = {
									dTitle = pty_title,
									dFname = pty_fname,
									dMname = pty_miname,
									dLname = pty_lname,
									dCname = pty_companyname,
									dTaxTitle = pty_tax_title,
									dTaxFname = pty_tax_fname,
									dTaxMname = pty_miname,
									dTaxLname = pty_tax_lname,
									dTaxCname = pty_tax_companyname,
									dAddress = {
										aOne = ptc_address,
										aTwo = ptc_addTwo,
										aCity = ptc_city,
										aProv = ptc_prov,
										aPost = ptc_post,
										aCountry = ptc_country
									},
									dEmail = ptc_email,
									dPhone = ptc_phone
								},
								tGift = post_dollaramount,
								tGiftAdv = giftAdvantage,
								tGiftTax = giftTaxable,
								tType = gift_type,
								tFreq = gift_frequency,
								tNotes = gift_notes,
								tSource = donation_source,
								eSource = ePhilSRC,
								tBrowser = {
									bUAgent = newBrowser,
									bName = uabrowsername,
									bMajor = uabrowsermajor,
									bVer = uabrowserversion,
									bOSname = uaosname,
									bOSver = uaosversion,
									dDevice = uadevicename,
									bDtype = uadevicetype,
									bDvend = uadevicevendor,
									bIP = newIP
								},
								tTType = pty_tax,
								tFreqDay = gift_day,
								tSHP = {
									tAdd = HeroDonateAdd,
									tToken = hiddenEventToken,
									tCampaign = hiddenEventCurrentYear,
									tTeamID = hiddenTeamID,
									tSupID = hiddenSupID,
									tDname = DName,
									tStype = hiddentype,
									tSmsg = Message,
									tSshow = Show,
									Hero_Donate_Amount = Hero_Donate_Amount
								},
								tJD = {
									Pins = RunnerPin,
									Buttons = RunnerButton,
									BBQ = RunnerBBQ,
									BBQl = '',
									cFriday = 0
								},
								tFORM = {
									hiddenDonationPCType = js_bcchf_donate_type,
									hiddenDonationType = gift_frequency,
									hiddenFreqDay = hiddenFreqDay,
									hiddenGiftAmount = hiddenGiftAmount,
									donation_type = js_bcchf_donate_type,
									gift_frequency = js_bcchf_donation_frequency,
									gift_day = js_bcchf_bill_cycle,
									hiddenTributeType = js_bcchf_gift_type,
									gift_tributeType = js_bcchf_gift_type
									
								},
								adInfo = {
									iSecurity = '',
									iWill = '',
									iLife = '',
									iTrust = '',
									iRRSP = '',
									iWillInclude = '',
									iLifeInclude = '',
									iRSPinclude = '',
									SOC_subscribe = SOC_subscribe,
									news_subscribe = news_subscribe,
									AR_subscribe = AR_subscribe,
									iWhere = '',
									iPastDonor = '',
									gPledgeDet = gPledgeDeatil,
									gPledgeDREID = gift_pledge_DonorID,
									gPledge = gPledge
								},
								tribInfo = {
									trbFname = trb_fname,
									trbLname = trb_lname,
									trbEmail = trb_email,
									trbAddress = '',
									trbCity = '',
									trbProv = '',
									trbPost = '',
									srpFname = '',
									srpLname = '',
									trbCardfrom = trb_cardfrom,
									trbMsg = '',
									tribNotes = hiddenTributeType,
									cardSend = hiddenAWKtype,
									gTribute = gTribute
								}
			} />
            
            <cfset tAttempt = SerializeJSON(tAttemptRecord)>
    	
    		<cfset tATPrec = recordTransAttempt(tAttempt)>
    
    
    
    	<cfinclude template="../includes/0log_donation.cfm">
    
    <cfcatch type="any">
    <cfmail to="csweeting@bcchf.ca" from="error@bcchf.ca" subject="error recording backup data" type="html">
    Error recording backup data - trying to record attempt record.
    Message: #cfcatch.Message#
    Detail: #cfcatch.Detail#
    <cfdump var="#cfcatch#" label="catch">
    <cfdump var="#form#" hide="POST_CARD_NUMBER,POST_CVV,FIELDNAMES,POST_DOLLARAMOUNT,js_bcchf_cardnumber,js_bcchf_cvv" label="transaction">
    </cfmail>
    </cfcatch>
    </cftry>
    
	
    <!--- check for XDS,IP, and Fraud MO --->
    <cftry>
    
    <!--- XDS --->
    <cfset goodXDS = checkXDS(APPLICATION.AppVerifyXDS, FORM.App_verifyToken, CGI.HTTP_REFERER)>
    
    <cfif goodXDS EQ 0>
    	<cfset attemptCharge = 0>
    </cfif>
    
    <!--- check IP method --->
    <cfset goodIP = checkIPaddress(newIP)>
    
    <cfif goodIP EQ 0>
    	<cfset attemptCharge = 0>
    </cfif>
    
    <!--- check Fraudster MO --->
    <cfset fradulent = checkFraudsterMO(pty_tax_fname, pty_tax_lname, pty_fname, pty_lname, ptc_email, ptc_country, gift_frequency, post_dollaramount)>
    
    <cfif fradulent EQ 1>
    	<cfset attemptCharge = 0>
    </cfif>
    
    
    <cfcatch type="any">
    <cfset attemptCharge = 0>
    <cfmail to="csweeting@bcchf.ca" from="error@bcchf.ca" subject="error checking for Fraud" type="html">
    Error checking for fraud
    Message: #cfcatch.Message#
    Detail: #cfcatch.Detail#
    <cfdump var="#cfcatch#" label="catch">
    <cfdump var="#form#" hide="POST_CARD_NUMBER,POST_CVV,FIELDNAMES,POST_DOLLARAMOUNT,js_bcchf_cardnumber,js_bcchf_cvv" label="transaction">
    </cfmail>
    </cfcatch>
    </cftry>
    
    
    <!--- if we can attempt to post to PayPal --->
    <cfif attemptCharge EQ 1>
    
		<!--- trying to post to PayPal--->
        <cftry>
        
        <!--- a monthly transaction requires a billing pland and subsequent approval of the billing agreement.
		one time gift requires a regular 'payment'
		--->
		
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
 
			<cfset SHPevent = DeserializeJSON(toString( result.fileContent ))>
        
            <!--- auth token --->
            <cfset requestToken='#SHPevent.token_type# #SHPevent.access_token#'>
            
            
            <cfset payDetail["intent"] = "sale">
			<cfset payDetail["payer"] = {}>
            <cfset payDetail.payer["payment_method"] = 'paypal' />
            <cfset payDetail["transactions"] = ArrayNew(1)>
            <cfset payDetail.transactions[1]["amount"] = {}>
            <cfset payDetail.transactions[1].amount["currency"] = 'CAD'>
            <cfset payDetail.transactions[1].amount["total"] = NumberFormat(post_dollaramount, 9.00)>
            <cfset payDetail.transactions[1]["description"] = '#DollarFormat(post_dollaramount)# #gift_type# Donation'>
            <cfset payDetail.transactions[1]["invoice_number"] = variables.newUUID>
            <cfset payDetail.transactions[1]["soft_descriptor"] = "BCCHF">
            <cfset payDetail["redirect_urls"] = {}>
            <cfset payDetail.redirect_urls["return_url"] = '#secureBCCHF#/donate/completeDonation-mobile-PayPal.cfm?Event=#gift_type#&UUID=#variables.newUUID#'>
            <cfset payDetail.redirect_urls["cancel_url"] = '#secureBCCHF#/donate/donation-mobile.cfm?DtnID=#variables.newUUID#&PayPalCancel=Yes&#CGI.QUERY_STRING#'>
            
            
            
            <cfhttp 
            result="result"
            method="post"
            url="#apiendPoint#v1/payments/payment" 
            >
                <cfhttpparam type="header" name="Content-Type" value="application/json" />
                <cfhttpparam type="header" name="Authorization" value="#requestToken#" />
                <cfhttpparam type="body" value="#serializeJSON(payDetail)#">
            </cfhttp>

 			<!--- check result header for 201 status code --->
			<cfif result.responseheader.status_code EQ 201>
 				
                <!--- payment has been 'created' on PayPal --->
                <!--- parse response --->
				<cfset SHPevent = DeserializeJSON(toString( result.fileContent ))>
    
				<cfset i = 0>
    			<cfset rdrLinkFnd = 0>
    			
    			
                <!--- check for execution link --->
    			<cfloop condition = "rdrLinkFnd EQUALS 0">
    				<cfset i = i + 1>
    
					<cfif StructKeyExists(SHPevent.links[i], 'method') 
                        AND SHPevent.links[i].method EQ 'REDIRECT'>
                        <cfset rdrLinkFnd = 1>
                        <cfset rdrLnk = SHPevent.links[i].href>
                    </cfif>
                    
				</cfloop>
                
                <!---- OK to proceed with PayPal Payment ID --->
				<cfset rqst_transaction_approved = 1>
				<cfset payPalPaymentID = SHPevent.id>

    
			<cfelse>
                
                <!--- non 201 code response - indicate error --->
                <cfset rqst_exact_respCode = '#result.responseheader.status_code# Error Connectiong to PayPal.'>
                <cfset rqst_transaction_approved = 0>
                
                <cfmail to="csweeting@bcchf.ca" from="error@bcchf.ca" subject="payPal Response error result" type="html">
                Response other than 201 when creating transaction
                <cfdump var="#result#" label="catch">
                <cfdump var="#form#" hide="POST_CARD_NUMBER,POST_CVV,FIELDNAMES,POST_DOLLARAMOUNT,js_bcchf_cardnumber,js_bcchf_cvv" label="transaction">
                </cfmail>

			</cfif>
            
            
            
    
    	<cfelse>
        
        	<!--- PayPal login failure --->
			<cfset rqst_transaction_approved = 0>
            <cfset rqst_exact_respCode = 'Error Connectiong to PayPal.'>
            
            <cfmail to="csweeting@bcchf.ca" from="error@bcchf.ca" subject="payPal Login error result" type="html">
            Login Failure
            <cfdump var="#result#" label="catch">
            <cfdump var="#form#" hide="POST_CARD_NUMBER,POST_CVV,FIELDNAMES,POST_DOLLARAMOUNT,js_bcchf_cardnumber,js_bcchf_cvv" label="transaction">
            </cfmail>
        
        </cfif>


        <cfcatch type="any">
        <cfmail to="csweeting@bcchf.ca" from="error@bcchf.ca" subject="error in paypal creation process" type="html">
        error in exact process
        Message: #cfcatch.Message#
        Detail: #cfcatch.Detail#
        <cfdump var="#cfcatch#" label="catch">
        <cfdump var="#form#" hide="POST_CARD_NUMBER,POST_CVV,FIELDNAMES,POST_DOLLARAMOUNT,js_bcchf_cardnumber,js_bcchf_cvv" label="transaction">
        </cfmail>
        </cfcatch>
        </cftry>
            

    <cfelse>
    	<!--- charge not attempted - IP blocked --->
    
    	<cfset rqst_transaction_approved = 0>
        <cfset rqst_exact_respCode = 0>
    	<cfset chargeAproved = 0>
        <cfset exact_respCode = 0>
        <cfset returnMSG = 'Charge Not Attempted'>
    
    </cfif>
    
    
    
    <!--- NOT approved --->
    <cfif rqst_transaction_approved NEQ 1>
    
    	<!--- abort and show messages --->
    	<cfset chargeAproved = 0>
        <cfset exact_respCode = rqst_exact_respCode>
        <cfset returnMSG = 'charging-notapproved'>
        
		
        <!--- will return exact message for display to the user ---->   
        
        
        
    <cfelse>
    <!--- charge approved --->
    
    	<cfset chargeAproved = 1>
        <cfset returnMSG = 'charging-approved'>
            
    	<!--- record transaction information 
			
			1. Dump content of form to txt file
			2. Insert core transaction information into db
				- Transaction Information
				- Donor Information
				- SHP tables if necessary
			3. Update additional information
			4. Update tribute information
			5. Add eCard Information
			6. 
		
		
		--->
        
        <!--- remove IP from blocker trace --->
        <cftry>
        
        <cfset removeIP = removeIPaddress(newIP)>
        
        <cfcatch type="any">
        
        <cfmail to="csweeting@bcchf.ca" from="error@bcchf.ca" subject="error removing IP from blocker trace" type="html">
        Error removing IP from blocker trace table
        Message: #cfcatch.Message#
        Detail: #cfcatch.Detail#
        <cfdump var="#cfcatch#" label="catch">
        <cfdump var="#form#" hide="POST_CARD_NUMBER,POST_CVV,FIELDNAMES,js_bcchf_cardnumber,js_bcchf_cvv" label="transaction">
        </cfmail>
        
        </cfcatch>
        </cftry>
        
        
        <!--- try and record the transaction details in a flat txt file --->
        <cftry>
        
			<!--- directories --->
            <cfset monthlyDumpDirectory = DateFormat(Now(), 'mm-yy')>
            <Cfset dailyDumpDirectory = DateFormat(Now(), 'DD')>
            
            <cfset dumpDirectory = "#APPLICATION.WEBLINKS.File.service#\transactions\#monthlyDumpDirectory#\#dailyDumpDirectory#\">
            
            <!--- check if directory exists --->
            <cfif DirectoryExists(dumpDirectory)>
                <!--- directory exists - we are all good --->
            <cfelse>
                <!--- need to create directory --->
                <cfdirectory directory="#dumpDirectory#" action="create">
                        
            </cfif>
            
            <!--- add timestamp to file --->
            <Cfset append = "#DateFormat(Now())#---#TimeFormat(Now(), 'HH-mm-ss.l')#">
            
            <!--- dump form to file --->
            <!--- hide PCI fields --->
            <cfdump var="#form#" output="#dumpDirectory#bcchildren_full_donation_dump_date-#append#.txt" hide="POST_CARD_NUMBER,POST_CVV,FIELDNAMES,POST_DOLLARAMOUNT,js_bcchf_cardnumber,js_bcchf_cvv" type="html">
        
    	<cfcatch type="any">
        
        <cfmail to="csweeting@bcchf.ca" from="error@bcchf.ca" subject="error recording backup data" type="html">
        Error recording backup data - trying to create txt file of transaction
        Message: #cfcatch.Message#
        Detail: #cfcatch.Detail#
        <cfdump var="#cfcatch#" label="catch">
        <cfdump var="#form#" hide="POST_CARD_NUMBER,POST_CVV,FIELDNAMES,js_bcchf_cardnumber,js_bcchf_cvv" label="transaction">
        </cfmail>
        
        </cfcatch>
        </cftry>
        
        
        <!--- exact date from server --->
		<cfset exact_odbcDT = pty_Date>
        
        
        <!--- Try to Insert PayPal Created Payment Record Into Database --->
        <cftry>
       
        
        
        <!--- transaction information--->
        <CFQUERY datasource="#APPLICATION.DSN.Superhero#" name="insert_record" dbtype="ODBC">
        INSERT INTO tblPayPal (dtnDate, exact_date, dtnAmt, dtnBenefit, dtnReceiptAmt, dtnReceiptType, dtnBatch, dtnSource, rqst_dollaramount, pge_UUID, dtnIP, dtnBrowser, payPalPaymentID, payPalEXE) 
        VALUES (#pty_Date#, #exact_odbcDT#, '#post_dollaramount#', '#giftAdvantage#', '#giftTaxable#', '#receipt_type#', 'Online', '#donation_source#', '#post_dollaramount#', '#variables.newUUID#', '#newIP#', '#bDetail#', '#payPalPaymentID#', '#rdrLnk#') 
        </CFQUERY>
                
        
        <!--- if the try block fails --->
        <!--- send email with details to isbcchf --- log transaction --->
        <cfcatch type="any">
			<cfmail to="csweeting@bcchf.ca" from="error@bcchf.ca" subject="error recording transaction data" type="html">
            Error recording database data into tblTransaction
            Message: #cfcatch.Message#
            Detail: #cfcatch.Detail#
            <cfdump var="#cfcatch#" label="catch">
            <cfdump var="#form#" hide="POST_CARD_NUMBER,POST_CVV,FIELDNAMES,POST_DOLLARAMOUNT,js_bcchf_cardnumber,js_bcchf_cvv">
            </cfmail>
        </cfcatch>
        </cftry>
        
        
        <!--- check URL for email referal --->
        <cftry>
        
        <!--- lookup email and add note that donation has been made --->
        <cfif IsDefined('emailReferal') AND emailReferal NEQ ''>
        
            <cfset eRefUpdate = checkEmailReff(emailReferal, variables.newUUID)>
        
        </cfif>
        
        
        <cfcatch type="any">
        	<!--- do nothing --->
        </cfcatch>
        </cftry>
        
        
        
                
        
        
        <!--- end of database processing --->
        


        
        <!--- message about frequency  --->
        <cfset chargeMSG = gift_frequency>
        <!--- after inserting in DB and sending emails --->
        <cfset returnSuccess = 1>
        
    	</cfif><!--- end of if charging approved --->


    
    <cfset ChargeAttmpt = {
		cAttempted = chargeAttempt,
		cApproved = chargeAproved,
		cMSG = chargeMSG,
		exact_respCode = exact_respCode,
		ipBlocker = ipBlocker,
		goodXDS = goodXDS,
		ppEXURL = rdrLnk,
		ppID = payPalPaymentID 
		} />

	<!--- this is the structure of the return message --->
    <cfset SHPdonationReturnMSG = {
	Success = returnSuccess,
	ChargeAttmpt = ChargeAttmpt,
	Message = returnMSG,
	EventToken = hiddenEventToken,
	UUID = variables.newUUID,
	tGenTwoID = tGenTwoID
	} />
    
    
    <cfreturn SHPdonationReturnMSG>



</cffunction>






<!--- Send notification to Supporter --->
<cffunction name="sendNotifyEm" access="private" returntype="boolean">
	
    <cfargument name="toSupID" type="string" required="yes">
    <cfargument name="fromAdd" type="string" required="yes">
    <cfargument name="emSubject" type="string" required="yes">
    <cfargument name="emTemplate" type="string" required="yes">
    <cfargument name="emEvent" type="string" required="yes">
    <cfargument name="emDonID" type="string" required="yes">
    
    <cfif NOT IsDefined("pty_date")><cfset pty_date= "#Now()#"></cfif>
    
    <cftry>
    
    
    <!--- get the supporter name and email --->
    <cfquery name="selectMember" datasource="#APPLICATION.DSN.Superhero#">
    SELECT SupFName, SupLName, SupEmail, Don_Notify 
    FROM Hero_Members WHERE SuppID = #toSupID#
    </cfquery>
    
    <!--- get the donor name --->
    <cfquery name="selectDonor" datasource="#APPLICATION.DSN.general#">
	SELECT pty_fname, pty_lname, SupID FROM tblGeneral WHERE pge_UUID = '#emDonID#'
	</cfquery>
    
    <!--- get the event name and year --->
    <cfquery name="selectEventName" datasource="#APPLICATION.DSN.Superhero#">
    SELECT Event_Name, Staff_email, Event_Email, Don_Notify, 
    Don_cc, EventCurrentYear
    FROM Hero_Event WHERE Event = '#emEvent#'
    </cfquery>
    
    <!--- event notificatin template--->
    <cfquery name="ConstructEventDonNotificationTemplate" datasource="#APPLICATION.DSN.Superhero#">
	SELECT TextApprovedBody FROM Hero_EventText 
	WHERE Event = '#emEvent#' AND TextName = '#emTemplate#'
	</cfquery>
    
    <!--- registration details --->
    <cfquery name="selectReg" datasource="#APPLICATION.DSN.Superhero#">
    SELECT EventFundGoal, EventTeamID 
    FROM Hero_Registration WHERE SupID = #toSupID#
    AND RegEvent = '#emEvent#'
    AND RegYear = #selectEventName.EventCurrentYear#
    </cfquery>
    
    <cfset FundGoal = selectReg.EventFundGoal>
    <cfset NotType = 'Personal'>
    
    <cfif selectReg.EventTeamID NEQ 0>
    	<cfif emTemplate EQ 'DonTNotify'
			OR emTemplate EQ 'TGoal25Not'
			OR emTemplate EQ 'TGoal50Not'
			OR emTemplate EQ 'TGoal75Not'
			OR emTemplate EQ 'TGoal100Not'>
            <!--- lookup team info --->
            
            <cfquery name="selectTeam" datasource="#APPLICATION.DSN.Superhero#">
            SELECT TeamName, TeamGoal
            FROM Hero_Team WHERE TeamID = #selectReg.EventTeamID#
            AND TeamEvent = '#emEvent#'
            AND TeamCampID = #selectEventName.EventCurrentYear#
            </cfquery>
            
            <cfset FundGoal = selectTeam.TeamGoal>
            <cfset NotType = 'Team'>
            
            <!--- get the supporter name and email --->
            <cfquery name="supportMember" datasource="#APPLICATION.DSN.Superhero#">
            SELECT SupFName, SupLName, SupEmail, Don_Notify 
            FROM Hero_Members WHERE SuppID = #selectDonor.SupID#
            </cfquery>
                        
            
            
        </cfif>
    
    </cfif>
	
    <!--- email UUID --->
	<cfset emailUUID=createUUID()>
    
    <!--- hard coded links --->
    <cfset emailLoginLink = URLencodedformat('https://secure.bcchf.ca/SuperHeroPages/login.cfm?Event=#emEvent#')>
    <cfset emailtTrackLogin = "https://secure.bcchf.ca/SuperheroPages/ridr.cfm?emID=#emailUUID#&reirURL=#URLencodedformat(emailLoginLink)#">
    
    <cfset eventHomeLink = URLencodedformat('https://secure.bcchf.ca/#emEvent#')>
    <cfset eventHomeTrack = "https://secure.bcchf.ca/SuperheroPages/ridr.cfm?emID=#emailUUID#&reirURL=#URLencodedformat(eventHomeLink)#">
    
    <cfset eventDonateLink = URLencodedformat('https://secure.bcchf.ca/SuperheroPages/search.cfm?Event=#emEvent#')>
    <cfset eventDonateTrack = "https://secure.bcchf.ca/SuperheroPages/ridr.cfm?emID=#emailUUID#&reirURL=#URLencodedformat(eventDonateLink)#">
    
    <cfset eventFBLink = URLencodedformat('https://www.facebook.com/ChildRun')>
    <cfset eventFBTrack = "https://secure.bcchf.ca/SuperheroPages/ridr.cfm?emID=#emailUUID#&reirURL=#URLencodedformat(eventFBLink)#">
    
    <cfset ChildRunTwitterLink = URLencodedformat('https://twitter.com/bcchildrun')>
    <cfset ChildRunTwitterTrack = "https://secure.bcchf.ca/SuperheroPages/ridr.cfm?emID=#emailUUID#&reirURL=#URLencodedformat(ChildRunTwitterLink)#">
    
    <cfset eventTwitterLink = URLencodedformat('https://twitter.com/BCCHF')>
    <cfset eventTwitterTrack = "https://secure.bcchf.ca/SuperheroPages/ridr.cfm?emID=#emailUUID#&reirURL=#URLencodedformat(eventTwitterLink)#">
    
    
    
    <cfset bcchfHome = URLencodedformat('https://www.bcchf.ca/')>
    <cfset bcchfHomeTrack = "https://secure.bcchf.ca/SuperheroPages/ridr.cfm?emID=#emailUUID#&reirURL=#URLencodedformat(bcchfHome)#">
    
    <!--- default text if not setup for this event  --->
	<cfif ConstructEventDonNotificationTemplate.recordCount EQ 0
		OR ConstructEventDonNotificationTemplate.TextApprovedBody EQ ''
		OR ConstructEventDonNotificationTemplate.TextApprovedBody EQ 'DonNotify'>
            
            
		<cfset DonationNotification = '<div style="font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 12px; text-align: left; line-height: 20px; padding-right: 30px; color: ##000000;"><a href="#emailLoginLink#">Login here</a> to check your fundraising progress and to thank your supporters. Thank you for your continued support!</div>'>
            
	<cfelse>
        
		<cfset DonationNotification = ConstructEventDonNotificationTemplate.TextApprovedBody>
            
	</cfif>
    
    <!--- collect all links in text --->
	<cfset DonationNotificationHref = REMatch('(?s)<a href=".*?"', DonationNotification)>
    <cfset DonationNotificationAttributes = REMatch("(?s)<a .*?</a>", DonationNotification)>
    
    <cfif ArrayLen(DonationNotificationAttributes) GT 0>
    
    <cfloop from="1" to="#ArrayLen(DonationNotificationAttributes)#" index="i">
    
    <cfset LinkTitle = REMatch('(?s)>.*?<', DonationNotificationAttributes[i])>
    <cfset LinkTitle[1] = Replace(LinkTitle[1], '>', '')>
    <cfset LinkTitle[1] = Replace(LinkTitle[1], '<', '')>
    <!------>
    <cfset LinkAttrib = ParseHTMLTag( Trim( DonationNotificationAttributes[i] ) )>
    
    <cfset LinkHREF[i] = {href = LinkAttrib.ATTRIBUTES.href,
            Title = LinkTitle[1],
            Clicks = 0,
            Unique = 0} />
    <cfset Links[i] = REMatch('(?s)>.*?<', DonationNotificationAttributes[i])>
    </cfloop>
    
    
    
    <!--- replace all links in text with tracking codes--->
    <cftry>
    <!--- if we fail here its OK, allow to proceed with no tracking . --->
    
    <cfloop from="1" to="#ArrayLen(LinkHREF)#" index="i">
    
    <cfset emailLink = URLencodedformat(LinkHREF[i].href)>
    <cfset emailTrackLink = "https://secure.bcchf.ca/SuperheroPages/ridr.cfm?emID=#emailUUID#&reirURL=#URLencodedformat(emailLink)#">
    <cfset emailTrackHTML = '<a href="#emailTrackLink#">#LinkHREF[i].title#</a>'>
    
    <cfset DonationNotification = Replace(DonationNotification, DonationNotificationAttributes[i], emailTrackHTML)>
    
    </cfloop> 
    
    <cfcatch type="any">
    </cfcatch>
    </cftry>
    
    
    <!--- store email details in structure 
    <cfset LinkHREFJSON = SerializeJSON(LinkHREF)>
    	<cfset LinkHREF = ''>--->
    <cfelse>
    	<cfset LinkHREF = ''>
    </cfif>
     
	<cfset emailMeta= {ToAdd = SelectMember.SupEmail,
        ToName = '#SelectMember.SupFName# #SelectMember.SupLName#',
        FromAdd = 'bcchfds@bcchf.ca',
        FromName = 'BCCHF Superhero Pages',
        Subject = emSubject,
        Body = '',
		Links = LinkHREF,
        EmailType = emTemplate,
		SupGoal = FundGoal
        }
        />
    
    <cfset emailMetaJSON = SerializeJSON(emailMeta)>
    
    <!--- send email --->
    <cfmail to="#SelectMember.SupFName# #SelectMember.SupLName# <#SelectMember.SupEmail#>" 
    	from="BCCHF Superhero Pages <bcchfds@bcchf.ca>" 
        subject="#emSubject#" 
        type="html" 
        failto="csweeting@bcchf.ca">
        
        
        <cfif emEvent EQ 'ChildRun'
			OR emEvent EQ 'RFTK'
			OR emEvent EQ 'SloPitch'>
        <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
		<html xmlns="http://www.w3.org/1999/xhtml">
		<head>
		<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
		<title>BC Children's Hospital Foundation</title>
		<link href="../css/styles-superhero.css" rel="stylesheet" type="text/css" />
		<link href="../css/ANOM-emailStyles.css" rel="stylesheet" type="text/css" />
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
            <cfif emEvent EQ 'ChildRun'>
            <img src="http://newsletter.bcchf.ca/images/2015/header-ChildRun.png" width="720" alt="ChildRun" border="0">
            
        	<cfelseif emEvent EQ 'RFTK'>
            <img src="http://newsletter.bcchf.ca/images/2017/header-RFTK.png" width="720" alt="2017 RBC Race for the Kids" border="0">
			
			
			<cfelseif emEvent EQ 'SloPitch'>
            <div><img src="http://newsletter.bcchf.ca/images/2015/header-SloPitch.png" width="720" height="347" border="0" usemap="##SloPitchHeaderMap">
    <map name="SloPitchHeaderMap">
    <area shape="rect" coords="61,190,246,332" href="#eventHomeTrack#" target="_blank">
    <area shape="rect" coords="87,44,239,165" href="#bcchfHomeTrack#" target="_blank">
    <area shape="rect" coords="499,21,652,88" href="#eventDonateTrack#" target="_blank">
    </map>
    </div>

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
        <td align="left" width="610">&nbsp;</td>
        <td width="50"><img alt="." height="1" src="https://my.bcchf.ca/view.image?Id=612" width="50" /></td>
        </tr>
        <tr>
        <td>&nbsp;</td>
        <td>
        <div style="font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 12px; text-align: left; line-height: 20px; padding-right: 30px; color: ##000000;">
        <cfif emEvent EQ 'ChildRun'
			OR emEvent EQ 'RFTK'>
        <p>#SelectMember.SupFName# #SelectMember.SupLName#,</p>
        <cfelseif emEvent EQ 'SloPitch'>
        <p>Dear #SelectMember.SupFName#,</p>
        </cfif>
        </div>
        <div style="font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 12px; text-align: left; line-height: 20px; padding-right: 30px; color: ##000000;">
        <cfif NotType EQ 'Personal'>
        <p>Congratulations, a donation has been made from #selectDonor.pty_fname# #selectDonor.pty_lname# to your #selectEventName.Event_Name# Page. 
        </p>
        <cfelse>
        <p>Congratulations, a donation has been made from #selectDonor.pty_fname# #selectDonor.pty_lname# to your #selectEventName.Event_Name# #selectTeam.TeamName# Team Page,  in support of #supportMember.SupFName# #supportMember.SupLName#. 
        </p>
        </cfif>
        </div>
        <div>
        #DonationNotification#
        <!---
        <cfif toSupID EQ '17454'>
        <cfdump var="#LinkHREF#">
        <cfdump var="#DonationNotificationAttributes#">
        <a href="#emailtTrackLogin#">Login</a>
        </cfif>--->
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
        	<!--- footer --->
            <cfif emEvent EQ 'ChildRun'>
            <div>
            <img src="http://newsletter.bcchf.ca/images/2013/footer-ChildRun.png" width="720" border="0" usemap="##Map"><br>
            <img src="http://newsletter.bcchf.ca/images/2015/footer-ChildRun-sponsorOnly.png" width="720" height="70" alt="ChildRun Sponsors"> 
            
            <map name="Map">
            <area shape="rect" coords="495,31,533,68" href="#eventFBTrack#" target="_blank" alt="Facebook">
            <area shape="rect" coords="538,31,573,68" href="#ChildRunTwitterTrack#" target="_blank" alt="Twitter">
            <area shape="rect" coords="498,81,684,133" href="#eventDonateTrack#" target="_blank" alt="Donate">
            </map>
            </div>
            <cfelseif emEvent EQ 'RFTK'>
            
            <div><img src="http://newsletter.bcchf.ca/images/2016/footer-new.png" width="720" border="0" height="168" usemap="##Map"></div>

 
  
  <map name="Map"> 
	<area shape="rect" coords="644,84,687,128" href="https://youtube.com/bcchf" target="_blank" alt="YouTube" /> 
	<area shape="rect" coords="598,84,641,128" href="https://instagram.com/bcchf" target="_blank" alt="Instagram" /> 
	<area shape="rect" coords="507,84,550,128" href="https://www.facebook.com/BCCHF" target="_blank" alt="Facebook"> 
	<area shape="rect" coords="553,84,596,128" href="http://twitter.com/bcchf" target="_blank" alt="Twitter"> 
	<area shape="rect" coords="507,10,687,81" href="https://secure.bcchf.ca/SuperheroPages/search.cfm?Event=RFTK&utm_source=dNotification&utm_medium=email&utm_campaign=RFTK&utm_content=BottomGraphic" target="_blank" alt="Donate"> 
	</map> 

            
			<cfelseif emEvent EQ 'SloPitch'>
            
            <div><img src="http://newsletter.bcchf.ca/images/2013/footer-SloPitch.png" width="720" border="0" usemap="##SloPitchMap"></div>

<map name="SloPitchMap"><area shape="rect" coords="60,95,319,139" href="#eventHomeTrack#" target="_blank" alt="Donate">
      <area shape="rect" coords="498,31,536,68" href="#eventFBTrack#" target="_blank" alt="Facebook">
    <area shape="rect" coords="539,31,574,68" href="#eventTwitterTrack#" target="_blank" alt="Twitter">
    <area shape="rect" coords="496,80,682,132" href="#eventDonateTrack#" target="_blank" alt="Donate">
</map>



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
        
        <img src="https://secure.bcchf.ca/SuperheroPages/rimg.cfm?emID=#emailUUID#" />
        
        </body>
        </html>

        
        <cfelse>
                
        <p>#SelectMember.SupFName# #SelectMember.SupLName#</p>
		<p>Congratulations, a donation has been made from #selectDonor.pty_fname# #selectDonor.pty_lname# to your <cfif emEvent EQ 'WigsForKids'><cfelse>#selectEventName.EventCurrentYear# </cfif>#selectEventName.Event_Name# Page. </p>
        
		#DonationNotification#
        
        </cfif>
        

    </cfmail>
    
    <!--- record email has been sent successfully --->
	<cfquery name="recordEmail" datasource="bcchf_SuperHero">
	INSERT INTO Hero_Email_SupRecieved (EmSendDate, HeroEventCampaign, HeroEventToken, SupID, EmType, EmSHPName, EmID, EmMetaData, EmUUID)
	VALUES (#pty_date#, #selectEventName.EventCurrentYear#, '#emEvent#', #toSupID#, 'SHP', '#emTemplate#', 0, '#emailMetaJSON#', '#emailUUID#')
	</cfquery>
    
    
    <cfcatch type="any">
    
    <cfmail to="csweeting@bcchf.ca" from="error@bcchf.ca" subject="SupNotification Email Error" type="html">
    <cfdump var="#cfcatch#">
    <cfdump var="#CGI#">
    </cfmail>
        
	</cfcatch>
	</cftry>
	
    <cfset goodEmail = 1>

	<cfreturn goodEmail>

</cffunction>

<!--- 2014-02-14 XDS (Cross Domain Scripting) Prevention Check --->
<cffunction name="checkXDS" access="private" returntype="boolean">

	<cfargument name="AppXDS" type="string" required="yes">
    <cfargument name="FormXDS" type="string" required="yes">
    <cfargument name="refferalInfo" type="string" required="yes">
    
   
    
    <cfif AppXDS EQ FormXDS>
    	
		
    	<!--- All good - allow charge --->
        <cfset goodXDS = 1>

    <cfelse>
    
		<!--- AppXDS does not match FormXDS -- ABORT --->
        <cfset goodXDS = 0>
        
        <cfmail to="csweeting@bcchf.ca" from="error@bcchf.ca" subject="XDS non Match Error" type="html">
    
        APPLICATION.AppVerifyXDS: #AppXDS#<br>
        FORM.App_verifyToken: #FormXDS#<br>
        <cfdump var="#CGI#">
        </cfmail>
    
    </cfif>
    <!--- 
    <cfif Left(refferalInfo, 30) NEQ 'https://secure.bcchf.ca/donate'
		AND Left(refferalInfo, 31) NEQ 'http://bcchf-ws02/secureBCCHFca'
		AND Left(refferalInfo, 31) NEQ 'http://cf10test.bcchf.ca/donate'>
    <cfset goodXDS = 1>
    
    <cfmail to="csweeting@bcchf.ca" from="error@bcchf.ca" subject="HTTP REFERER is not secure.bcchf.ca" type="html">
    Ref: #refferalInfo#<br />
    APPLICATION.AppVerifyXDS: #AppXDS#<br>
	FORM.App_verifyToken: #FormXDS#<br>
	<cfdump var="#CGI#">
    </cfmail>
    
    </cfif> --->

	<cfreturn goodXDS>

</cffunction>


<!--- 2012-09-10 Checking the IP of client making processing request
	IP is checked against our blocked IP listing --->
<cffunction name="checkIPaddress" access="private" returntype="boolean">

	<cfargument name="newIP" type="string" required="yes">
    
    <!--- check for blocked IPs --->
    <cfquery name="CheckIP" datasource="bcchf_SHPadmin">
    SELECT Source FROM BlockedIp WHERE BlockedIP = '#newIP#'
    </cfquery>
    
    <cfif CheckIP.recordcount EQ 0>
    	
		
    	<!--- All good - allow charge --->
        <cfset goodIP = 1>
        <!--- Set a marker ---
		<cfset frapi.trace( "IP OK; Charging" )>--->

    <cfelse>
    
		<!--- IP Found on blocked listing - ABORT --->
        <cfset goodIP = 0>
        <!--- Set a marker ---
		<cfset frapi.trace( "IP NO GOOD; ABORTING" )>--->
    
    </cfif>

	<cfreturn goodIP>

</cffunction>

<!--- removing the IP of client making an approved request --->
<cffunction name="removeIPaddress" access="private" returntype="boolean">

	<cfargument name="newIP" type="string" required="yes">

	<cfquery name="checkIP" datasource="bcchf_SHPadmin">
    SELECT Attempts FROM BlockedIP_trace 
    WHERE AttemptIP = '#newIP#'
    </cfquery>
        
        <cfif checkIP.recordcount EQ 0>
        <!--- good --->
        <cfelse>
        <!--- remove --->
        	<cfquery name="recordIP" datasource="bcchf_SHPadmin">
            UPDATE BlockedIP_trace SET 
            Attempts = 0, 
            LastAttempt = #pty_Date#
            WHERE AttemptIP = '#newIP#'
            </cfquery>
        
        
        </cfif>
        
    <cfset goodIP = 1>
        
	<cfreturn goodIP>

</cffunction>       

<!--- 2012-09-10 Recording the IP of client making a failed request --->
<cffunction name="recordIPaddress" access="private" returntype="boolean">

	<cfargument name="newIP" type="string" required="yes">
	<cfset ipBlocker = 0>
    <!--- checking --->
        <cfquery name="checkIP" datasource="bcchf_SHPadmin">
        SELECT Attempts FROM BlockedIP_trace 
        WHERE AttemptIP = '#newIP#'
        </cfquery>
        
        <cfif checkIP.recordcount EQ 0>
        
			<!--- no attempts from this IP--->
            <cfquery name="recordIP" datasource="bcchf_SHPadmin">
            INSERT INTO BlockedIP_trace (AttemptIP, Attempts, LastAttempt)
            VALUES ('#newIP#', 1, #pty_Date#)
            </cfquery> 
        
        <cfelse><!--- previous attempts found --->
        
			<!--- there have been previous attempts --->
            <cfset Attempts = checkIP.Attempts + 1>
            <!--- record this attempts --->
            <cfquery name="recordIP" datasource="bcchf_SHPadmin">
            UPDATE BlockedIP_trace SET 
            Attempts = #Attempts#, 
            LastAttempt = #pty_Date#
            WHERE AttemptIP = '#newIP#'
            </cfquery>
            
            
            <cfif Attempts GT 4><!--- Block IP on 5th failed request --->
            
                
                <cfif newIP NEQ '142.103.232.17'><!--- hospital IP exception --->
                
                <cfquery name="recordIP" datasource="bcchf_SHPadmin">
                INSERT INTO BlockedIP (BlockedIP, Source, BlockDT)
                VALUES ('#newIP#', 'Online Script', #pty_Date#)
                </cfquery>
                
                </cfif>
                
                <!--- abort --->
                <cfset ipBlocker = 1>
                
            </cfif>
        </cfif>

	<cfreturn ipBlocker>

</cffunction>

<!--- 2012-09-10 Recording the IP of client making a failed request --->
<cffunction name="blockIP" access="private" returntype="boolean">

	<cfargument name="newIP" type="string" required="yes">
	<cfset ipBlocker = 0>
    <!--- checking --->
        <cfquery name="checkIP" datasource="bcchf_SHPadmin">
        SELECT Attempts FROM BlockedIP_trace 
        WHERE AttemptIP = '#newIP#'
        </cfquery>
        
        <cfif newIP NEQ '142.103.232.17'><!--- hospital IP exception --->
        
        <cfif checkIP.recordcount EQ 0>
        
			<!--- no attempts from this IP--->
            <cfquery name="recordIP" datasource="bcchf_SHPadmin">
            INSERT INTO BlockedIP (BlockedIP, Source, BlockDT)
            VALUES ('#newIP#', 'Online Script', #pty_Date#)
            </cfquery>
        
        <cfelse><!--- previous attempts found --->
        
			<cfquery name="recordIP" datasource="bcchf_SHPadmin">
            INSERT INTO BlockedIP (BlockedIP, Source, BlockDT)
            VALUES ('#newIP#', 'Online Script', #pty_Date#)
            </cfquery>
                
        </cfif>
        </cfif>

	<!--- abort --->
	<cfset ipBlocker = 1>

	<cfreturn ipBlocker>

</cffunction>

<!--- 2015-02-08 Recording Attempted Transactions --->
<cffunction name="recordTransAttempt" access="private" returntype="boolean">

	<cfargument name="tAttempt" type="string" required="yes">
    
    <cftry>
                
    <cfset tAttemptSuc = 1>
    
    <cfset taRec = DeserializeJSON(tAttempt)>
    
    <cfset bDetail = SerializeJSON(taRec.tBrowser)>
    <cfset fDetail = SerializeJSON(taRec.tFORM)>
    
    <cfset HDAddText = SerializeJSON(taRec.tSHP)>
    
    <cfif IsDefined('taRec.tJD.Pins')>
		<cfset jdPins = taRec.tJD.Pins>
    <cfelse>
        <cfset jdPins = 0>
    </cfif>
    
    <cfif IsDefined('taRec.tJD.Buttons')>
        <cfset jdButtons = taRec.tJD.Buttons>
    <cfelse>
        <cfset jdButtons = 0>
    </cfif>
    
    
        
                
    
    <CFQUERY datasource="#APPLICATION.DSN.Superhero#" name="insert_record">
    INSERT INTO tblAttempt (pty_date, 
    		exact_date,
    		pty_title, 
            pty_fname, 
            pty_miname, 
            pty_lname, 
            pty_companyname, 
            ptc_address, 
            ptc_add_two, 
            ptc_city, 
            ptc_prov, 
            ptc_post, 
            ptc_country, 
            ptc_email, 
            ptc_phone, 
            pty_tax_title, 
            pty_tax_fname, 
            pty_tax_lname, 
            pty_tax_companyname, 
            gift, 
            gift_Advantage,
            gift_Eligible,
            gift_type, 
            gift_frequency, 
            gift_notes,
            SupID,
            TeamID,
            JD_Pin,
            JD_Button,
            dnrBrowser,
            dnrPageSource,
            post_FORMdata,
            pge_UUID) 
    VALUES (#CreateODBCDateTime(taRec.tDate)#, 
    		#CreateODBCDateTime(taRec.tDate)#,
            '#taRec.tDonor.dTitle#', 
            '#taRec.tDonor.dFname#', 
            '#taRec.tDonor.dMname#', 
            '#taRec.tDonor.dLname#',  
            '#taRec.tDonor.dCname#', 
            '#taRec.tDonor.dAddress.aOne#', 
            '#taRec.tDonor.dAddress.aTwo#', 
            '#taRec.tDonor.dAddress.aCity#', 
            '#taRec.tDonor.dAddress.aProv#', 
            '#taRec.tDonor.dAddress.aPost#', 
            '#taRec.tDonor.dAddress.aCountry#', 
            '#taRec.tDonor.dEmail#', 
            '#taRec.tDonor.dPhone#', 
            '#taRec.tDonor.dTaxTitle#', 
            '#taRec.tDonor.dTaxFname#',
            '#taRec.tDonor.dTaxLname#', 
            '#taRec.tDonor.dTaxCname#',
            '#taRec.tGift#', 
            '#taRec.tGiftAdv#', 
            '#taRec.tGiftTax#', 
            '#taRec.tType#', 
            '#taRec.tFreq#', 
            '#taRec.tNotes#',
            '#taRec.tSHP.tSupID#',
            '#taRec.tSHP.tTeamID#',
            '#jdPins#',
            '#jdButtons#',
            '#bDetail#',
            '#HDAddText#',
            '#fDetail#', 
            '#taRec.tUUID#')
    </CFQUERY>
    
    
    
    <!--- if the try block fails --->
	<!--- send email with details to isbcchf --- log transaction --->
    <cfcatch type="any">
    
    	<cfset tAttemptSuc = 1>
    
        <cfmail to="csweeting@bcchf.ca" from="error@bcchf.ca" subject="error recording transaction data attempt" type="html">
        Error recording database data into tblAttempt
        Message: #cfcatch.Message#
        Detail: #cfcatch.Detail#
        <cfdump var="#cfcatch#" label="catch">
        <cfdump var="#form#" hide="POST_CARD_NUMBER,POST_CVV,FIELDNAMES,POST_DOLLARAMOUNT,js_bcchf_cardnumber,js_bcchf_cvv">
        </cfmail>
    </cfcatch>
    </cftry>
    
    <cftry>
    
    <cfset AddInfo = taRec.adInfo>
    
    <cfif IsDefined('AddInfo.iWhere')>
		<cfset iWhere = AddInfo.iWhere>
    <cfelse>
        <cfset iWhere = ''>
    </cfif>
    
    <cfif IsDefined('AddInfo.iPastDonor')>
		<cfset iPastDonor = AddInfo.iPastDonor>
    <cfelse>
        <cfset iPastDonor = ''>
    </cfif>
    
    <cfif IsDefined('AddInfo.iSecurity')>
		<cfset iSecurity = AddInfo.iSecurity>
    <cfelse>
        <cfset iSecurity = ''>
    </cfif>
    
    <cfif IsDefined('AddInfo.iWill')>
		<cfset iWill = AddInfo.iWill>
    <cfelse>
        <cfset iWill = ''>
    </cfif>
    
    <cfif IsDefined('AddInfo.iLife')>
		<cfset iLife = AddInfo.iLife>
    <cfelse>
        <cfset iLife = ''>
    </cfif>
    
    <cfif IsDefined('AddInfo.iRRSP')>
		<cfset iRRSP = AddInfo.iRRSP>
    <cfelse>
        <cfset iRRSP = ''>
    </cfif>
    
    <cfif IsDefined('AddInfo.iTrust')>
		<cfset iTrust = AddInfo.iTrust>
    <cfelse>
        <cfset iTrust = ''>
    </cfif>
    
    <cfif IsDefined('AddInfo.iWillInclude')>
		<cfset iWillInclude = AddInfo.iWillInclude>
    <cfelse>
        <cfset iWillInclude = ''>
    </cfif>
    
    <cfif IsDefined('AddInfo.iLifeInclude')>
		<cfset iLifeInclude = AddInfo.iLifeInclude>
    <cfelse>
        <cfset iLifeInclude = ''>
    </cfif>
    
    <cfif IsDefined('AddInfo.iRSPInclude')>
		<cfset iRRSPInclude = AddInfo.iRSPInclude>
    <cfelse>
        <cfset iRRSPInclude = ''>
    </cfif>
        
    
    <CFQUERY datasource="#APPLICATION.DSN.Superhero#" name="insert_record">
    UPDATE tblAttempt SET
    	info_where = '#iWhere#', 
        donated_before = '#iPastDonor#',
        info_securities = '#iSecurity#',
        info_will = '#iWill#', 
        info_life = '#iLife#', 
        info_RRSP = '#iRRSP#', 
        info_trusts = '#iTrust#', 
        info_willinclude = '#iWillInclude#', 
        info_lifeinclude = '#iLifeInclude#', 
        info_RSPinclude = '#iRRSPinclude#',
        ptc_subscribe = '#AddInfo.news_subscribe#',
        SOC_subscribe = '#AddInfo.SOC_subscribe#', 
        AR_subscribe = '#AddInfo.AR_subscribe#', 
        gift_pledge_det = '#AddInfo.gPledgeDet#',
        gift_pledge = '#AddInfo.gPledge#', 
        ConstitID = '#AddInfo.gPledgeDREID#'  
    WHERE pge_UUID = '#taRec.tUUID#'
    </CFQUERY>
            
    <!--- if the try block fails --->
	<!--- send email with details to isbcchf --- log transaction --->
    <cfcatch type="any">
    
    	<cfset tAttemptSuc = 1>
    
        <cfmail to="csweeting@bcchf.ca" from="error@bcchf.ca" subject="error updating attempted transaction additional info" type="html">
        Error updating database data into tblAttempt
        Message: #cfcatch.Message#
        Detail: #cfcatch.Detail#
        <cfdump var="#cfcatch#" label="catch">
        <cfdump var="#form#" hide="POST_CARD_NUMBER,POST_CVV,FIELDNAMES,POST_DOLLARAMOUNT,js_bcchf_cardnumber,js_bcchf_cvv">
        </cfmail>
    </cfcatch>
    </cftry>
    
    <cftry>
                
    <cfset tribInfo = taRec.tribInfo>
    
    <cfif IsDefined('sucRec.tJD.Pins')>
		<cfset jdPins = sucRec.tJD.Pins>
    <cfelse>
        <cfset jdPins = 0>
    </cfif>
    
    <cfif IsDefined('sucRec.tJD.Pins')>
		<cfset jdPins = sucRec.tJD.Pins>
    <cfelse>
        <cfset jdPins = 0>
    </cfif>
    
    <cfif IsDefined('tribInfo.trbEmail')>
		<cfset trbEmail = tribInfo.trbEmail>
    <cfelse>
        <cfset trbEmail = ''>
    </cfif>
    
    <cfif IsDefined('tribInfo.trbAddress')>
		<cfset trbAddress = tribInfo.trbAddress>
    <cfelse>
        <cfset trbAddress = ''>
    </cfif>
    
    <cfif IsDefined('tribInfo.trbCity')>
		<cfset trbCity = tribInfo.trbCity>
    <cfelse>
        <cfset trbCity = ''>
    </cfif>
    
    <cfif IsDefined('tribInfo.trbProv')>
		<cfset trbProv = tribInfo.trbProv>
    <cfelse>
        <cfset trbProv = ''>
    </cfif>
    
    <cfif IsDefined('tribInfo.trbPost')>
		<cfset trbPost = tribInfo.trbPost>
    <cfelse>
        <cfset trbPost = ''>
    </cfif>
    
    <cfif IsDefined('tribInfo.srpFname')>
		<cfset srpFname = tribInfo.srpFname>
    <cfelse>
        <cfset srpFname = ''>
    </cfif>
    
    <cfif IsDefined('tribInfo.srpLname')>
		<cfset srpLname = tribInfo.srpLname>
    <cfelse>
        <cfset srpLname = ''>
    </cfif>
    
    <cfif IsDefined('tribInfo.trbCardfrom')>
		<cfset trbCardfrom = tribInfo.trbCardfrom>
    <cfelse>
        <cfset trbCardfrom = ''>
    </cfif>
    
    <cfif IsDefined('tribInfo.trbMsg')>
		<cfset trbMsg = tribInfo.trbMsg>
    <cfelse>
        <cfset trbMsg = ''>
    </cfif>
    
        
    
    <CFQUERY datasource="#APPLICATION.DSN.Superhero#" name="insert_record">
    UPDATE tblAttempt SET
    	gift_tribute = '#tribInfo.gTribute#',
        trb_fname = '#tribInfo.trbFname#',
        trb_lname = '#tribInfo.trbLname#',
        trb_email = '#trbEmail#', 
		trb_address = '#trbAddress#',
		<!--- trb_address two ?? --->
        trb_city = '#trbCity#',
        trb_prov = '#trbProv#', 
        trb_postal = '#trbPost#',
        srp_fname = '#srpFname#', 
        srp_lname = '#srpLname#', 
        trb_cardfrom = '#trbCardfrom#', 
        trb_msg = '#trbMsg#', 
        trib_notes = '#tribInfo.tribNotes#',
        card_send = '#tribInfo.cardSend#'   
    WHERE pge_UUID = '#taRec.tUUID#'
    </CFQUERY>
    
    
    <!--- if the try block fails --->
	<!--- send email with details to isbcchf --- log transaction --->
    <cfcatch type="any">
    
    	<cfset tribAttemptSucAdd = 1>
    
        <cfmail to="csweeting@bcchf.ca" from="error@bcchf.ca" subject="error updating attempted transaction tribute data" type="html">
        Error recording tribute database data into tblGeneral
        Message: #cfcatch.Message#
        Detail: #cfcatch.Detail#
        <cfdump var="#cfcatch#" label="catch">
        <cfdump var="#form#" hide="POST_CARD_NUMBER,POST_CVV,FIELDNAMES,POST_DOLLARAMOUNT,js_bcchf_cardnumber,js_bcchf_cvv">
        </cfmail>
    </cfcatch>
    </cftry>
    
 
        
        
	<cfreturn tAttemptSuc>

</cffunction>


<!--- 2015-02-08 Recording Attempted Transactions - EXact Data --->
<cffunction name="recordExactAttempt" access="private" returntype="boolean">

	<cfargument name="eAttempt" type="string" required="yes">
    <cfargument name="tUUID" type="string" required="yes">
    
    <cftry>
                
    <cfset tAttemptSuc = 1>
    
    <cfset exRec = DeserializeJSON(eAttempt)>
    
    <cftry>
		<cfset DTindex = REFIND("DATE/TIME", exRec.rqst_CTR) + 14>
        <cfset DT = Mid(exRec.rqst_CTR, DTindex, 18)>
        <cfset exact_odbcDT = CreateODBCDateTime(DT)>
    <cfcatch type="any">
        <cfset exact_odbcDT = CreateODBCDateTime(Now())>
    </cfcatch>
    </cftry>
    
    
    <CFQUERY datasource="#APPLICATION.DSN.Superhero#" name="insert_record">
    UPDATE tblAttempt SET
    	post_exactAttpt = '#eAttempt#',
        exact_date = #exact_odbcDT#,
        rqst_authorization_num = '#exRec.Rqst_Authorization_Num#',
        POST_REFERENCE_NO = '#exRec.Rqst_SequenceNo#'
    WHERE pge_UUID = '#tUUID#'
    </CFQUERY>
    
    
    
    <!--- if the try block fails --->
	<!--- send email with details to isbcchf --- log transaction --->
    <cfcatch type="any">
    
    	<cfset tAttemptSuc = 1>
    
        <cfmail to="csweeting@bcchf.ca" from="error@bcchf.ca" subject="error recording transaction data attempt" type="html">
        Error recording database data into tblAttempt
        Message: #cfcatch.Message#
        Detail: #cfcatch.Detail#
        <cfdump var="#cfcatch#" label="catch">
        <cfdump var="#form#" hide="POST_CARD_NUMBER,POST_CVV,FIELDNAMES,POST_DOLLARAMOUNT,js_bcchf_cardnumber,js_bcchf_cvv">
        </cfmail>
    </cfcatch>
    </cftry>
        
        
	<cfreturn tAttemptSuc>

</cffunction>

<!--- Encrypt card data --->
<cffunction name="encrptCard" access="private" returntype="struct">

	<cfargument name="post_card_number" type="string" required="yes">
    <cfargument name="hiddenDonationType" type="string" required="yes">
    
    	
    
		<!--- ensure card type is recorded properly --->
        <!--- check left most digit of card number --->
        <cfif Left(post_card_number, 1) EQ 3>
			<cfset post_card_type = 'AMEX'>
        <cfelseif Left(post_card_number, 1) EQ 4>
			<cfset post_card_type = 'VISA'>
        <cfelseif Left(post_card_number, 1) EQ 5>
			<cfset post_card_type = 'MC'>
        <cfelseif Left(post_card_number, 1) EQ 6>
			<cfset post_card_type = 'DISCOVER'>
        <cfelse>
			<cfset post_card_type = 'Invalid'>
        </cfif>
        
        
        <cftry>
        
        <!--- Only record cc info for monthly transactions --->
		<cfif hiddenDonationType EQ 'monthly'>
			<cfset post_card_number = post_card_number>
        <cfelse>
        <!--- single transactions, 
			destroy ccrd info, 
			record type in card no. --->
        <!--- 2012-08-10 recording last 4 digits only --->
			<cfset post_card_number = RIGHT(post_card_number, 4)>
        </Cfif>
        
		<!--- encrypt card number data --->
        <!--- 2012-10-25 using 2-tiered encryption --->

        <!--- 1. select master key (this should be in application --->
        <cfquery name="selectKey" datasource="bcchf_poll">
        SELECT masterKey FROM encryption WHERE ID = 1
        </cfquery>
        
        
		<!--- 2. randomly select DEK ID to use for encryption --->
        <cfset DEKID = RandRange(1, 100, "SHA1PRNG")>
        
        <!--- select DEK --->
        <cfquery name="selectDEK" datasource="bcchf_poll">
        SELECT dataEncryptionKey FROM DEK WHERE keyID = #DEKID#
        </cfquery>
        
        <!--- 3. decrypt master 
			4. decrypt DEK using decrypted master
			5. encrypt Card Data using decrypted DEK
			--->
        <cfscript>

			almostreadableMaster = BinaryDecode(selectKey.masterKey, "UU");
			readableMaster = toBase64(almostreadableMaster);		
			
			decryptedKey = decrypt(selectDEK.dataEncryptionKey, readableMaster, 'AES', 'Base64');	
			
			theString = post_card_number;
			encryptedCardData = encrypt(theString, decryptedKey, 'AES', 'Base64');
			
		</cfscript>
        
        <cfcatch type="any">
        	<cfset encryptedCardData = 'encryption failed'>
            <cfset DEKID = 0>
        </cfcatch>
        </cftry>

	<cfset secureCard = {encData = encryptedCardData,
					encType = post_card_type,
					encDEKID = DEKID} />

	<cfreturn secureCard>
    
</cffunction>

<!--- 2015-02-08 Recording Successful Transactions --->
<cffunction name="recordSuccAttempt" access="private" returntype="boolean">

	<cfargument name="sAttempt" type="string" required="yes">
    
    <cftry>
                
    <cfset tAttemptSuc = 1>
    
    <cfset sucRec = DeserializeJSON(sAttempt)>
    

	<!--- details of the attempt record --->
	<cfquery name="selectAttempt" datasource="#APPLICATION.DSN.Superhero#">
	SELECT post_exactAttpt,
    	dnrBrowser,
        exact_date,
        pty_date,
        gift_type
    FROM tblAttempt 
    WHERE pge_UUID = '#sucRec.tUUID#'
	</cfquery>

	<cfset eRec = DeserializeJSON(selectAttempt.post_exactAttpt)>

    
    <!--- transaction information---
    <CFQUERY datasource="#APPLICATION.DSN.Superhero#" name="insert_record">
    INSERT INTO tblDonation (dtnDate, exact_date, dtnAmt, dtnBenefit, dtnReceiptAmt, dtnReceiptType, dtnBatch, dtnSource, post_cardholdersname, post_card_number, post_expiry_month, post_expiry_year, post_card_type, DEK_ID, post_ExactID, rqst_transaction_approved, rqst_authorization_num, rqst_dollaramount, rqst_CTR, rqst_sequenceno, rqst_bank_message, rqst_exact_message, rqst_formpost_message, rqst_AVS, pge_UUID, dtnBrowser) 
	VALUES (#CreateODBCDatetime(selectAttempt.pty_Date)#, 
    	#CreateODBCDatetime(selectAttempt.exact_date)#, 
        '#sucRec.tDollar#', 
        '#sucRec.tAdv#', 
        '#sucRec.tTax#', 
        '#sucRec.tRType#', 
        'Online', 
        '#sucRec.tSource#', 
        '#sucRec.tCard.cName#', 
        '#sucRec.tENC.ENCDATA#', 
        '#sucRec.tCard.eXm#', 
        '#sucRec.tCard.eXy#', 
        '#sucRec.tENC.ENCTYPE#', 
        #sucRec.tENC.ENCDEKID#, 
        'A00063-01', 
        '#eRec.rqst_transaction_approved#', 
        '#eRec.rqst_authorization_num#', 
        '#eRec.rqst_dollaramount#', 
        '#eRec.rqst_CTR#', 
        '#eRec.rqst_sequenceno#', 
        '#eRec.rqst_bank_message#', 
        '#eRec.rqst_exact_message#', 
        '#eRec.rqst_formpost_message#', 
        '#eRec.rqst_AVS#', 
        '#sucRec.tUUID#',  
        '#selectAttempt.dnrBrowser#') 
	</CFQUERY> --->
    
    <!--- if the try block fails --->
	<!--- send email with details to isbcchf --- log transaction --->
    <cfcatch type="any">
    
    	<cfset tAttemptSuc = 1>
    
        <cfmail to="csweeting@bcchf.ca" from="error@bcchf.ca" subject="error recording successful transaction data" type="html">
        Error recording successful transaction database data into tblDonation
        Message: #cfcatch.Message#
        Detail: #cfcatch.Detail#
        <cfdump var="#cfcatch#" label="catch">
        </cfmail>
    </cfcatch>
    </cftry>
    
    <cftry>
    
    
    <!--- <cfset receiptNumber = lookReceiptNum(variables.newUUID)> --->
    
    <cfif sucRec.tSHP.tSupID EQ ''>
    	<cfset tSupID = 0>
    <cfelse>
    	<cfset tSupID = sucRec.tSHP.tSupID>
    </cfif>
    
    <cfif sucRec.tSHP.tTeamID EQ ''>
    	<cfset tTeamID = 0>
    <cfelse>
    	<cfset tTeamID = sucRec.tSHP.tTeamID>
    </cfif>
    
    <cfif IsDefined('sucRec.tJD.Pins')>
		<cfset jdPins = sucRec.tJD.Pins>
    <cfelse>
        <cfset jdPins = 0>
    </cfif>
    
    <cfif IsDefined('sucRec.tJD.Buttons')>
        <cfset jdButtons = sucRec.tJD.Buttons>
    <cfelse>
        <cfset jdButtons = 0>
    </cfif>
    
    <!--- donation information ---
    <CFQUERY datasource="#APPLICATION.DSN.Superhero#" name="insert_record">
	INSERT INTO tblGeneral (pty_date, exact_date, pty_title, pty_fname, pty_miname, pty_lname, pty_companyname, ptc_address, ptc_add_two, ptc_city, ptc_prov, ptc_post, ptc_country, ptc_email, ptc_phone, pty_tax_title, pty_tax_fname, pty_tax_lname, pty_tax_companyname, gift, gift_Advantage, gift_Eligible, gift_type, gift_frequency, gift_notes, pty_tax, gift_day, SupID, TeamID, JD_Pin, JD_Button, pge_UUID) 
	VALUES (#CreateODBCDatetime(selectAttempt.pty_Date)#, 
    	#CreateODBCDatetime(selectAttempt.exact_date)#, 
		'#sucRec.tDonor.dTitle#', 
        '#sucRec.tDonor.dFname#', 
        '#sucRec.tDonor.dMname#', 
        '#sucRec.tDonor.dLname#',  
        '#sucRec.tDonor.dCname#', 
        '#sucRec.tDonor.dAddress.aOne#', 
        '#sucRec.tDonor.dAddress.aTwo#', 
        '#sucRec.tDonor.dAddress.aCity#', 
        '#sucRec.tDonor.dAddress.aProv#', 
        '#sucRec.tDonor.dAddress.aPost#', 
        '#sucRec.tDonor.dAddress.aCountry#', 
        '#sucRec.tDonor.dEmail#', 
        '#sucRec.tDonor.dPhone#', 
        '#sucRec.tDonor.dTaxTitle#', 
        '#sucRec.tDonor.dTaxFname#',
        '#sucRec.tDonor.dTaxLname#', 
        '#sucRec.tDonor.dTaxCname#', 
        '#sucRec.tDollar#',
        '#sucRec.tAdv#', 
        '#sucRec.tTax#',
        '#sucRec.tType#', 
        '#sucRec.tFreq#', 
        '#sucRec.tNotes#', 
        '#sucRec.tTType#', 
        '#sucRec.tFreqDay#',
        #tSupID#, 
        #tTeamID#,
        #jdPins#, 
		#jdButtons#,
        '#sucRec.tUUID#')
	</CFQUERY> --->
    
    <!--- if the try block fails --->
	<!--- send email with details to isbcchf --- log transaction --->
    <cfcatch type="any">
    
    	<cfset tAttemptSuc = 1>
    
        <cfmail to="csweeting@bcchf.ca" from="error@bcchf.ca" subject="error recording successful transaction data" type="html">
        Error recording successful transaction database data into tblGeneral
        Message: #cfcatch.Message#
        Detail: #cfcatch.Detail#
        <cfdump var="#cfcatch#" label="catch">
        <cfdump var="#form#" hide="POST_CARD_NUMBER,POST_CVV,FIELDNAMES,POST_DOLLARAMOUNT,js_bcchf_cardnumber,js_bcchf_cvv">
        </cfmail>
    </cfcatch>
    </cftry>
    
    
    <cftry>
    
    
    <cfif sucRec.tSHP.tAdd EQ 1>
    
    	<!--- Monthly * 12 in SHP --->
    	<cfif sucRec.tFreq EQ 'Monthly'
			OR sucRec.tFreq EQ 'Monthly - No Receipt'>
            
            <cfset Hero_Donate_Amount = sucRec.tDollar><!---  * 12 --->
            
		<cfelse>
        
			<cfset Hero_Donate_Amount = sucRec.tDollar>
            
		</cfif>
        
        <cfif IsDefined('sucRec.tJD.Pins')>
        	<cfset jdPins = sucRec.tJD.Pins>
		<cfelse>
        	<cfset jdPins = 0>
        </cfif>
        
        <cfif IsDefined('sucRec.tJD.Buttons')>
        	<cfset jdButtons = sucRec.tJD.Buttons>
		<cfelse>
        	<cfset jdButtons = 0>
        </cfif>
        
        <cfif IsDefined('sucRec.tJD.BBQ')>
        	<cfset jdBBQ = sucRec.tJD.BBQ>
		<cfelse>
        	<cfset jdBBQ = 0>
        </cfif>
        
        <cfif IsDefined('sucRec.tJD.cFriday')>
        	<cfset jdcFriday = sucRec.tJD.cFriday>
		<cfelse>
        	<cfset jdcFriday = 0>
        </cfif>
        
        <cfif IsDefined('sucRec.tJD.BBQl')>
        	<cfset jdBBQl = sucRec.tJD.BBQl>
		<cfelse>
        	<cfset jdBBQl = 0>
        </cfif>
        
        <cfif sucRec.tSHP.tToken EQ ''>
        	<cfset SHPeventToken = 'General'>
		<cfelse>
        	<cfset SHPeventToken = sucRec.tSHP.tToken>
        </cfif>
        
        <cfif sucRec.tSHP.tCampaign EQ ''>
        	<cfset SHPeventCampaign = 0>
		<cfelse>
        	<cfset SHPeventCampaign = sucRec.tSHP.tCampaign>
        </cfif>
        
        <cfif sucRec.tSHP.tTeamID EQ ''>
        	<cfset SHPeventTeamID = 0>
		<cfelse>
        	<cfset SHPeventTeamID = sucRec.tSHP.tTeamID>
        </cfif>
        
        <cfif sucRec.tSHP.tSupID EQ ''>
        	<cfset SHPeventSupID = 0>
		<cfelse>
        	<cfset SHPeventSupID = sucRec.tSHP.tSupID>
        </cfif>
        
        <cfset SHPnoScroll = 0>
        
        
        
        
    
		<!--- insert into hero_donate --->
    	<cfquery name="insertHeroDonation" datasource="#APPLICATION.DSN.Superhero#">
		INSERT INTO Hero_Donate (Event, Campaign, TeamID, Name, Type, Message, Show, DonTitle, DonFName, DonLName, DonCompany, Email, don_date, Amount, SupID, JDPins, JDButtons, JDBBQ, JDCF, JDInputType, pge_UUID, AddDate, UserAdd, LastChange, LastUser, frequency) 
		VALUES ('#SHPeventToken#', 
        	#SHPeventCampaign#, 
            #SHPeventTeamID#, 
            '#sucRec.tSHP.tDname#', 
            '#sucRec.tSHP.tStype#', 
            '#sucRec.tSHP.tSmsg#', 
            #sucRec.tSHP.tSshow#, 
            '#sucRec.tDonor.dTitle#', 
			'#sucRec.tDonor.dFname#',
            '#sucRec.tDonor.dLname#',  
        	'#sucRec.tDonor.dCname#', 
            '#sucRec.tDonor.dEmail#', 
            #CreateODBCDatetime(selectAttempt.pty_Date)#, 
            #Hero_Donate_Amount#, 
            #SHPeventSupID#, 
            #jdPins#, 
            #jdButtons#, 
            #jdBBQ#,
            #jdcFriday#,
            '#jdBBQl#',
            '#sucRec.tUUID#', 
            #CreateODBCDatetime(selectAttempt.pty_Date)#,
            'Online', 
            #CreateODBCDatetime(selectAttempt.pty_Date)#,
            'Online',
            '#sucRec.tFreq#')
		</cfquery>
        
        <!--- CHECK if we are Jeans Day AND BBQ
			Add appropriate lines to BBQtix tables
			for downtown BBQ only --->
            <cfif SHPeventToken EQ 'JeansDay' 
				AND jdBBQ GTE 1
				AND SHPeventTeamID EQ 9130>
                
                <cfloop from="1" to="#jdBBQ#" index="i">
                
                <cfquery name="insertHeroDonation" datasource="bcchf_SuperHero">
                INSERT INTO JeansDay_BBQtix (BBQ_tblUUID, BBQ_Date) 
                VALUES ('#sucRec.tUUID#', #CreateODBCDatetime(selectAttempt.pty_Date)#)
                </cfquery>
                
                </cfloop>
                
                
                
            </cfif>
        
    </cfif>
    
    
    <!--- if the try block fails --->
	<!--- send email with details to isbcchf --- log transaction --->
    <cfcatch type="any">
    
    	<cfset tAttemptSuc = 1>
    
        <cfmail to="csweeting@bcchf.ca" from="error@bcchf.ca" subject="error recording successful transaction data to SHP" type="html">
        Error recording successful transaction database data into Hero_Donate
        Message: #cfcatch.Message#
        Detail: #cfcatch.Detail#
        <cfdump var="#cfcatch#" label="catch">
        <cfdump var="#form#" hide="POST_CARD_NUMBER,POST_CVV,FIELDNAMES,POST_DOLLARAMOUNT,js_bcchf_cardnumber,js_bcchf_cvv">
        </cfmail>
    </cfcatch>
    </cftry>
        
        
	<cfreturn tAttemptSuc>

</cffunction>

<!--- Lookup Receipt Number --->
<cffunction name="lookReceiptNum" access="private" returntype="string">

	<cfargument name="tUUID" type="string" required="yes">
    
    <cfset receiptNum = 0>
    
    <!--- we want the ID from tblDonation for the tax receipt --->
	<cfquery name="selectID" datasource="#APPLICATION.DSN.Superhero#">
	SELECT dtnID FROM tblDonation WHERE pge_UUID = '#tUUID#'
	</cfquery>
    
    <!--- new method for new receipts --->
	<cfif selectID.dtnID GTE 200000>
        <cfset receiptNum = selectID.dtnID + 1100000>
    <cfelse>
        <cfset receiptNum = selectID.dtnID + 800000>
    </cfif>
    

	<cfreturn receiptNum>
    
</cffunction>

<!--- 2015-02-08 Recording Successful Transactions - Additional Data --->
<cffunction name="recordSuccAdd" access="private" returntype="boolean">

	<cfargument name="aAttempt" type="string" required="yes">
    <cfargument name="tUUID" type="string" required="yes">
    
    <cftry>
                
    <cfset tAttemptSucAdd = 1>
    
    <cfset AddInfo = DeserializeJSON(aAttempt)>
    
    <cfif IsDefined('AddInfo.iWhere')>
		<cfset iWhere = AddInfo.iWhere>
    <cfelse>
        <cfset iWhere = ''>
    </cfif>
    
    <cfif IsDefined('AddInfo.iPastDonor')>
		<cfset iPastDonor = AddInfo.iPastDonor>
    <cfelse>
        <cfset iPastDonor = ''>
    </cfif>
    
    <cfif IsDefined('AddInfo.iSecurity')>
		<cfset iSecurity = AddInfo.iSecurity>
    <cfelse>
        <cfset iSecurity = ''>
    </cfif>
    
    <cfif IsDefined('AddInfo.iWill')>
		<cfset iWill = AddInfo.iWill>
    <cfelse>
        <cfset iWill = ''>
    </cfif>
    
    <cfif IsDefined('AddInfo.iLife')>
		<cfset iLife = AddInfo.iLife>
    <cfelse>
        <cfset iLife = ''>
    </cfif>
    
    <cfif IsDefined('AddInfo.iRRSP')>
		<cfset iRRSP = AddInfo.iRRSP>
    <cfelse>
        <cfset iRRSP = ''>
    </cfif>
    
    <cfif IsDefined('AddInfo.iTrust')>
		<cfset iTrust = AddInfo.iTrust>
    <cfelse>
        <cfset iTrust = ''>
    </cfif>
    
    <cfif IsDefined('AddInfo.iWillInclude')>
		<cfset iWillInclude = AddInfo.iWillInclude>
    <cfelse>
        <cfset iWillInclude = ''>
    </cfif>
    
    <cfif IsDefined('AddInfo.iLifeInclude')>
		<cfset iLifeInclude = AddInfo.iLifeInclude>
    <cfelse>
        <cfset iLifeInclude = ''>
    </cfif>
    
    <cfif IsDefined('AddInfo.iRSPInclude')>
		<cfset iRRSPInclude = AddInfo.iRSPInclude>
    <cfelse>
        <cfset iRRSPInclude = ''>
    </cfif>
    
    <cfif IsDefined('AddInfo.news_subscribe')>
		<cfset news_subscribe = AddInfo.news_subscribe>
    <cfelse>
        <cfset news_subscribe = 0>
    </cfif>
    
    <cfif IsDefined('AddInfo.SOC_subscribe')>
		<cfset SOC_subscribe = AddInfo.SOC_subscribe>
    <cfelse>
        <cfset SOC_subscribe = 0>
    </cfif>
    
    <cfif IsDefined('AddInfo.AR_subscribe')>
		<cfset AR_subscribe = AddInfo.AR_subscribe>
    <cfelse>
        <cfset AR_subscribe = 0>
    </cfif>
    
    <cfif IsDefined('AddInfo.gPledgeDet')>
		<cfset gPledgeDet = AddInfo.gPledgeDet>
    <cfelse>
        <cfset gPledgeDet = ''>
    </cfif>
        
    <!--- 
    <CFQUERY datasource="#APPLICATION.DSN.Superhero#" name="insert_record">
    UPDATE tblGeneral SET
    	info_where = '#iWhere#', 
        donated_before = '#iPastDonor#',
        info_securities = '#iSecurity#',
        info_will = '#iWill#', 
        info_life = '#iLife#', 
        info_RRSP = '#iRRSP#', 
        info_trusts = '#iTrust#', 
        info_willinclude = '#iWillInclude#', 
        info_lifeinclude = '#iLifeInclude#', 
        info_RSPinclude = '#iRRSPinclude#',
        ptc_subscribe = '#news_subscribe#',
        SOC_subscribe = '#SOC_subscribe#', 
        AR_subscribe = '#AR_subscribe#', 
        gift_pledge_det = '#gPledgeDet#'      
    WHERE pge_UUID = '#tUUID#'
    </CFQUERY> --->
    
    
    <!--- if the try block fails --->
	<!--- send email with details to isbcchf --- log transaction --->
    <cfcatch type="any">
    
    	<cfset tAttemptSucAdd = 1>
    
        <cfmail to="csweeting@bcchf.ca" from="error@bcchf.ca" subject="error recording successful transaction additional data" type="html">
        Error recording additional database data into tblGeneral
        Message: #cfcatch.Message#
        Detail: #cfcatch.Detail#
        <cfdump var="#cfcatch#" label="catch">
        <cfdump var="#form#" hide="POST_CARD_NUMBER,POST_CVV,FIELDNAMES,POST_DOLLARAMOUNT,js_bcchf_cardnumber,js_bcchf_cvv">
        </cfmail>
    </cfcatch>
    </cftry>
        
        
	<cfreturn tAttemptSucAdd>

</cffunction>

<!--- 2015-02-08 Recording Successful Transactions - Pledge Data --->
<cffunction name="recordSuccPledge" access="private" returntype="boolean">

	<cfargument name="pAttempt" type="string" required="yes">
    <cfargument name="tUUID" type="string" required="yes">
    
    <cftry>
                
    <cfset tAttemptSucPledge = 1>
    
    <cfset PledgeInfo = DeserializeJSON(pAttempt)>
        
    <!--- 
    <CFQUERY datasource="#APPLICATION.DSN.Superhero#" name="insert_record">
    UPDATE tblGeneral SET
    	gift_pledge_det = '#PledgeInfo.pDetail#',
        gift_pledge = '#PledgeInfo.pledge#', 
        ConstitID = '#PledgeInfo.pDREID#'   
    WHERE pge_UUID = '#tUUID#'
    </CFQUERY> --->
    
    
    <!--- if the try block fails --->
	<!--- send email with details to isbcchf --- log transaction --->
    <cfcatch type="any">
    
    	<cfset tAttemptSucPledge = 1>
    
        <cfmail to="csweeting@bcchf.ca" from="error@bcchf.ca" subject="error recording successful transaction additional data" type="html">
        Error recording additional database data into tblGeneral
        Message: #cfcatch.Message#
        Detail: #cfcatch.Detail#
        <cfdump var="#cfcatch#" label="catch">
        <cfdump var="#form#" hide="POST_CARD_NUMBER,POST_CVV,FIELDNAMES,POST_DOLLARAMOUNT,js_bcchf_cardnumber,js_bcchf_cvv">
        </cfmail>
    </cfcatch>
    </cftry>
        
        
	<cfreturn tAttemptSucPledge>

</cffunction>

<!--- 2015-02-08 Recording Successful Transactions - Tribute Data --->
<cffunction name="recordSuccTrib" access="private" returntype="boolean">

	<cfargument name="tribAttempt" type="string" required="yes">
    <cfargument name="tUUID" type="string" required="yes">
    
    <cftry>
                
    <cfset tribAttemptSucAdd = 1>
    
    <cfset tribInfo = DeserializeJSON(tribAttempt)>
    
    <cfif IsDefined('tribInfo.trbEmail')>
		<cfset trbEmail = tribInfo.trbEmail>
    <cfelse>
        <cfset trbEmail = ''>
    </cfif>
    
    <cfif IsDefined('tribInfo.trbAddress')>
		<cfset trbAddress = tribInfo.trbAddress>
    <cfelse>
        <cfset trbAddress = ''>
    </cfif>
    
    <cfif IsDefined('tribInfo.trbCity')>
		<cfset trbCity = tribInfo.trbCity>
    <cfelse>
        <cfset trbCity = ''>
    </cfif>
    
    <cfif IsDefined('tribInfo.trbProv')>
		<cfset trbProv = tribInfo.trbProv>
    <cfelse>
        <cfset trbProv = ''>
    </cfif>
    
    <cfif IsDefined('tribInfo.trbPost')>
		<cfset trbPost = tribInfo.trbPost>
    <cfelse>
        <cfset trbPost = ''>
    </cfif>
    
    <cfif IsDefined('tribInfo.srpFname')>
		<cfset srpFname = tribInfo.srpFname>
    <cfelse>
        <cfset srpFname = ''>
    </cfif>
    
    <cfif IsDefined('tribInfo.srpLname')>
		<cfset srpLname = tribInfo.srpLname>
    <cfelse>
        <cfset srpLname = ''>
    </cfif>
    
    <cfif IsDefined('tribInfo.trbCardfrom')>
		<cfset trbCardfrom = tribInfo.trbCardfrom>
    <cfelse>
        <cfset trbCardfrom = ''>
    </cfif>
    
    <cfif IsDefined('tribInfo.trbMsg')>
		<cfset trbMsg = tribInfo.trbMsg>
    <cfelse>
        <cfset trbMsg = ''>
    </cfif>
        
    <!--- trb_address two ?? 
    <CFQUERY datasource="#APPLICATION.DSN.Superhero#" name="insert_record">
    UPDATE tblGeneral SET
    	gift_tribute = 'yes',
        trb_fname = '#tribInfo.trbFname#',
        trb_lname = '#tribInfo.trbLname#',
        trb_email = '#trbEmail#', 
		trb_address = '#trbAddress#',
		
        trb_city = '#trbCity#',
        trb_prov = '#trbProv#', 
        trb_postal = '#trbPost#',
        srp_fname = '#srpFname#', 
        srp_lname = '#srpLname#', 
        trb_cardfrom = '#trbCardfrom#', 
        trb_msg = '#trbMsg#', 
        trib_notes = '#tribInfo.tribNotes#',
        card_send = '#tribInfo.cardSend#'   
    WHERE pge_UUID = '#tUUID#'
    </CFQUERY>--->
    
    
    <!--- if the try block fails --->
	<!--- send email with details to isbcchf --- log transaction --->
    <cfcatch type="any">
    
    	<cfset tribAttemptSucAdd = 1>
    
        <cfmail to="csweeting@bcchf.ca" from="error@bcchf.ca" subject="error recording successful transaction tribute data" type="html">
        Error recording tribute database data into tblGeneral
        Message: #cfcatch.Message#
        Detail: #cfcatch.Detail#
        <cfdump var="#cfcatch#" label="catch">
        </cfmail>
    </cfcatch>
    </cftry>
        
        
	<cfreturn tribAttemptSucAdd>

</cffunction>

<!--- 2015-02-09 Check Email Referral Token --->
<cffunction name="checkEmailReff" access="private" returntype="boolean">

	<cfargument name="eUUID" type="string" required="yes">
    <cfargument name="tUUID" type="string" required="yes">
    
    <!--- UPDATE SHP email with donation info
		UPDATE specific email with specific click --->
    <cftry>
                
	<cfif NOT IsDefined("pty_date")><cfset pty_date= "#Now()#"></cfif>
    
    <cfquery name="updateEMailAddress" datasource="#APPLICATION.DSN.Superhero#">
    UPDATE Hero_EMail
    SET DonationDate = #CreateODBCDateTime(Now())#
    WHERE PageVDate = '#eUUID#'
    </cfquery>
    
    <cfquery name="GetLinkStruct" datasource="bcchf_SuperHero">
    SELECT EmMetaData FROM Hero_Email_SupRecieved
    WHERE EmUUID = '#eUUID#'
    </cfquery>
    
    <cfif GetLinkStruct.recordCount NEQ 0>
    
    <cfset emailMeta = DeSerializeJSON(GetLinkStruct.EmMetaData)>
    
    <cfset emailMeta.Donation = {dDate = pty_date,
								dUUID = tUUID,
								donated = 1} />
    
    
    <cfset emailMetaJSON = SerializeJSON(emailMeta)>
    
    <cfquery name="UpdateEmailStat" datasource="bcchf_SuperHero">
    UPDATE Hero_Email_SupRecieved
    SET EmMetaData = '#emailMetaJSON#',
        EmClickDate = #pty_date#
    WHERE EmUUID = '#URL.emID#'
    </cfquery>
    
    
    </cfif>
    
    
    <cfcatch type="any">
    
    <cfmail to="csweeting@bcchf.ca" from="error@bcchf.ca" subject="error recording email refferal data" type="html">
        Error recording email referral data to Hero_Email
        <cfdump var="#cfcatch#">
        <cfdump var="#CGI#">
    </cfmail>
        
    </cfcatch>
    </cftry>

    <cfset eUpdated = 1>  
	<cfreturn eUpdated>

</cffunction>

<!--- Notification Email TO: Foundation access="private"  --->
<cffunction name="FDNnotifyEmail" returntype="boolean">

	<cfargument name="pge_UUID" type="string" required="yes">

	<cftry>
	<cfset emailOK = 1>
    
    <cfquery name="selectTransaction" datasource="bcchf_Superhero">
    SELECT tblGeneral.pge_UUID, tblGeneral.pty_title, tblGeneral.pty_fname, tblGeneral.pty_miname, tblGeneral.pty_lname, tblGeneral.pty_companyname, tblGeneral.ptc_address, tblGeneral.ptc_add_two, tblGeneral.ptc_city, tblGeneral.ptc_prov, tblGeneral.ptc_post, tblGeneral.ptc_email, tblGeneral.ptc_phone, tblGeneral.pty_tax_companyname, tblGeneral.gift, tblGeneral.gift_type, tblGeneral.gift_frequency, tblGeneral.gift_pledge, tblGeneral.gift_pledge_det, tblGeneral.gift_notes, tblGeneral.SOC_subscribe, tblGeneral.AR_subscribe, tblGeneral.ConstitID
    FROM tblGeneral
    WHERE (((tblGeneral.pge_UUID)='#pge_UUID#'));
    </cfquery>
    
    <cfquery name="selectTransRecord" datasource="bcchf_Superhero">
    SELECT tblDonation.dtnIP, tblDonation.dtnBrowser, tblDonation.rqst_transaction_approved, tblDonation.rqst_authorization_num, tblDonation.rqst_dollaramount, tblDonation.rqst_CTR, tblDonation.rqst_sequenceno, tblDonation.dtnSource
    FROM tblDonation
    WHERE (((tblDonation.pge_UUID)='#pge_UUID#'));
    </cfquery>
    
    <!---- FIRST TO FOUNDATION IN ALL CASES --->
	<cfset toRecievers = 'bcchfds@bcchf.ca'><!--- --->
    <cfset ccRecievers = 'isbcchf@bcchf.ca'>
    
    <!--- for 10K+ cc ccc program --->
    <cfif selectTransaction.gift GT 9999>
    	<cfset ccRecievers = '#ccRecievers#;ccc@bcchf.ca'>
    </cfif>
    
	<!--- for pledge cc Aaron --->
    <cfif selectTransaction.gift_type EQ 'Pledge'>
    	<cfset ccRecievers = '#ccRecievers#;ahui@bcchf.ca'>
    </cfif> 
    
    <cfif selectTransaction.pty_tax_companyname EQ ''>
    	<cfset PCtype = 'Personal'>
    <cfelse>
    	<cfset PCtype = 'Corporate'>
    </cfif>  
        
	<!--- ontent of E-mail to Foundation --->
    <cfmail to="#toRecievers#" cc="#ccRecievers#" from="bcchfds@bcchf.ca" subject="BCCHF Donation Notification" failto="csweeting@bcchf.ca" >
    <cfif selectTransaction.gift_type EQ 'Pledge'>Pledge Payment
    Donor Supplied RE ID: #selectTransaction.ConstitID#</cfif>
    Personal/Corporate: #PCtype#
    Title: #selectTransaction.pty_title#
    Name: #selectTransaction.pty_fname# #selectTransaction.pty_lname#
    Company Name: #selectTransaction.pty_companyname#
    Email: #selectTransaction.ptc_email#
    
    Email Subscribe: #selectTransaction.SOC_subscribe#
    
    Address: #selectTransaction.ptc_address# #selectTransaction.ptc_add_two#
    City: #selectTransaction.ptc_city#
    Province: #selectTransaction.ptc_prov#
    Postal Code: #selectTransaction.ptc_post#
    Phone: #selectTransaction.ptc_phone#
    Date/Time: #DateFormat(Now(), "DDDD, MMMM DD, YYYY")#
    Frequency: #selectTransaction.gift_frequency#
    Gift Appeal: #selectTransaction.gift_type#
    Comments: #selectTransaction.gift_notes#<!---  --->
    <cfif selectTransaction.gift_type EQ 'Pledge'>
    Pledge Comments: #selectTransaction.gift_pledge_det#<!---  --->
    </cfif>
    Donation: #selectTransaction.gift#
    
    Transaction Information
    
    rqst_transaction_approved:	#selectTransRecord.rqst_transaction_approved#
    rqst_authorization_num:		#selectTransRecord.rqst_authorization_num#
    rqst_dollaramount:			#selectTransRecord.rqst_dollaramount#
    rqst_sequenceno:			#selectTransRecord.rqst_sequenceno#
    
    Source: #selectTransRecord.dtnSource#
    IP Address: #selectTransRecord.dtnIP#
    Browser Agent: #selectTransRecord.dtnBrowser#
    </cfmail>
    
    <cfcatch type="any">
        
    <cfmail to="csweeting@bcchf.ca" from="error@bcchf.ca" subject="error sending FDN notification email" type="html">
        Error sending FDN notification email
        Message: #cfcatch.Message#
        Detail: #cfcatch.Detail#
        <cfdump var="#cfcatch#">
        </cfmail>
        
    </cfcatch>
    </cftry>


	<cfreturn emailOK>

</cffunction>

<!--- Notification Email TO: Tribute Awk --->
<cffunction name="TribAwkEmail" access="private" returntype="boolean">

	<cfargument name="pge_UUID" type="string" required="yes">

	<cftry>
	<cfset emailOK = 1>
    
    <cfquery name="selectTransaction" datasource="bcchf_Superhero">
    SELECT tblGeneral.pty_fname, tblGeneral.pty_lname, tblGeneral.gift, tblGeneral.trib_notes, tblGeneral.trb_fname, tblGeneral.trb_lname, tblGeneral.srp_fname, tblGeneral.srp_lname, tblGeneral.trb_email, tblGeneral.trb_cardfrom, tblGeneral.trb_msg, tblGeneral.ptc_email
FROM tblGeneral
    WHERE (((tblGeneral.pge_UUID)='#pge_UUID#'));
    </cfquery>
    
    
    <cfif selectTransaction.trib_notes EQ 'hon' 
		OR selectTransaction.trib_notes EQ 'honour'>
		<cfset tribEmailSubject = "In Honour Donation">
                
		<cfif selectTransaction.srp_fname EQ selectTransaction.trb_fname
        	AND selectTransaction.srp_lname EQ selectTransaction.trb_lname>
                	
			<cfset trbHonMSG = 'in your honour'>
            
		<cfelse>
        
			<cfset trbHonMSG = 'in honour of #selectTransaction.trb_fname# #selectTransaction.trb_lname#'>
            
		</cfif>
                
	<cfelseif selectTransaction.trib_notes EQ 'mem'
		OR selectTransaction.trib_notes EQ 'memory'>
        
		<cfset tribEmailSubject = "Memorial Donation">
        
	</cfif>
    
    <cfif selectTransaction.srp_fname EQ '' 
		AND selectTransaction.srp_lname EQ ''>
    
    	<cfset trbEmailTo = "#selectTransaction.trb_email#">
    <cfelse>
		<cfset trbEmailTo = "#selectTransaction.srp_fname# #selectTransaction.srp_lname# <#selectTransaction.trb_email#>">
    </cfif>
    <cfset trbEmailFrom = "BC Children's Hospital Foundation <tributeprogram@bcchf.ca>">
    
    
	<cfmail to="#trbEmailTo#" from="#trbEmailFrom#" replyto="#selectTransaction.ptc_email#" subject="#tribEmailSubject#" type="html">
    <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">

<head>

<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />

<title>BC Children's Hospital Foundation</title>


<link href="../css/styles-superhero.css" rel="stylesheet" type="text/css" />
<link href="../css/ANOM-emailStyles.css" rel="stylesheet" type="text/css" />

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
    
	<div><img src="http://newsletter.bcchf.ca/images/2014/header-General.png" width="720" alt="BC Children's Hospital Foundation" border="0" ></div>

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
<div style="font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 12px; text-align: left; line-height: 20px; padding-right: 30px; color: ##000000;">

    <p>Dear #selectTransaction.srp_fname#,</p>
    <cfif selectTransaction.trib_notes EQ 'hon'
		OR selectTransaction.trib_notes EQ 'honour'>
    <p>I would like to inform you that a donation has been made to BC Children's Hospital Foundation #trbHonMSG#. This gift has been made by:</p>
    <cfelseif selectTransaction.trib_notes EQ 'mem'
		OR selectTransaction.trib_notes EQ 'memory'>
    <p>I would like to inform you that a gift has been made to BC Children's Hospital Foundation in memory of #selectTransaction.trb_fname# #selectTransaction.trb_lname#. The gift has been made by:</p>
    </cfif>
    <table width="100%" border="1" cellpadding="5" cellspacing="5">
    <tr>
    <td><div align="center"><p>#selectTransaction.trb_cardfrom#</p>
    <cfif selectTransaction.trb_msg NEQ ''>
    <p>#selectTransaction.trb_msg#</p>
    </cfif>
    </div>
    </td>
    </tr>
    </table>
    <cfif selectTransaction.trib_notes EQ 'hon'
		OR selectTransaction.trib_notes EQ 'honour'>
    <p>Gifts like this one help ensure every one of BC's children has access to the highest level of pediatric care and specialized treatments available. Thank you for helping make a difference in the lives of thousands of families across the province that will benefit from this support.
    </p>
    <cfelseif selectTransaction.trib_notes EQ 'mem'
		OR selectTransaction.trib_notes EQ 'memory'>
    <p>We extend our sincerest condolences to you and your family and hope that you find comfort in knowing that this gift will be making a difference in the lives of children and families at BC Children's Hospital. </p>
    </cfif>
    <p>Sincerely,<br />
    &nbsp;<br />
    Cherie Spence<br />
    Philanthropy Coordinator<br />
    Tribute Program<br />
    BC Children's Hospital Foundation<br />
    938 West 28th Avenue, Vancouver BC V5Z 4H4<br />
    Tel: 604-875-2444 - Fax: 604-875-2596 - Toll Free: 1-888-663-3033<br />
    Website: <a href="http://www.bcchf.ca">www.bcchf.ca</a></p>
    
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

<div><img src="http://newsletter.bcchf.ca/images/2015/footer.png" width="720" border="0" height="168" usemap="##GeneralMap"></div>

<map name="GeneralMap">
	<area shape="rect" coords="627,15,667,57" href="https://instagram.com/bcchf" target="_blank" alt="Instagram" />
    <area shape="rect" coords="506,15,549,59" href="https://www.facebook.com/BCCHF" target="_blank" alt="Facebook">
    <area shape="rect" coords="568,15,608,57" href="http://twitter.com/bcchf" target="_blank" alt="Twitter">
    <area shape="rect" coords="504,71,704,132" href="http://www.bcchf.ca/donate/?utm_source=newsletter17&utm_medium=email&utm_campaign=General&utm_content=BottomGraphic" target="_blank" alt="Donate">
</map>

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
    
    
    </cfmail>
    
    <cfcatch type="any">
        
    <cfmail to="csweeting@bcchf.ca" from="error@bcchf.ca" subject="error sending Trib AWK email" type="html">
        Error sending Trib AWK email
        Message: #cfcatch.Message#
        Detail: #cfcatch.Detail#
        <cfdump var="#cfcatch#">
        </cfmail>
        
    </cfcatch>
    </cftry>


	<cfreturn emailOK>

</cffunction>

<!--- Notification Emails ICE --->
<cffunction name="ICEnotifyEmail" access="private" returntype="boolean">

	<cfargument name="pge_UUID" type="string" required="yes">
    
    <cftry>
    <cfset emailOK = 1>
    
    <cfquery name="selectTransaction" datasource="#APPLICATION.DSN.Superhero#">
    SELECT tblGeneral.pty_fname, tblGeneral.pty_lname, tblGeneral.gift, tblGeneral.ptc_email, tblGeneral.SupID, tblGeneral.TeamID
    FROM tblGeneral
    WHERE (((tblGeneral.pge_UUID)='#pge_UUID#'));
    </cfquery>
    
    <cfquery name="selectMember" datasource="#APPLICATION.DSN.Superhero#">
    SELECT SupFName, SupLName, SupEmail, Don_Notify 
    FROM Hero_Members WHERE SuppID = #selectTransaction.SupID#
    </cfquery>
    
    
    <!--- 1. to the supporter - in most cases this is also the team captain --->
	<!--- do not send if the user has disabled notifications --->
	<cfif SelectMember.Don_notify EQ 1 OR SelectMember.Don_notify EQ 'Yes'>
        
		<cfif selectTransaction.SupID EQ 19609><!--- custom mail to coast capital --->
            <cfset SHPnotificationTO = "Danijela.Adzic@coastcapitalsavings.com,kimberly.tompkins@coastcapitalsavings.com">
        <cfelseif selectTransaction.SupID EQ 19796><!--- custom email to fs financial --->
            <cfset SHPnotificationTO = "melissa.zhang@fsfinancial.ca,dixon.wong@fsfinancial.ca">
        <cfelse>
            <cfset SHPnotificationTO = "#SelectMember.SupFName# #SelectMember.SupLName# <#SelectMember.SupEmail#>">
        </cfif>
            
        <cfmail to="#SHPnotificationTO#" failto="csweeting@bcchf.ca" from="BCCHF Community Events <bcchfds@bcchf.ca>" subject="A donation has been made to your Community Event Page" type="html">
        <p>#SelectMember.SupFName# #SelectMember.SupLName#</p>
        <p>Congratulations, a #DollarFormat(selectTransaction.gift)# donation has been made from #selectTransaction.pty_fname# #selectTransaction.pty_lname# to your Community Event Page. 
        <a href="https://secure.bcchf.ca/SuperHeroPages/login.cfm?Event=ICE">Login here</a> to check your fundraising progress and to thank your supporters. 
        Thank you for your continued support!</p>
        </cfmail>        
    
        <!---  Email to ICE organizer complete" )> --->
		
	</cfif>
    
    
    
    <cfif selectTransaction.TeamID NEQ 0>
        <!--- 2. to the team captain, 
		when the team captain is not the supporter above--->
        <cfquery name="selectTeam" datasource="#APPLICATION.DSN.Superhero#">
        SELECT Hero_Team.TeamID, Hero_Team.TeamName, Hero_Team.Lead_DonNot, Hero_Members.SupFName, Hero_Members.SupLName, Hero_Members.SupEmail, Hero_Members.SuppID
        FROM Hero_Team LEFT JOIN Hero_Members ON Hero_Team.TeamLeadID = Hero_Members.SuppId
        WHERE (((Hero_Team.TeamID)=#selectTransaction.TeamID#));
        </cfquery>
        
        <cfif (selectTeam.Lead_DonNot EQ 1 OR selectTeam.Lead_DonNot EQ 'Yes') 
			AND selectTeam.SuppID NEQ selectTransaction.SupID>
        <!---   --->
        
        
			<cfset SHPnotificationTO = "#SelectTeam.SupFName# #SelectTeam.SupLName# <#SelectTeam.SupEmail#>">
            <cfset SHPnotificationFROM = "BCCHF Community Events <bcchfds@bcchf.ca>">
            <cfset SHPsubject = "A donation has been made to your Community Event Page">
            <cfset SHPnotification = '<p>#SelectTeam.SupFName# #SelectTeam.SupLName#</p>
            <p>Congratulations, a #DollarFormat(selectTransaction.gift)# donation has been made from #selectTransaction.pty_fname# #selectTransaction.pty_lname# to your Community Event Page in support of #SelectMember.SupFName# #SelectMember.SupLName#. <a href="https://secure.bcchf.ca/SuperHeroPages/login.cfm?Event=ICE">Login here</a> to check your fundraising progress and to thank your supporters. Thank you for your continued support!</p>'>
        
            <cfmail to="#SHPnotificationTO#" from="#SHPnotificationFROM#" subject="#SHPsubject#" type="html" >
            #SHPnotification#
            </cfmail> 

			<!--- Email to ICE organizer(secondary) complete" )> --->
        
        
        </cfif>
	</cfif>
        
        <!--- 3. to R.M. cherie / jessica ... --->
    
    
    <cfcatch type="any">
        
    <cfmail to="csweeting@bcchf.ca" from="error@bcchf.ca" subject="error sending ICE notification emails" type="html">
        Error ICE notification email
        Message: #cfcatch.Message#
        Detail: #cfcatch.Detail#
        <cfdump var="#cfcatch#">
        <cfdump var="#form#" hide="POST_CARD_NUMBER,POST_CVV,FIELDNAMES,POST_DOLLARAMOUNT,js_bcchf_cardnumber,js_bcchf_cvv">
        </cfmail>
        
    </cfcatch>
    </cftry>


    <cfreturn emailOK>

</cffunction>

<!--- Notification Emails WOT --->
<cffunction name="WOTnotifyEmail" access="private" returntype="boolean">

	<cfargument name="pge_UUID" type="string" required="yes">
    
    <cftry>
    <cfset emailOK = 1>
        
    <cfquery name="selectTransaction" datasource="#APPLICATION.DSN.Superhero#">
    SELECT tblGeneral.pge_UUID, tblGeneral.pty_title, tblGeneral.pty_fname, tblGeneral.pty_miname, tblGeneral.pty_lname, tblGeneral.pty_companyname, tblGeneral.ptc_address, tblGeneral.ptc_add_two, tblGeneral.ptc_city, tblGeneral.ptc_prov, tblGeneral.ptc_post, tblGeneral.ptc_email, tblGeneral.ptc_phone, tblGeneral.pty_tax_companyname, tblGeneral.gift, tblGeneral.gift_type, tblGeneral.gift_frequency, tblGeneral.gift_pledge, tblGeneral.gift_pledge_det, tblGeneral.gift_notes, tblGeneral.SupID, tblGeneral.TeamID
    FROM tblGeneral
    WHERE (((tblGeneral.pge_UUID)='#pge_UUID#'));
    </cfquery>
    
    <cfif selectTransaction.SupID NEQ 0>
    
    <cfquery name="selectMember" datasource="#APPLICATION.DSN.Superhero#">
    SELECT SupFName, SupLName, SupEmail, Don_Notify 
    FROM Hero_Members WHERE SuppID = #selectTransaction.SupID#
    </cfquery>
    
    <!--- do not send if the user has disabled notifications --->
	<cfif SelectMember.Don_notify EQ 1 OR SelectMember.Don_notify EQ 'Yes'>
    
    	<cfset SHPnotificationTO = "#SelectMember.SupFName# #SelectMember.SupLName# <#SelectMember.SupEmail#>">
        <cfset SHPnotificationFROM = "BCCHF Wall of Tribute <bcchfds@bcchf.ca>">
        <cfset SHPsubject = "A donation has been made to your Tribute Page">
        <cfset SHPnotification = '<p>#SelectMember.SupFName# #SelectMember.SupLName#</p>
        <p>A donation has been made from #selectTransaction.pty_fname# #selectTransaction.pty_lname# to your Tribute Page. <a href="https://secure.bcchf.ca/SuperHeroPages/login.cfm?Event=WOT">Login here</a> to view donation details and thank your supporters. Thank you for your continued support!</p>'>
        
		<!--- 1. to supporter / team captain --->
        <cfmail to="#SHPnotificationTO#" from="#SHPnotificationFROM#" subject="#SHPsubject#" type="html" failto="csweeting@bcchf.ca" >
        #SHPnotification#
        </cfmail> 
    
    </cfif>
    
    
    
    <!--- 2. to honouree --->
	<!--- 3. NOK --->
    
    <!--- both are team members and not the captain --->
    <!--- lookup 'team' members --->
	<cfquery name="selectWOTmembers" datasource="#APPLICATION.DSN.Superhero#">
    SELECT Hero_Registration.EventTeamID, Hero_Members.SupFName, Hero_Members.SupLName, Hero_Members.SupEmail, Hero_Registration.Reg_MemSuppID, Hero_Registration.SupID, Hero_Members.Don_Notify
    FROM Hero_Registration LEFT JOIN Hero_Members ON Hero_Registration.SupID = Hero_Members.SuppId
    WHERE (((Hero_Registration.EventTeamID)=#selectTransaction.TeamID#));
    </cfquery>
    
    <!--- get the tribute name --->
	<cfquery name="selectTribute" datasource="#APPLICATION.DSN.Superhero#">
	SELECT TeamName, TeamType
	FROM Hero_Team WHERE TeamID = #selectTransaction.TeamID#
	</cfquery>
    
    
    <cfif selectWOTmembers.recordCount NEQ 0>
    <cfloop query="selectWOTmembers">
    <!--- loop team members - exclude captain --->
    <cfif selectWOTmembers.SupID NEQ selectTransaction.SupID>
    
		<cfif selectWOTmembers.Don_Notify NEQ 0>
        
            <cfset SHPnotificationTO = "#selectWOTmembers.SupFName# #selectWOTmembers.SupLName# <#selectWOTmembers.SupEmail#>">
            <cfset SHPnotificationFROM = "BCCHF Wall of Tribute <bcchfds@bcchf.ca>">
            <cfset SHPsubject = "A donation has been made to your Tribute Page">
            <cfset SHPnotification = "<p>#selectWOTmembers.SupFName# #selectWOTmembers.SupLName#</p>
            <p>A donation has been made to BC Children's Hospital Foundation from #selectTransaction.pty_fname# #selectTransaction.pty_lname# #selectTribute.teamType# #selectTribute.TeamName#. </p>">
        
            <cfmail to="#SHPnotificationTO#" from="#SHPnotificationFROM#" subject="#SHPsubject#" type="html" failto="csweeting@bcchf.ca" >
            #SHPnotification#
            </cfmail>
        
        </cfif>
    
    </cfif>
    
    
    </cfloop>
    </cfif>
    
    </cfif>
    
    
    <!--- to organizers --->
	<cfset EventDonNotifySend = 1>
    <cfset EventDonNotifyTo = "jyoung@bcchf.ca">
    <cfset EventDonNotifyCC = "">
        
    <cfmail to="#EventDonNotifyTo#" cc="#EventDonNotifyCC#" from="bcchfds@bcchf.ca" subject="Wall of Tribute Donation Made" type="html" failto="csweeting@bcchf.ca" >
    
    Personal/Corporate: #hiddenDonationPCType#<br>
    Title: #selectTransaction.pty_title#<br>
    Name: #selectTransaction.pty_fname# #selectTransaction.pty_lname#<br>
    Company Name: #selectTransaction.pty_companyname#<br>
    Email: #selectTransaction.ptc_email#<br>
    Address: #selectTransaction.ptc_address#<br>
    Postal Code: #selectTransaction.ptc_post#<br>
    Province: #selectTransaction.ptc_prov#<br>
    City: #selectTransaction.ptc_city#<br>
    Phone: #selectTransaction.ptc_phone#<br>
    Date/Time: #DateFormat(Now(), "DDDD, MMMM DD, YYYY")# #TimeFormat(pty_date, "h:mm:ss tt")#<br>
    Frequency: #selectTransaction.gift_frequency#<br>
    Gift Appeal: #selectTransaction.gift_type#<br>
    Donation: #DollarFormat(selectTransaction.gift)#<br>
    #selectTribute.teamType# #selectTribute.TeamName#
    NOK: #SelectMember.SupFName# #SelectMember.SupLName#
    <br>
    Comments: #selectTransaction.gift_notes#<br />
    Donation: #DollarFormat(selectTransaction.gift)#<br />
    <br />
    </cfmail> 
    
    
    
    
    <cfcatch type="any">
        
    <cfmail to="csweeting@bcchf.ca" from="error@bcchf.ca" subject="error sending WOT notification emails" type="html">
        Error WOT notification email
        Message: #cfcatch.Message#
        Detail: #cfcatch.Detail#
        <cfdump var="#cfcatch#">
        <cfdump var="#form#" hide="POST_CARD_NUMBER,POST_CVV,FIELDNAMES,POST_DOLLARAMOUNT,js_bcchf_cardnumber,js_bcchf_cvv">
        </cfmail>
        
    </cfcatch>
    </cftry>


    <cfreturn emailOK>

</cffunction>

<!--- Notification Emails JeansDay --->
<cffunction name="JeansDayNotifyEmail" access="private" returntype="boolean">

	<cfargument name="pge_UUID" type="string" required="yes">
    
    <cftry>
    <cfset emailOK = 1>
    
    <cfquery name="selectTransaction" datasource="#APPLICATION.DSN.Superhero#">
    SELECT tblGeneral.pge_UUID, tblGeneral.pty_title, tblGeneral.pty_fname, tblGeneral.pty_miname, tblGeneral.pty_lname, tblGeneral.pty_companyname, tblGeneral.ptc_address, tblGeneral.ptc_add_two, tblGeneral.ptc_city, tblGeneral.ptc_prov, tblGeneral.ptc_post, tblGeneral.ptc_email, tblGeneral.ptc_phone, tblGeneral.pty_tax_companyname, tblGeneral.gift, tblGeneral.gift_type, tblGeneral.gift_frequency, tblGeneral.gift_pledge, tblGeneral.gift_pledge_det, tblGeneral.gift_notes, tblGeneral.SupID, tblGeneral.TeamID, tblGeneral.JD_Pin, tblGeneral.JD_Button
    FROM tblGeneral
    WHERE (((tblGeneral.pge_UUID)='#pge_UUID#'));
    </cfquery>
    
    <cfquery name="selectMember" datasource="#APPLICATION.DSN.Superhero#">
    SELECT SupFName, SupLName, SupEmail, Don_Notify 
    FROM Hero_Members WHERE SuppID = #selectTransaction.SupID#
    </cfquery>
    
    <cfquery name="selectBBQ" datasource="#APPLICATION.DSN.Superhero#">
    SELECT JDBBQ
    FROM Hero_DOnate WHERE pge_UUID = '#pge_UUID#'
    </cfquery>
    
    
    <!--- do not send if the user has disabled notifications --->
	<cfif SelectMember.Don_notify EQ 1 OR SelectMember.Don_notify EQ 'Yes'>
    
    	<cfset SHPnotificationTO = "#SelectMember.SupFName# #SelectMember.SupLName# <#SelectMember.SupEmail#>">
		<cfset SHPnotificationFROM = "BCCHF Jeans Day <bcchfds@bcchf.ca>">
        <cfset SHPsubject = "A purchase has been made to your Jeans Day Champion Page">
        <cfset SHPnotification = "<p>#SelectMember.SupFName# #SelectMember.SupLName#</p>">
		<cfset SHPnotification = "#SHPnotification#<p>Congratulations, a purchase ">
        <cfif runnerButton NEQ 0 OR runnerPin NEQ 0>
            <cfset SHPnotification = "#SHPnotification#of ">
            <cfif runnerButton NEQ 0>
                <cfset SHPnotification = "#SHPnotification##runnerButton# Button">
                <cfif runnerButton GT 1>
                    <cfset SHPnotification = "#SHPnotification#s ">
                <cfelse>
                	<cfset SHPnotification = "#SHPnotification# ">
                </cfif>
            </cfif>
            <cfif runnerPin NEQ 0>
                <cfset SHPnotification = "#SHPnotification##runnerPin# Pin">
                <cfif runnerPin GT 1>
                	<cfset SHPnotification = "#SHPnotification#s ">
                <cfelse>
                	<cfset SHPnotification = "#SHPnotification# ">
                </cfif>
            </cfif>
        </cfif>
        <cfset SHPnotification = "#SHPnotification#has been made from #selectTransaction.pty_fname# #selectTransaction.pty_lname# to your Jeans Day Page.">
        <cfset SHPnotification = '#SHPnotification#<a href="https://secure.bcchf.ca/SuperHeroPages/login.cfm?Event=#hiddenEventToken#">Login here</a> to check your fundraising progress and to thank your supporters. Thank you for your continued support!</p>'>
        
    
        <cfmail to="#SHPnotificationTO#" from="#SHPnotificationFROM#" subject="#SHPsubject#" type="html" failto="csweeting@bcchf.ca">
        #SHPnotification#
        </cfmail>
        
	</cfif>
    
    
    <!--- Notification to jeansday@bcchf.ca for general purchases --->
	<cfif selectTransaction.SupID EQ 0 AND selectTransaction.TeamID EQ 0>
        
    <cfmail to="jeansday@bcchf.ca" bcc="csweeting@bcchf.ca" from="jeansday@bcchf.ca" subject="General Jeans Day Purchase Made">
    A general purchase was just made on the Jeans Day page.
    (No Champion Selected)
    Donor Information:
    Received on: #DateFormat(Now(), "DDDD, MMMM DD, YYYY")#
    Name: #selectTransaction.pty_fname# #selectTransaction.pty_lname#
    Company Name: #selectTransaction.pty_companyname#
    Email: #selectTransaction.ptc_email#
    Address: #selectTransaction.ptc_address#
    Postal Code: #selectTransaction.ptc_post#
    Province: #selectTransaction.ptc_prov#
    City: #selectTransaction.ptc_city#
    Phone: #selectTransaction.ptc_phone#
    Gift Type: #selectTransaction.gift_frequency#
    Donation: #selectTransaction.gift#	
    Comments: #selectTransaction.gift_notes#
    
    Pins: #selectTransaction.JD_Pin#
    Buttons: #selectTransaction.JD_Button#
    <cfif selectBBQ.recordCount NEQ 0>
    BBQ Tickets: #selectBBQ.JDBBQ#
    </cfif>
    </cfmail>

	</cfif>
    
    <cfcatch type="any">
        
    <cfmail to="csweeting@bcchf.ca" from="error@bcchf.ca" subject="error sending JeansDay notification emails" type="html">
        Error JeansDay notification email
        Message: #cfcatch.Message#
        Detail: #cfcatch.Detail#
        <cfdump var="#cfcatch#">
        <cfdump var="#form#" hide="POST_CARD_NUMBER,POST_CVV,FIELDNAMES,POST_DOLLARAMOUNT,js_bcchf_cardnumber,js_bcchf_cvv">
        </cfmail>
        
    </cfcatch>
    </cftry>


    <cfreturn emailOK>

</cffunction>

<!--- Notification Emails SHP access="private"--->
<cffunction name="SHPnotifyEmail"  returntype="boolean">

	<cfargument name="pge_UUID" type="string" required="yes">
    
    <cftry>
    <cfset emailOK = 1>
    
    <cfquery name="selectTransaction" datasource="#APPLICATION.DSN.Superhero#">
    SELECT tblGeneral.pge_UUID, tblGeneral.pty_title, tblGeneral.pty_fname, tblGeneral.pty_miname, tblGeneral.pty_lname, tblGeneral.pty_companyname, tblGeneral.ptc_address, tblGeneral.ptc_add_two, tblGeneral.ptc_city, tblGeneral.ptc_prov, tblGeneral.ptc_post, tblGeneral.ptc_email, tblGeneral.ptc_phone, tblGeneral.pty_tax_companyname, tblGeneral.gift, tblGeneral.gift_type, tblGeneral.gift_frequency, tblGeneral.gift_pledge, tblGeneral.gift_pledge_det, tblGeneral.gift_notes, tblGeneral.SupID, tblGeneral.TeamID
    FROM tblGeneral
    WHERE (((tblGeneral.pge_UUID)='#pge_UUID#'));
    </cfquery>
    
    <cfquery name="selectMember" datasource="#APPLICATION.DSN.Superhero#">
    SELECT SupFName, SupLName, SupEmail, Don_Notify 
    FROM Hero_Members WHERE SuppID = #selectTransaction.SupID#
    </cfquery>
    
    <!--- get the event name and necessary emails --->
    <cfquery name="selectEventName" datasource="#APPLICATION.DSN.Superhero#">
    SELECT Event_Name, Staff_email, Event_Email, Don_Notify, 
    Don_cc, EventCurrentYear
    FROM Hero_Event WHERE Event = '#selectTransaction.gift_type#'
    </cfquery>

    <!--- registration record --->
    <cfquery name="selectReg" datasource="#APPLICATION.DSN.Superhero#">
    SELECT EventFundGoal 
    FROM Hero_Registration WHERE SupID = #selectTransaction.SupID#
    AND RegEvent = '#selectTransaction.gift_type#'
    AND RegYear = #selectEventName.EventCurrentYear# 
    </cfquery>
    
    
	<!--- Total Donations For This participant --->
    <CFQUERY name="selectDonation" datasource="#APPLICATION.DSN.Superhero#">
    SELECT Sum(Hero_Donate.Amount) AS sumAmount, SupID 
    FROM Hero_Donate 
    WHERE SupID = #selectTransaction.SupID# 
        AND Campaign = #selectEventName.EventCurrentYear# 
        AND Event = '#selectTransaction.gift_type#' 
        AND TeamID = #selectTransaction.TeamID#
    GROUP BY SupID
    </CFQUERY>
    
    <cfif selectDonation.sumAmount EQ ''>
        <cfset TotalRaised = 0>
    <cfelse>
        <cfset TotalRaised = selectDonation.sumAmount>
    </cfif>
    
    <cfif selectTransaction.SupID NEQ 0>
    
		<cfset PerOfTotal = 0>
        <cfif selectReg.EventFundGoal NEQ 0>
        
            <cfset PerOfTotal = Int((TotalRaised / selectReg.EventFundGoal) * 100)>
        
        </cfif>
        
        <cfif PerOfTotal GT 100>
            <cfset PerOfTotal = 100>
        </cfif>
        
        <cfset DonNotEmailTemplate = 'DonNotify'>
        <cfset DonNotEmailSubject = 'A donation has been made to your Superhero Page'>
        
        
        <cfif selectTransaction.gift_type EQ 'ChildRun'
            AND selectTransaction.teamID EQ 9157
            AND TotalRaised GT 99.99>
        
            <!--- Custom ChildRun Feature for RBC match --->
            <!--- if donation is on TeamID 9157
                AND this donation has put this participant over $100
                
                INSERT additional $50 in support of this participant
                --->
             
            <!--- ensure an RBC matching donation has not yet been added in this account --->
            <CFQUERY name="selectRBCpledge" datasource="bcchf_Superhero">
            SELECT Amount
            FROM Hero_Donate 
            WHERE SupID = #selectTransaction.SupID# 
                AND Campaign = #selectEventName.EventCurrentYear# 
                AND Event = '#selectTransaction.gift_type#' 
                AND TeamID = #selectTransaction.TeamID#
                AND Gift_Type = 'Pledge'
                AND DonCompany = 'RBC'
                AND Amount = 50
            </CFQUERY>
            
           
            
            <cfif selectRBCpledge.recordCount EQ 0>
            <!---- insert pledge --->
            
                <cfset variables.newpledgeUUID=createUUID()>
            
                <cfquery name="insertHeroDonation" datasource="#APPLICATION.DSN.Superhero#">
                INSERT INTO Hero_Donate (Event, Campaign, TeamID, Name, Type, Message, Show, DonTitle, DonFName, DonLName, DonCompany, Email, don_date, Amount, SupID, JDPins, JDButtons, Env_Notes, pge_UUID, AddDate, UserAdd, LastChange, LastUser, dtnSource, Gift_Type) 
                VALUES ('#selectTransaction.gift_type#', 
                    #selectEventName.EventCurrentYear#, 
                    #selectTransaction.TeamID#, 
                    'RBC', 
                    'in Support of', 
                    '#selectMember.SupFName# #selectMember.SupLName#', 
                    0, 
                    '', 
                    '',
                    '',  
                    'RBC', 
                    '', 
                    #CreateODBCDatetime(Now())#, 
                    50, 
                    #selectTransaction.SupID#, 
                    0, 
                    0, 
                    'RBC Auto Match',
                    '#variables.newpledgeUUID#', 
                    #CreateODBCDatetime(Now())#,
                    'Online', 
                    #CreateODBCDatetime(Now())#,
                    'Online',
                    'ChildRun Auto Match',
                    'Pledge')
                </cfquery>
            
            
            </cfif>
    
        </cfif>
        
        
        
        
        
        <!--- do not send if the user has disabled notifications --->
        <cfif SelectMember.Don_notify EQ 1 OR SelectMember.Don_notify EQ 'Yes'>
            
            
            
            
                    <!--- For ChildRun - 
                Determine the appropriate donation notification message
                If we are achieving the 100% goal mark ---
                    if we are over 1,000k goal
                    if we are under 1,000k goal
                if we are achieving the 75% goal mark ---
                if we are achieving the 50% goal mark ---
                if we are achieving the 25% goal mark ---
                no special achievement --->
    
            <cfif selectTransaction.gift_type EQ 'ChildRun'
				OR selectTransaction.gift_type EQ 'RFTK'>
            
            
                <cfif PerOfTotal EQ 100>
                <!--- goal reached --->
                    <cfset DonNotEmailTemplate = 'Goal100NotLT'>
                    
                    <!--- 2015 - no conditional 100% goal
						2016 - re-add this conditional. --->
                    <cfif selectReg.EventFundGoal GT 999.99>
                        <cfset DonNotEmailTemplate = 'Goal100NotGT'>
                    <cfelse>
                        <cfset DonNotEmailTemplate = 'Goal100NotLT'>
                    </cfif>
                    
                <cfelseif PerOfTotal GT 74>
                    <cfset DonNotEmailTemplate = 'Goal75Not'> 
                    
                <cfelseif PerOfTotal GT 49>
                    <cfset DonNotEmailTemplate = 'Goal50Not'>
                     
                <cfelseif PerOfTotal GT 24>
                    <cfset DonNotEmailTemplate = 'Goal25Not'>
                     
                <cfelse>
                    <cfset DonNotEmailTemplate = 'DonNotify'> 
                    
                </cfif> 
            
            
            <cfelseif selectTransaction.gift_type EQ 'SloPitch'>
            
                <cfif TotalRaised GT 499.99>
                    <cfset DonNotEmailTemplate = 'Goal500Not'>
                    <cfset DonNotEmailSubject = 'Congratulations - you are now an elite Slo-Pitch Ledcor Challenger '>
                    
                <cfelseif TotalRaised GT 249.99>
                    <cfset DonNotEmailTemplate = 'Goal300Not'>
                    <cfset DonNotEmailSubject = 'Keep up the great work - you are almost a Slo-Pitch Ledcor Challenger'>
                    
                <cfelse>
                    <cfset DonNotEmailTemplate = 'DonNotify'> 
                    <cfset DonNotEmailSubject = 'A donation has been made to your Superhero Page'>
                    
                </cfif>
                
            </cfif>
            <!--- donation template determined --->
            
            <!--- Check that this user has not already recieved one of the goal notificatin is this is the case --->
            <cfif DonNotEmailTemplate NEQ 'DonNotify'>
                    
            
            <cfquery name="GetSHPEmail" datasource="bcchf_SuperHero">
            SELECT EmSHPName, EmMetaData FROM Hero_Email_SupRecieved 
            WHERE SupID = #selectTransaction.SupID#
                AND EmSHPName = '#DonNotEmailTemplate#'
                AND HeroEventCampaign =  #selectEventName.EventCurrentYear#
                AND HeroEventToken = '#selectTransaction.gift_type#'
            </cfquery>
            
            
            <cfif GetSHPEmail.recordCount EQ 0>
                <cfset DonNotEmailTemplate = DonNotEmailTemplate>
            
            <cfelse>
            <!--- need to parse out meta data and check if we are at the same goal --->
            <!--- check if we have sent this notification to this user at this goal --->
            <cfset DonNotEmailTemplate = DonNotEmailTemplate>
            
            <cfif selectTransaction.gift_type EQ 'ChildRun'
				OR selectTransaction.gift_type EQ 'RFTK'>
            
                <cfloop query="GetSHPEmail">
                    
                    <cfset EmailData = DeserializeJSON(EmMetaData)>
                    
                    <cfif IsDefined('EmailData.SUPGOAL')>
                    <cfif EmailData.SUPGOAL EQ selectReg.EventFundGoal>
                    <!--- user has recieved this email at this goal already --->
                        <cfset DonNotEmailTemplate = 'DonNotify'>
                    </cfif>
                    </cfif>
                
                </cfloop>
            
            <cfelseif hiddenEventToken EQ 'SloPitch'>
            
                <cfset DonNotEmailTemplate = 'DonNotify'><!---  --->
            
            </cfif>
            
            </cfif>
            
            </cfif>
            
            <!--- lookup notification text --->
            <cfquery name="ConstructEventDonNotificationTemplate" datasource="#APPLICATION.DSN.Superhero#">
            SELECT TextApprovedBody FROM Hero_EventText 
            WHERE Event = '#selectTransaction.gift_type#' AND TextName = '#DonNotEmailTemplate#'
            </cfquery>
            
            
            <cfquery name="ConstructEventDonNotification" datasource="#APPLICATION.DSN.Superhero#">
            SELECT TextApprovedBody FROM Hero_EventText 
            WHERE Event = '#selectTransaction.gift_type#' AND TextName = 'DonNotify'
            </cfquery>
            
            
            
            <cfset emailUUID=createUUID()>
            <cfset emailMeta= {ToAdd = SelectMember.SupEmail,
                ToName = '#SelectMember.SupFName# #SelectMember.SupLName#',
                FromAdd = 'bcchfds@bcchf.ca',
                FromName = 'BCCHF Superhero Pages',
                Subject = DonNotEmailSubject,
                Body = '',
                EmailType = DonNotEmailTemplate,
                SupRaised = TotalRaised,
                SupGoal = selectReg.EventFundGoal
                }
                />
            
            <cfset emailMetaJSON = SerializeJSON(emailMeta)>
            
            
            
            <cfif selectTransaction.gift_type EQ 'ChildRun' 
				OR selectTransaction.gift_type EQ 'RFTK'
				OR selectTransaction.gift_type EQ 'SloPitch'>
            
            <cfset supNotifyEmail = sendNotifyEm(selectTransaction.SupID, 'bcchfds', emailMeta.Subject, emailMeta.EmailType, selectTransaction.gift_type, pge_UUID)>
            
            <cfelse>
            
            
            <!--- Send notification email to supporter --->
            <cfset supNotifyEmail = sendNotifyEm(selectTransaction.SupID, 'bcchfds', emailMeta.Subject, emailMeta.EmailType, selectTransaction.gift_type, pge_UUID)>
            
            </cfif>
    
        </cfif>
    </cfif>
    
    
    
    
    <!--- 2. to the team captain, 
		when the team captain is not the supporter above--->
	<cfif selectTransaction.TeamID NEQ 0>
        
        <cfquery name="selectTeam" datasource="#APPLICATION.DSN.Superhero#">
        SELECT Hero_Team.TeamID, Hero_Team.TeamName, Hero_Team.Lead_DonNot, Hero_Team.TeamGoal, Hero_Members.SupFName, Hero_Members.SupLName, Hero_Members.SupEmail, Hero_Members.SuppID, Hero_Team.TeamLeadID
        FROM Hero_Team LEFT JOIN Hero_Members ON Hero_Team.TeamLeadID = Hero_Members.SuppId
        WHERE (((Hero_Team.TeamID)=#selectTransaction.TeamID#));
        </cfquery>
        
        
        
		<cfif (selectTeam.Lead_DonNot EQ 1 OR selectTeam.Lead_DonNot EQ 'Yes') 
			AND selectTeam.SuppID NEQ selectTransaction.SupID
			AND SelectTeam.SupEmail NEQ ''
			AND selectTeam.SuppID NEQ 0
			AND selectTeam.SuppID NEQ 1>
        <!---   --->
        
			<!--- team total raised --->
            <CFQUERY name="selectDonation" datasource="#APPLICATION.DSN.Superhero#">
            SELECT Sum(Hero_Donate.Amount) AS sumAmount, TeamID 
            FROM Hero_Donate 
            WHERE TeamID = #selectTransaction.TeamID# 
                AND Campaign = #selectEventName.EventCurrentYear# 
                AND Event = '#selectTransaction.gift_type#' 
            GROUP BY TeamID
            </CFQUERY>
            
            <!--- calculate percentage --->
            <cfif selectDonation.Recordcount EQ 0>
                <cfset TotalRaised = 0>
            <cfelse>
                <cfset TotalRaised = selectDonation.sumAmount>
            </cfif>
            
            
            <cfset PerOfTotal = 0>
            
            <cfif selectTeam.TeamGoal NEQ 0>
				<cfset PerOfTotal = Int((TotalRaised / selectTeam.TeamGoal) * 100)>
            </cfif>
        
			<cfif PerOfTotal GT 100>
                <cfset PerOfTotal = 100>
            </cfif>
            
            <cfset DonNotEmailTemplate = 'DonTNotify'>
            <cfset DonNotEmailSubject = 'A donation has been made to your Team Page'>
            
            <cfif selectTransaction.gift_type EQ 'ChildRun'
				OR selectTransaction.gift_type EQ 'RFTK'>
            
				<cfif PerOfTotal EQ 100>
            		<!--- goal reached --->
            		<cfset DonNotEmailTemplate = 'TGoal100Not'>
                                
				<cfelseif PerOfTotal GT 74>
                    <cfset DonNotEmailTemplate = 'TGoal75Not'> 
                    
                <cfelseif PerOfTotal GT 49>
                    <cfset DonNotEmailTemplate = 'TGoal50Not'>
                     
                <cfelseif PerOfTotal GT 24>
                    <cfset DonNotEmailTemplate = 'TGoal25Not'>
                     
                <cfelse>
                    <cfset DonNotEmailTemplate = 'DonTNotify'> 
                    
                </cfif> 
                
            </cfif>
            <!--- donation template determined --->
        
			<!--- Check that this user has not already recieved one of the goal notificatin is this is the case --->
            <cfif DonNotEmailTemplate NEQ 'DonTNotify'>
                
        
                <cfquery name="GetSHPEmail" datasource="bcchf_SuperHero">
                SELECT EmSHPName, EmMetaData FROM Hero_Email_SupRecieved 
                WHERE SupID = #selectTeam.SuppID#
                    AND EmSHPName = '#DonNotEmailTemplate#'
                    AND HeroEventCampaign =  #selectEventName.EventCurrentYear#
                    AND HeroEventToken = '#selectTransaction.gift_type#'
                </cfquery>
            
            
                <cfif GetSHPEmail.recordCount EQ 0>
                    <cfset DonNotEmailTemplate = DonNotEmailTemplate>
                
                <cfelse>
                    <!--- need to parse out meta data and check if we are at the same goal --->
                    <!--- check if we have sent this notification to this user at this goal --->
                    <cfset DonNotEmailTemplate = DonNotEmailTemplate>
                    
                    <cfif selectTransaction.gift_type EQ 'ChildRun'
						OR selectTransaction.gift_type EQ 'RFTK'>
            
                        <cfloop query="GetSHPEmail">
                        
                        <cfset EmailData = DeserializeJSON(EmMetaData)>
                        
                        <cfif IsDefined('EmailData.SUPGOAL')>
                        <cfif EmailData.SUPGOAL EQ selectTeam.TeamGoal>
                        <!--- user has recieved this email at this goal already --->
                            <cfset DonNotEmailTemplate = 'DonTNotify'>
                        </cfif>
                        </cfif>
                    
                        </cfloop>
                        
                    </cfif>
                    
                </cfif>
            
            </cfif>
            
            
            <cfset SHPnotificationTO = "#SelectTeam.SupFName# #SelectTeam.SupLName# <#SelectTeam.SupEmail#>">
            
            <!--- lookup notification text --->
            <cfquery name="ConstructEventDonNotificationTemplate" datasource="#APPLICATION.DSN.Superhero#">
            SELECT TextApprovedBody FROM Hero_EventText 
            WHERE Event = '#selectTransaction.gift_type#' AND TextName = '#DonNotEmailTemplate#'
            </cfquery>
        
			<cfset emailUUID=createUUID()>
            <cfset emailMeta= {ToAdd = SelectTeam.SupEmail,
                ToName = '#SelectTeam.SupFName# #SelectTeam.SupLName#',
                FromAdd = 'bcchfds@bcchf.ca',
                FromName = 'BCCHF Superhero Pages',
                Subject = DonNotEmailSubject,
                Body = '',
                EmailType = DonNotEmailTemplate,
                SupRaised = TotalRaised,
                SupGoal = selectTeam.TeamGoal
                }
                />
            
            <cfset emailMetaJSON = SerializeJSON(emailMeta)>
            
            <!--- send the email --->
            
        
			
            
            <cfif selectTransaction.gift_type EQ 'ChildRun'
				OR selectTransaction.gift_type EQ 'RFTK'>
            
            <cfset supNotifyEmail = sendNotifyEm(selectTeam.SuppID, 'bcchfds', emailMeta.Subject, emailMeta.EmailType, selectTransaction.gift_type, pge_UUID)>
                        
            <cfelse>
            
            
            
                <cfmail to="#SHPnotificationTO#" failto="csweeting@bcchf.ca" from="BCCHF Superhero Pages <bcchfds@bcchf.ca>" subject="#DonNotEmailSubject#" type="html">
                <p>#SelectTeam.SupFName# #SelectTeam.SupLName#</p>
                
                <p>Congratulations, a #DollarFormat(selectTransaction.gift)# donation has been made from #selectTransaction.pty_fname# #selectTransaction.pty_lname# to your #selectTeam.TeamName# Team Page in support of #SelectMember.SupFName# #SelectMember.SupLName#. <a href="https://secure.bcchf.ca/SuperHeroPages/login.cfm?Event=#selectTransaction.gift_type#">Login here</a> to check your fundraising progress and to thank your supporters. Thank you for your continued support!</p>
                </cfmail>
			
			</cfif>
        
        
		</cfif>
	</cfif>
    
    
    <!--- 3 to organizers --->
        <cfif selectEventName.Don_notify EQ 1 AND selectEventName.Don_cc EQ 1>
        	<cfset EventDonNotifySend = 1>
        	<cfset EventDonNotifyTo = selectEventName.Staff_email>
            <cfset EventDonNotifyCC = selectEventName.Event_Email>
        <cfelseif selectEventName.Don_notify EQ 1 AND selectEventName.Don_cc EQ 0>
        	<cfset EventDonNotifySend = 1>
        	<cfset EventDonNotifyTo = selectEventName.Staff_email>
            <cfset EventDonNotifyCC = ''>
        <cfelseif selectEventName.Don_notify EQ 0 AND selectEventName.Don_cc EQ 1>
        	<cfset EventDonNotifySend = 1>
        	<cfset EventDonNotifyTo = selectEventName.Event_Email>
            <cfset EventDonNotifyCC = ''>
        
        <cfelse>
        	<cfset EventDonNotifySend = 0>
        	<cfset EventDonNotifyTo = ''>
            <cfset EventDonNotifyCC = ''>
        </cfif>
        
        
        <!--- FOT Custom Notifications --->
        <!--- Notify Debbie if this is an island donations
			Thats TeamID 4211 4212 4213--->
        <cfif selectTransaction.gift_type EQ 'FOT' 
			AND (selectTransaction.TeamID EQ 4211 OR selectTransaction.TeamID EQ 4212 OR selectTransaction.TeamID EQ 4213)>
        	<cfset EventDonNotifySend = 1>
        	<cfset EventDonNotifyTo = 'dfullwood@bcchf.ca'>
            <cfset EventDonNotifyCC = ''>
        </cfif> 
        
        <cfif EventDonNotifySend EQ 1>
        
        <cfset subject = "#selectEventName.Event_Name# Donation Made">
        
        <cfif selectTransaction.gift_type EQ 'Mining'
			AND selectTransaction.SupID EQ 0
			AND selectTransaction.TeamID EQ 0>
            
            <cfset subject = "Mining for Miracles Donation Made">
            
        <cfelse>
        </cfif>
        
    <cfmail to="#EventDonNotifyTo#" cc="#EventDonNotifyCC#" from="bcchfds@bcchf.ca" subject="#subject#" type="html" failto="csweeting@bcchf.ca">
    
    Title: #selectTransaction.pty_title#<br>
    Name: #selectTransaction.pty_fname# #selectTransaction.pty_lname#<br>
    Company Name: #selectTransaction.pty_companyname#<br>
    Email: #selectTransaction.ptc_email#<br>
    Address: #selectTransaction.ptc_address#<br>
    Postal Code: #selectTransaction.ptc_post#<br>
    Province: #selectTransaction.ptc_prov#<br>
    City: #selectTransaction.ptc_city#<br>
    Phone: #selectTransaction.ptc_phone#<br>
    Date/Time: #DateFormat(Now(), "DDDD, MMMM DD, YYYY")#<br>
    Frequency: #selectTransaction.gift_frequency#<br>
    Gift Appeal: #selectTransaction.gift_type#<br>
    Donation: #DollarFormat(selectTransaction.gift)#<br>
    <cfif selectTransaction.SupID NEQ 0>
    Supporting: #SelectMember.SupFName# #SelectMember.SupLName#<br>
    </cfif>
    <cfif selectTransaction.TeamID NEQ 0>
    Supporting Team: #selectTeam.TeamName#<br>
    </cfif>
    
    </cfmail>  
            
        <!--- Set a marker ---
		<cfset frapi.trace( "Email to SHP event organizer complete" )>--->
        
        </cfif>
    
    
    
    <cfcatch type="any">
        
    <cfmail to="csweeting@bcchf.ca" from="error@bcchf.ca" subject="error sending SHP notification emails" type="html">
        Error SHP notification email
        Message: #cfcatch.Message#
        Detail: #cfcatch.Detail#
        <cfdump var="#cfcatch#">
        </cfmail>
        
    </cfcatch>
    </cftry>


    <cfreturn emailOK>

</cffunction>



<!---  --->
<cffunction name="recordLegacyGiftInfo" access="remote" returntype="boolean">

	<cfargument name="sUUID" type="string" required="yes">
    
    <cfif IsDefined('bcchf_will')>
    	<cfset willInclude = 'included in will'>
    <cfelse>
    	<cfset willInclude = ''>
    </cfif>
    
    	
    
    <cfif IsDefined('bcchf_send_info')>
    	<cfset willInfo = 'will'>
    <cfelse>
    	<cfset willInfo = ''>
    </cfif>
    	
	<cftry>
      
	<cfset adInfo = {
          iWill = willInfo,
          iWillInclude = willInclude
      } />
      
      <cfset addInfo = SerializeJSON(adInfo)>
      
      <cfset tSSUCadd = recordSuccAdd(addInfo, sUUID)>
      
      
      <!--- DEPRECIATE add additional information section --->
      <cfquery name="updateAddInfo" datasource="#APPLICATION.DSN.general#">
      UPDATE tblGeneral
      SET info_will = '#willInfo#', 
          info_willinclude = '#willInclude#'
      WHERE pge_UUID = '#sUUID#'
      </cfquery>
      
	<cfcatch type="any">
	</cfcatch>
	</cftry>
	
	<cfset surveyComplete = 1>
    <cfreturn surveyComplete>


</cffunction>

<!---  --->
<cffunction name="recordTributeGiftInfo" access="remote" returntype="boolean">

	<cfargument name="tUUID" type="string" required="yes">
    
    <!--- tribute information --->
    <cftry>
        
        <cfset cleanTrbMessage = bcchf_acknowledgement_msg>
        
        <cfset tribInfo = {
				trbFname = '',
				trbLname = bcchf_in_memory,
				trbEmail = bcchf_email,
				trbAddress = bcchf_address,
				trbAddTwo = bcchf_address2,
				trbCity = bcchf_city,
				trbProv = bcchf_province,
				trbPost = bcchf_postal_code,
				trbCountry = bcchf_country,
				srpFname = bcchf_first_name,
				srpLname = bcchf_last_name,
				trbCardfrom = bcchf_sign,
				trbMsg = cleanTrbMessage,
				tribNotes = hiddenTributeType,
				cardSend = bcchf_send_card
				
			} />
            
            <cfset tribInfoJSON = SerializeJSON(tribInfo)>
            
            <!--- <cfset tSSUCtrib = recordSuccTrib(tribInfoJSON, tUUID)> --->
            
            
        
        <!--- DEPRECIATE update tblGeneral with tribute data --->
        <cfquery name="updateTributeData" datasource="#APPLICATION.DSN.general#">
        UPDATE tblGeneral
        SET	gift_tribute = 'yes',
        	trb_fname = '',
        	trb_lname = '#bcchf_in_memory#', 
            <cfif bcchf_send_card EQ 'email'>
            trb_email = '#bcchf_email#', 
            <cfelseif bcchf_send_card EQ 'mail'>
            trb_address = '#bcchf_address#',
            <!--- trb_address two ?? --->
            trb_city = '#bcchf_city#',
            trb_prov = '#bcchf_province#', 
            trb_postal = '#bcchf_postal_code#',
            </cfif> 
            srp_fname = '#bcchf_first_name#', 
            srp_lname = '#bcchf_last_name#', 
            trb_cardfrom = '#bcchf_sign#', 
            trb_msg = '#cleanTrbMessage#', 
            trib_notes = '#hiddenTributeType#',
            card_send = '#bcchf_send_card#'
        WHERE pge_UUID = '#tUUID#'
        </cfquery>
        
        <!--- Send tribute email ---->
            <cfif bcchf_send_card EQ 'email'>
        
        		<cfset TribAwkEmail = TribAwkEmail(tUUID)>
        
        	</cfif>
        

    <cfcatch type="any">
    </cfcatch>
    </cftry>
    
	<cfset tribComplete = 1>
    <cfreturn tribComplete>

</cffunction>


<!--- 2012-09-10 Blocking MO of fradulent transactions --->
<cffunction name="checkFraudsterMO" access="private" returntype="boolean">

	<!--- taking in name variables --->
	<cfargument name="pty_tax_fname" type="string" required="yes">
    <cfargument name="pty_tax_lname" type="string" required="yes">
    
    <cfargument name="pty_fname" type="string" required="yes">
    <cfargument name="pty_lname" type="string" required="yes">
    
    <cfargument name="ptc_email" type="string" required="yes">
    
    <cfargument name="ptc_country" type="string" required="yes">
    <cfargument name="gift_frequency" type="string" required="yes">
    <cfargument name="post_dollaramount" type="string" required="yes">
    
    <!--- check for MO --->
    <cfif (pty_tax_fname EQ 'Octavius' OR pty_fname EQ 'Octavius') 
		AND (pty_tax_lname EQ 'Robinson' OR pty_lname EQ 'Robinson')
		AND ptc_email EQ 'taye012004@yahoo.com'
		><!---  --->
    
    	<!--- MO blocked - ABORT --->
        <cfset fradulent = 1>
        <!--- Set a marker ---
		<cfset frapi.trace( "MO Blocked; ABORTING" )>--->
    
    <cfelse>
    
    	<!--- 2015 MO Blocking --->
        <cfif (ptc_country EQ 'brasil'
			OR ptc_country EQ 'uruguai'
			OR ptc_country EQ 'Argentina')
			AND gift_frequency EQ 'monthly'
			AND post_dollaramount LT 10>
            
            <cfset fradulent = 1>
            
        <cfelse>
    	
			<!--- all good --->    
            <cfset fradulent = 0>
            
        </cfif>
    
    </cfif>
    
    <!--- check for MO --->
    <cfif (pty_tax_fname EQ 'Mark') 
		AND (pty_tax_lname EQ 'Zuckerberg')
		AND ptc_email EQ 'mark@facebook.com'
		><!---  --->
    
    	<!--- MO blocked - ABORT --->
        <cfset fradulent = 1>
        <!--- Set a marker ---
		<cfset frapi.trace( "MO Blocked; ABORTING" )>--->
	</cfif>
    
    <!--- check for MO --->
    <cfif (pty_tax_fname EQ 'Mark') 
		AND (pty_tax_lname EQ 'Zucker')
		AND ptc_email EQ 'mzuck@fb.com'
		><!---  --->
    
    	<!--- MO blocked - ABORT --->
        <cfset fradulent = 1>
        <!--- Set a marker ---
		<cfset frapi.trace( "MO Blocked; ABORTING" )>--->
	</cfif>
    
    <!--- check for MO --->
    <cfif (pty_tax_fname EQ 'jams') 
		AND (pty_tax_lname EQ 'mad')
		AND ptc_email EQ 'jams.mad@gmail.com'
		><!---  --->
    
    	<!--- MO blocked - ABORT --->
        <cfset fradulent = 1>
        <!--- Set a marker ---
		<cfset frapi.trace( "MO Blocked; ABORTING" )>--->
	</cfif>
    
    <!--- check for MO --->
    <cfif ptc_email EQ 'daraerik8@gmail.com'><!---  --->
    
    	<!--- MO blocked - ABORT --->
        <cfset fradulent = 1>
        <!--- Set a marker ---
		<cfset frapi.trace( "MO Blocked; ABORTING" )>--->
	</cfif>
    
     <!--- check for MO --->
    <cfif (pty_tax_fname EQ 'Tester') ><!---  --->
    
    	<!--- MO blocked - ABORT --->
        <cfset fradulent = 1>
        <!--- Set a marker ---
		<cfset frapi.trace( "MO Blocked; ABORTING" )>--->
	</cfif>
    
    
	<cfreturn fradulent>

</cffunction>


<!--- onPanel MMP Processor - Credit Cards --->
<cffunction name="onPanelMMPcard" access="remote">
    
    <cfargument name="EventToken" type="string" required="yes">
    <cfargument name="SupporterID" type="numeric" required="yes">
    <cfargument name="TeamID" type="numeric" required="yes">
	<cfargument name="payMethod" type="string" required="no">
    <cfargument name="donation" type="numeric" required="yes">
    
    
    <!--- cardholder data --->
    <cfargument name="post_card_number" type="string" required="no">
    <cfargument name="post_expiry_date" type="string" required="no">
    <cfargument name="post_cardholdersname" type="string" required="no">
    <cfargument name="post_CVV" type="string" required="no">

	<!--- ---------------------------- start of processing  -------------------------------------------- --->
    <!--- SERVER Date at submission --->
    <cfif NOT IsDefined("pty_date")><cfset pty_date= "#Now()#"></cfif>
    
    <!--- create UUID to access info --->
    <cfset variables.newUUID=createUUID()>
    <!--- collect IP address of remote requestor --->
	<cfset newIP = CGI.REMOTE_ADDR>
	<cfset newBrowser = CGI.HTTP_USER_AGENT>
    <cfset ipBlocker = 0>
    
    <!--- set transaction amount --->
    <cfset hiddenGiftAmount = REREPlace(donation, '[^0-9.]','','all')>
    <cfset post_dollaramount = donation>
    
    <!--- default setting is YES for adding to hero donate ---> 
    <cfset HeroDonateAdd = 1>
    <cfset SupID = SupporterID>
    <cfset TeamID = TeamID>
    
    <!--- successful variables --->
    <cfset chargeSuccess = 0>
    <cfset donationSuccess = 0>
    <cfset chargeAttempt = 0>
    <cfset chargeAproved = 0>
    <cfset chargeMSG = "">
    <cfset tGenTwoID = 0>
    
    <!--- construct return message --->
    <cfset returnSuccess = 0>
    <cfset returnMSG = 'beginAttempt'>
    <cfset exact_respCode = 0>
    
    <cfset pty_subscr_r = 0>
    
    <!--- trim name vars --->
    <cfset pty_tax_fname = TRIM(fname)>
	<cfset pty_tax_lname = TRIM(lname)>
    <cfset pty_tax = 'yes'>
    
    <!--- set gift type on form pre load --->
    <cfset gift_type = '#EventToken#'>
    
    <cfif EventToken EQ 'MMP'>
    
    	<cfset gift_frequency = 'Single'>
    
    <cfelse>
    
    	<cfset gift_frequency = 'Single - No Receipt'>
    
    </cfif>
    
    
	<cfset gift_day = "">
    <cfset gift_notes = "">
        
	<!--- set source --->
	<cfset donation_source = 'MMP 2015 OnPanel Form'>
    
    <cfset donEmailTemplate = 'DonEmail'>
	
    
    <!--- scrub some variables for db loading --->
    <cftry>
    
    
    	<!--- we have event information -- query for donation confirmation text --->
        <cfquery name="ConstructEventYear" datasource="#APPLICATION.DSN.Superhero#">
        SELECT EventCurrentYear FROM Hero_Event
        WHERE Event = '#EventToken#'
        </cfquery>
		
		<!--- we have event information -- query for donation confirmation text --->
        <cfquery name="ConstructEventDonText" datasource="#APPLICATION.DSN.Superhero#">
        SELECT TextApprovedBody FROM Hero_EventText 
        WHERE Event = '#EventToken#' AND TextName = '#donEmailTemplate#'
        </cfquery>
        
        <!--- get the supporter name and email --->
        <cfquery name="selectMember" datasource="#APPLICATION.DSN.Superhero#">
        SELECT SupFName, SupLName, SupEmail, Don_Notify 
        FROM Hero_Members WHERE SuppID = #SupID#
        </cfquery>
                
        <!--- get the event name and necessary emails --->
        <cfquery name="selectEventName" datasource="#APPLICATION.DSN.Superhero#">
        SELECT Event_Name, Staff_email, Event_Email, Don_Notify, 
        Don_cc, EventCurrentYear
        FROM Hero_Event WHERE Event = '#EventToken#'
        </cfquery>
        
        <!--- update the confirmation texts --->
        <cfset emailConfirmationText = ConstructEventDonText.TextApprovedBody>
        <cfset emailConfirmationEvent = ' to the #selectEventName.Event_Name#'>
        <cfset emailConfirmationSupporting = '#selectMember.SupFName# #selectMember.SupLName#'>
        <cfset Message = '#selectMember.SupFName# #selectMember.SupLName#'>

    	<!--- TAX receipt options for processor ---->
        <!--- use receipt type for Ink/No Ink --->
        <!--- TODO: HK receipting options --->
        <!--- receipt types
			TAX = TAX RECEIPT
			AWK = AWKNOWLEDGMENT RECEIPT
			TAX-HK = Hong Kong 
			TAX-IF = Ink Friendly
			TAX-ANNUAL = Annual Receipt for monthly gift
			TAX-HK-ANNUAL = Annual Receipt for monthly gift on HK page
			NONE = None requested / ineligible
			--->
		
        
		<cfif gift_frequency EQ 'single'>
            <cfif pty_tax EQ "no">
                <cfset receipt_type = 'NONE'>
            <cfelse>
                <cfif IsDefined('pty_ink')>
                    <cfif pty_ink EQ 'yes'>
                        <cfset receipt_type = 'TAX-IF'>
                    <cfelse>
                        <cfset receipt_type = 'TAX'>
                    </cfif>
                <cfelse>
                    <cfset receipt_type = 'TAX'>
                </cfif>
            </cfif>
        <cfelse>
            <cfif pty_tax EQ "no">
                <cfset receipt_type = 'NONE'>
            <cfelse>
                <cfset receipt_type = 'TAX-ANNUAL'>
            </cfif>        
        </cfif>
        
    	<!--- legacy: receipt generator method
			- check for receipt status 
			- append 'no receipt' to frequency for no receipt--->
        <cfif pty_tax EQ "no">
			<cfset gift_frequency="#gift_frequency# - No Receipt">
        <cfelse>
        	<cfset gift_frequency="#gift_frequency#">
        </cfif>
        
        <cfif gift_frequency EQ 'single'>
        	<cfset gift_frequency = 'Single'>
        </cfif>
    
        
        <!--- add to Hero_Donate AMount --->
        <cfif gift_frequency EQ 'monthly'>
			<cfset Hero_Donate_Amount = post_dollaramount * 12>
        <cfelse>
            <cfset Hero_Donate_Amount = post_dollaramount>
        </Cfif> 
        
        <!--- TYS options --->
        <cfif IsDefined('Show')>
            
			<cfif Show EQ 'Yes'>
				<cfset Show = 1>
			<cfelse>
				<cfset Show = 0>
			</cfif>
            
		<cfelse>
            
			<cfset Show = 0>
            
		</cfif>
        
        <!--- we want to insert first as anonymous - 
			donor updates the scroll on confirmation page --->
		<cfset DName = 'Anonymous'>
        <!--- 2013-03-01 Default now shows donor name
			until the donor changes it on the confirmation screen --->
		<cfset DName = '#fname# #lname#'>
        
        <!--- new method --- pty_subscr_r ---->
        <cfif pty_subscr_r EQ 1>
            <cfset SOC_subscribe = 1>
            <cfset news_subscribe = 1>
            <cfset AR_subscribe = 0>
        <cfelse>
            <cfset SOC_subscribe = 0>
            <cfset news_subscribe = 0>
            <cfset AR_subscribe = 0>
        </cfif>
                
    <cfcatch type="any">
    
    <cfmail to="csweeting@bcchf.ca" from="error@bcchf.ca" subject="error scrubbing donation form data" type="html">
    Error scrubbing donation form data
    Message: #cfcatch.Message#
    Detail: #cfcatch.Detail#
    <cfdump var="#cfcatch#" label="catch">
    <cfdump var="#form#" hide="POST_CARD_NUMBER,POST_CVV,FIELDNAMES,js_bcchf_cardnumber,js_bcchf_cvv,bcchf_cvv,bcchf_cc_number" label="transaction">
    </cfmail>
    
    </cfcatch>
    </cftry>
    
    
    <!--- attempt charge --->
	<cfset chargeAttempt = 1>
    <cfset attemptCharge = 1>
    <cfset returnMSG = 'beginAttempt-charging'>
    
    <!--- Trying to record Attempt Record --->
    <cftry>
    
    	<cfset tAttemptRecord = {tDate = pty_date, 
								tUUID = variables.newUUID,
								tDonor = {
									dTitle = title,
									dFname = fname,
									dMname = '',
									dLname = lname,
									dCname = '',
									dTaxTitle = title,
									dTaxFname = pty_tax_fname,
									dTaxMname = '',
									dTaxLname = pty_tax_lname,
									dTaxCname = '',
									dAddress = {
										aOne = add1,
										aTwo = add2,
										aCity = city,
										aProv = prov,
										aPost = postal,
										aCountry = 'Canada'
									},
									dEmail = ptc_email,
									dPhone = phone
								},
								tGift = post_dollaramount,
								tGiftAdv = 0,
								tGiftTax = post_dollaramount,
								tType = gift_type,
								tFreq = gift_frequency,
								tNotes = gift_notes,
								tSource = donation_source,
								tBrowser = {
									bUAgent = newBrowser,
									bName = '',
									bMajor = '',
									bVer = '',
									bOSname = '',
									bOSver = '',
									dDevice = '',
									bDtype = '',
									bDvend = '',
									bIP = newIP
								},
								tTType = pty_tax,
								tFreqDay = gift_day,
								tSHP = {
									tAdd = HeroDonateAdd,
									tToken = EventToken,
									tCampaign = ConstructEventYear.EventCurrentYear,
									tTeamID = TeamID,
									tSupID = SupID,
									tDname = DName,
									tStype = 'in Support of',
									tSmsg = Message,
									tSshow = Show,
									Hero_Donate_Amount = Hero_Donate_Amount
								},
								tJD = {
									Pins = 0,
									Buttons = 0,
									BBQ = 0,
									BBQl = '',
									cFriday = 0
								},
								tFORM = {
									form = 'MMP OnPanel'
								},
								adInfo = {
									iSecurity = '',
									iWill = '',
									iLife = '',
									iTrust = '',
									iRRSP = '',
									iWillInclude = '',
									iLifeInclude = '',
									iRSPinclude = '',
									SOC_subscribe = SOC_subscribe,
									news_subscribe = news_subscribe,
									AR_subscribe = AR_subscribe,
									iWhere = '',
									iPastDonor = '',
									gPledgeDet = '',
									gPledgeDREID = '',
									gPledge = 'No'
									
								},
								tribInfo = {
									trbFname = '',
									trbLname = '',
									trbEmail = '',
									trbAddress = '',
									trbCity = '',
									trbProv = '',
									trbPost = '',
									srpFname = '',
									srpLname = '',
									trbCardfrom = '',
									trbMsg = '',
									tribNotes = '',
									cardSend = '',
									gTribute = 'No'
								}
			} />
            
            <cfset tAttempt = SerializeJSON(tAttemptRecord)>
    	
    		<cfset tATPrec = recordTransAttempt(tAttempt)>
    
    	<cfinclude template="../includes/0log_donation.cfm">
    
    <cfcatch type="any">
    <cfmail to="csweeting@bcchf.ca" from="error@bcchf.ca" subject="error recording backup data" type="html">
    Error recording backup data - trying to record attempt record.
    Message: #cfcatch.Message#
    Detail: #cfcatch.Detail#
    <cfdump var="#cfcatch#" label="catch">
    <cfdump var="#form#" hide="POST_CARD_NUMBER,POST_CVV,FIELDNAMES,POST_DOLLARAMOUNT,js_bcchf_cardnumber,js_bcchf_cvv" label="transaction">
    </cfmail>

    </cfcatch>
    </cftry>
    
     <!--- ---------------------------- start of exact processing -------------------------------------------- --->
    <!--- if we can attempt the charge --->
    <cfif attemptCharge EQ 1>
    
		<!--- trying to process on e-xact --->
        <cftry>
        
			<!--- BCCHF Exact Gobal Vars --->
            <cfinclude template="../includes/e-xact_include_var.cfm">
            
            <cfif post_card_number EQ 4111111111111111><!--- allow testing --->
            
                <!--- Testing Process ---><cfinclude template="../includes/testBlock.cfm"> 
                <!--- UUID used in test approvals --->
            
            <cfelse>
            
                <!--- Exact Method cfinvoke webservice ---> 
                <cfinclude template="../includes/e-xact_post_v60.1.cfm">
            
            </cfif> 
        
        
        <cfcatch type="any">
        <cfmail to="csweeting@bcchf.ca" from="error@bcchf.ca" subject="error in exact process" type="html">
        error in exact process
        Message: #cfcatch.Message#
        Detail: #cfcatch.Detail#
        <cfdump var="#cfcatch#" label="catch">
        <cfdump var="#form#" hide="POST_CARD_NUMBER,POST_CVV,FIELDNAMES,POST_DOLLARAMOUNT,js_bcchf_cardnumber,js_bcchf_cvv" label="transaction">
        </cfmail>
        </cfcatch>
        </cftry>
        

        <!--- trying to record Recieved Record --->
        <!--- records form data and exact returned vars --->
        <cftry>
        
        	<!--- Update Attempt Record with E-Xact Charge Tokens --->
            <cfset eTransResult = {
				rqst_transaction_approved = rqst_transaction_approved,
				rqst_dollaramount = rqst_dollaramount,
				rqst_CTR = rqst_CTR,
				rqst_authorization_num = rqst_authorization_num,
				rqst_sequenceno = rqst_sequenceno,
				rqst_bank_message = rqst_bank_message,
				rqst_exact_message = rqst_exact_message,
				rqst_formpost_message = rqst_formpost_message,
				rqst_exact_respCode = rqst_exact_respCode,
				rqst_AVS = rqst_AVS
			}/>
            
            
            
            <cfset eXactRes = SerializeJSON(eTransResult)>
            
            <cfset eATPrec = recordExactAttempt(eXactRes, variables.newUUID)>
            
        
            <cfinclude template="../includes/1log_donation.cfm">
        
        <cfcatch type="any">
        <cfmail to="csweeting@bcchf.ca" from="error@bcchf.ca" subject="error recording backup data" type="html">
        Error recording backup data - trying to record recieved data
        Message: #cfcatch.Message#
        Detail: #cfcatch.Detail#
        <cfdump var="#cfcatch#" label="catch">
        <cfdump var="#form#" hide="POST_CARD_NUMBER,POST_CVV,FIELDNAMES,POST_DOLLARAMOUNT,js_bcchf_cardnumber,js_bcchf_cvv" label="transaction">
        </cfmail>
        </cfcatch>
        </cftry>
    

    <cfelse>
    	<!--- charge not attempted - IP blocked --->
    
    	<cfset rqst_transaction_approved = 0>
        <cfset rqst_exact_respCode = 0>
    	<cfset chargeAproved = 0>
        <cfset exact_respCode = 0>
        <cfset returnMSG = 'Charge Not Attempted'>
    
    </cfif>
    <!--- ---------------------------- end of exact of processing  ------------------------------------- --->


	<!--- ---------------------------- start of database processing  -------------------------------------------- --->
    <!--- NOT approved --->
    <cfif rqst_transaction_approved NEQ 1>
    
    	<!--- abort and show messages --->
    	<cfset chargeAproved = 0>
        <cfset exact_respCode = rqst_exact_respCode>
        <cfset returnMSG = 'charging-notapproved'>
        
        
    <cfelse>
    <!--- charge approved --->
    
    	<cfset chargeAproved = 1>
        <cfset returnMSG = 'charging-approved'>
        
    	<!--- record transaction information 
			
			1. Dump content of form to txt file
			2. Insert core transaction information into db
				- Transaction Information
				- Donor Information
				- SHP tables if necessary
			3. Update additional information
			4. Update tribute information
		
		--->
        
       
        <!--- try and record the transaction details in a flat txt file --->
        <cftry>
        
			<!--- directories --->
            <cfset monthlyDumpDirectory = DateFormat(Now(), 'mm-yy')>
            <Cfset dailyDumpDirectory = DateFormat(Now(), 'DD')>
            
            <cfset dumpDirectory = "#APPLICATION.WEBLINKS.File.service#\transactions\#monthlyDumpDirectory#\#dailyDumpDirectory#\">
            
            <!--- check if directory exists --->
            <cfif DirectoryExists(dumpDirectory)>
                <!--- directory exists - we are all good --->
            <cfelse>
                <!--- need to create directory --->
                <cfdirectory directory="#dumpDirectory#" action="create">
                        
            </cfif>
            
            <!--- add timestamp to file --->
            <Cfset append = "#DateFormat(Now())#---#TimeFormat(Now(), 'HH-mm-ss.l')#">
            
            <!--- dump form to file --->
            <!--- hide PCI fields --->
            <cfdump var="#form#" output="#dumpDirectory#bcchildren_full_donation_dump_date-#append#.txt" hide="POST_CARD_NUMBER,POST_CVV,FIELDNAMES,POST_DOLLARAMOUNT,js_bcchf_cardnumber,js_bcchf_cvv" type="html">
        
    	<cfcatch type="any">
        
        <cfmail to="csweeting@bcchf.ca" from="error@bcchf.ca" subject="error recording backup data" type="html">
        Error recording backup data - trying to create txt file of transaction
        Message: #cfcatch.Message#
        Detail: #cfcatch.Detail#
        <cfdump var="#cfcatch#" label="catch">
        <cfdump var="#form#" hide="POST_CARD_NUMBER,POST_CVV,FIELDNAMES,js_bcchf_cardnumber,js_bcchf_cvv,bcchf_cvv,bcchf_cc_number" label="transaction">
        </cfmail>
        
        </cfcatch>
        </cftry>
        
        <!--- Parse exact rqst_CTR for exact time --->
        <cftry>
			<cfset DTindex = REFIND("DATE/TIME", rqst_CTR) + 14>
            <cfset DT = Mid(rqst_CTR, DTindex, 18)>
            <cfset exact_odbcDT = CreateODBCDateTime(DT)>
        <cfcatch type="any">
			<cfset exact_odbcDT = pty_Date>
        </cfcatch>
        </cftry>
        
        <!--- Try to Insert Successful Record Into Database --->
        <cftry>
        
        <!--- encrypt card data --->
        <cfset encrptedCardData = encrptCard(post_card_number, gift_frequency)>
        
        <!--- Successful Record Struct --->
        <cfset tSuccessRecord = {
			tUUID = variables.newUUID,
			tDollar = post_dollaramount,
			tAdv = 0,
			tTax = post_dollaramount,
			tRType = receipt_type,
			tSource = donation_source,
			tENC = encrptedCardData,
			tCard = {
				cName = post_cardholdersname,
				eXm = post_expiry_month,
				eXy = post_expiry_year
			},
			tDonor = {
				dTitle = title,
				dFname = fname,
				dMname = '',
				dLname = lname,
				dCname = '',
				dTaxTitle = title,
				dTaxFname = pty_tax_fname,
				dTaxMname = '',
				dTaxLname = pty_tax_lname,
				dTaxCname = '',
				dAddress = {
					aOne = add1,
					aTwo = add2,
					aCity = city,
					aProv = prov,
					aPost = postal,
					aCountry = 'Canada'
				},
				dEmail = ptc_email,
				dPhone = phone
			},
			tType = gift_type,
			tFreq = gift_frequency,
			tNotes = gift_notes,
			tTType = pty_tax,
			tFreqDay = gift_day,
			tSHP = {
				tAdd = HeroDonateAdd,
				tToken = EventToken,
				tCampaign = ConstructEventYear.EventCurrentYear,
				tTeamID = TeamID,
				tSupID = SupID,
				tDname = DName,
				tStype = 'in Support of',
				tSmsg = Message,
				tSshow = Show
			},
			tJD = {
				Pins = 0,
				Buttons = 0,
				BBQ = 0,
				BBQl = '',
				cFriday = 0
			}
			
		} />
        
        <cfset tSRec = SerializeJSON(tSuccessRecord)>
        
        <cfset tSSUCrec = recordSuccAttempt(tSRec, variables.newUUID)>
        
        <!--- DEPRECIATE: bcchf_bcchildren -- transaction data in tblDonation --->
        <CFQUERY datasource="#APPLICATION.DSN.transaction#" name="insert_record" dbtype="ODBC">
        INSERT INTO tblDonation (dtnDate, exact_date, dtnAmt, dtnBenefit, dtnReceiptAmt, dtnReceiptType, dtnBatch, dtnSource, post_cardholdersname, post_card_number, post_expiry_month, post_expiry_year, post_card_type, DEK_ID, post_ExactID, rqst_transaction_approved, rqst_authorization_num, rqst_dollaramount, rqst_CTR, rqst_sequenceno, rqst_bank_message, rqst_exact_message, rqst_formpost_message, rqst_AVS, pge_UUID, dtnIP, dtnBrowser) 
        VALUES (#pty_Date#, #exact_odbcDT#, '#post_dollaramount#', '0', '#post_dollaramount#', '#receipt_type#', 'Online', '#donation_source#', '#post_cardholdersname#', '#encrptedCardData.ENCDATA#', '#post_expiry_month#', '#post_expiry_year#', '#encrptedCardData.ENCTYPE#', #encrptedCardData.ENCDEKID#, 'A00063-01', '#rqst_transaction_approved#', '#rqst_authorization_num#', '#rqst_dollaramount#', '#rqst_CTR#', '#rqst_sequenceno#', '#rqst_bank_message#', '#rqst_exact_message#', '#rqst_formpost_message#', '#rqst_AVS#', '#variables.newUUID#', '#newIP#', '#newBrowser#') 
        </CFQUERY>
        
        <!--- we want the ID from tblDonation for the tax receipt --->
        <cfquery name="selectID" datasource="#APPLICATION.DSN.transaction#">
        SELECT dtnID FROM tblDonation WHERE pge_UUID = '#variables.newUUID#'
        </cfquery>
        

        <!--- new method for new receipts --->
		<cfif selectID.dtnID GTE 200000>
            <cfset receiptNumber = selectID.dtnID + 1100000>
        <cfelse>
            <cfset receiptNumber = selectID.dtnID + 800000>
        </cfif>
        
        
        <!--- if the try block fails --->
        <!--- send email with details to isbcchf --- log transaction --->
        <cfcatch type="any">
			<cfmail to="csweeting@bcchf.ca" from="error@bcchf.ca" subject="error recording transaction data" type="html">
            Error recording database data into tblDonation
            Message: #cfcatch.Message#
            Detail: #cfcatch.Detail#
            <cfdump var="#cfcatch#" label="catch">
            <cfdump var="#form#" hide="POST_CARD_NUMBER,POST_CVV,FIELDNAMES,POST_DOLLARAMOUNT,js_bcchf_cardnumber,js_bcchf_cvv">
            </cfmail>
        </cfcatch>
        </cftry>
        
      
        <!--- DEPRECIATE: bcchf_donationGeneral -- donor data in tblGeneral --->
        <cftry>
        
        
        <!--- insert basic info and update later with other info --->
        <!--- donor information --->
        <CFQUERY datasource="#APPLICATION.DSN.general#" name="insert_record">
        INSERT INTO tblGeneral (pty_date, exact_date, pty_title, pty_fname, pty_miname, pty_lname, pty_companyname, ptc_address, ptc_add_two, ptc_city, ptc_prov, ptc_post, ptc_country, ptc_email, ptc_phone, pty_tax_title, pty_tax_fname, pty_tax_lname, pty_tax_companyname, gift, gift_Advantage, gift_Eligible, gift_type, gift_frequency, gift_notes, rqst_authorization_num, pty_tax, POST_REFERENCE_NO, rqst_sequenceno, gift_day, JD_Pin, JD_Button, SupID, TeamID, pge_UUID) 
        VALUES (#pty_date#, #exact_odbcDT#, '#title#', '#fname#', '', '#lname#',  '', '#add1#', '#add2#', '#city#', '#prov#', '#postal#', '', '#ptc_email#', '#phone#', '#title#', '#pty_tax_fname#', '#pty_tax_lname#', '', '#post_dollaramount#', '0', '#post_dollaramount#', '#gift_type#', '#gift_frequency#', '#gift_notes#', '#rqst_authorization_num#', '#pty_tax#', '#rqst_sequenceno#', '#rqst_sequenceno#', '#gift_day#', '0',  '0', #SupID#, #TeamID#, '#variables.newUUID#')
        </CFQUERY>
        
        <!--- if the try block fails --->
        <!--- send email with details to isbcchf --- log transaction --->
        <cfcatch type="any">
			<cfmail to="csweeting@bcchf.ca" from="error@bcchf.ca" subject="error recording transaction data" type="html">
            Error recording database data into tblGeneral
            Message: #cfcatch.Message#
            Detail: #cfcatch.Detail#
            <cfdump var="#cfcatch#" label="catch">
            <cfdump var="#form#" hide="POST_CARD_NUMBER,POST_CVV,FIELDNAMES,POST_DOLLARAMOUNT,js_bcchf_cardnumber,js_bcchf_cvv">
            </cfmail>
        </cfcatch>
        </cftry>
                
        
        <!--- ---------------------------- end of database processing -------------------------------------------- --->
        <!--- ---------------------------- confirmation email process -------------------------------------------- --->
        
        
        
        <cftry>
        
        <!--- 
			1. Transaction info to DS/IS 
				- include aahui@bcchf.ca if pledge
				- include asafy@bcchf.ca,lmador@bcchf.ca if GT 10K
				
			2. Notification to Donor (may need to load event template)
				This email and receipt is now sent from confirmation page....
				the donor email gets activated once the confirmationpage has been served
				
			7. if SHP - Notification to 
				1. Supporter 
				2. Team Captain 
				3. R.M. & Event Orgs
				
			--->
        
        
        <!---- 1. FIRST TO FOUNDATION IN ALL CASES 
        <cfset FDNnotifyEmail = FDNnotifyEmail(variables.newUUID)>--->
		
        <!---- 2. donation confirmation message 
		message being triggered from completed donation page ---------
		<cfset DonorEmailThanks = DonorEmailThanks(variables.newUUID)> --->
        
        <cfif EventToken EQ 'ICE'>
        
        	<cfif ptc_email NEQ ''>
            
            <cfmail to="#ptc_email#" from="donations@bcchf.ca" subject="Thank you for your transaction" type="html">
            <p>#fname# #lname#, </p>
            <p>Thank you for your contribution to The CUISA 2016 Conference and Trade Show in support of BC Children's Hospital Foundation. Below please find receipt of your transaction.</p>
            <p>
            ======Transaction Record======<br />
            BC Children's Hospital Foundation<br />
            938 West 28th Ave.<br />
            Vancouver, BC V5Z 4H4<br />
            Canada<br />
            http://www.bcchf.ca<br />
            TYPE: Purchase<br />
            PAY TYPE: #post_card_type#<br />
            DATE: #DateFormat(Now(), "DD MMM YYYY HH:MM:SS")#<br />
            AMOUNT: #DollarFormat(post_dollaramount)# CAD<br />
            AUTH: #rqst_authorization_num#<br />
            REF: #rqst_sequenceno#<br />
            <br />
            Thank You.<br />
            </p>
            
            </cfmail>
            
            
            </cfif>
        
        
        <cfelseif EventToken EQ 'WigsForKids'>
        
        	<cfif ptc_email NEQ ''>
            
            <cfmail to="#ptc_email#" from="donations@bcchf.ca" subject="Thank you for your transaction" type="html">
            <p>#post_cardholdersname#, </p>
            <p>Thank you for your support of Wigs for Kids in support of BC Children's Hospital Foundation. Below please find a confirmation receipt of your transaction.</p>
            <p>
            ======Transaction Record======<br />
            BC Children's Hospital Foundation<br />
            938 West 28th Ave.<br />
            Vancouver, BC V5Z 4H4<br />
            Canada<br />
            http://www.bcchf.ca<br />
            TYPE: Purchase<br />
            PAY TYPE: #post_card_type#<br />
            DATE: #DateFormat(Now(), "DD MMM YYYY HH:MM:SS")#<br />
            AMOUNT: #DollarFormat(post_dollaramount)# CAD<br />
            AUTH: #rqst_authorization_num#<br />
            REF: #rqst_sequenceno#<br />
            <br />
            Thank You.<br />
            </p>
            
            </cfmail>
            
            
            </cfif>
        
        </cfif>
        
       
       
		<cfcatch type="any">
        
        	<cfmail to="csweeting@bcchf.ca" from="error@bcchf.ca" subject="error sending donation emails" type="html">
            Error sending donation emails
            Message: #cfcatch.Message#
            Detail: #cfcatch.Detail#
            tEAMid: #hiddenTeamID#
            <cfdump var="#form#" hide="POST_CARD_NUMBER,POST_CVV,FIELDNAMES,POST_DOLLARAMOUNT,js_bcchf_cardnumber,js_bcchf_cvv">
            </cfmail>
        </cfcatch>
        </cftry>	
			
		<!--- ---------------------------- end of email processing    -------------------------------------------- --->

        <!--- send return message to browser window that the transaction is complete --->
        
        
        <!--- message about frequency  --->
        <cfset chargeMSG = gift_frequency>
        <!--- after inserting in DB and sending emails --->
        <cfset returnSuccess = 1>
        
    </cfif>
    <!--- ---------------------------- end of if charging approved  -------------------------------------------- --->




	<cfset supporterMSG = ''>
    <cfset regMSG = ''>
    <cfset reg_u_MSG = ''>
    <cfset teamMSG = ''>
    <cfset emMSG = ''>
    



	<!--- this is the structure of the return message --->
	<cfset SHPregReturnMSG = {
		Success = returnSuccess,
		ChargeAttmpt = {
			cAttempted = chargeAttempt,
			cApproved = chargeAproved,
			cMSG = chargeMSG
			},
		SHPprocess = {
			SupMSG = supporterMSG,
			RegMSG = regMSG,
			Reg_u_MSG = reg_u_MSG,
			TeamMSG = teamMSG,
			emMSG = emMSG
		},
		Message = returnMSG,
		UUID = variables.newUUID,
		SupID = SupID
		} />  
            
    <cfreturn SHPregReturnMSG>

</cffunction>

<!--- onPanel MMP Processor - Pledges --->
<cffunction name="onPanelMMPpledge" access="remote">
    
    <cfargument name="SupporterID" type="numeric" required="yes">
    <cfargument name="TeamID" type="numeric" required="yes">
	<cfargument name="payMethod" type="string" required="no">
    <cfargument name="donation" type="numeric" required="yes">
    

	<!--- ---------------------------- start of processing  -------------------------------------------- --->
    <!--- SERVER Date at submission --->
    <cfif NOT IsDefined("pty_date")><cfset pty_date= "#Now()#"></cfif>
    
    <!--- create UUID to access info --->
    <cfset variables.newUUID=createUUID()>
    <!--- collect IP address of remote requestor --->
	<cfset newIP = CGI.REMOTE_ADDR>
	<cfset newBrowser = CGI.HTTP_USER_AGENT>
    <cfset ipBlocker = 0>
    
    <!--- set transaction amount --->
    <cfset hiddenGiftAmount = REREPlace(donation, '[^0-9.]','','all')>
    <cfset post_dollaramount = donation>
    
    <!--- default setting is YES for adding to hero donate ---> 
    <cfset HeroDonateAdd = 1>
    <cfset SupID = SupporterID>
    <cfset TeamID = TeamID>
    
    <!--- successful variables --->
    <cfset chargeSuccess = 0>
    <cfset donationSuccess = 0>
    <cfset chargeAttempt = 0>
    <cfset chargeAproved = 0>
    <cfset chargeMSG = "">
    <cfset tGenTwoID = 0>
    
    <!--- construct return message --->
    <cfset returnSuccess = 0>
    <cfset returnMSG = 'beginAttempt'>
    <cfset exact_respCode = 0>
    
    <cfset pty_subscr_r = 0>
    
    <!--- trim name vars --->
    <cfset pty_tax_fname = TRIM(fname)>
	<cfset pty_tax_lname = TRIM(lname)>
    <cfset pty_tax = 'yes'>
    
    <!--- set gift type on form pre load --->
    <cfset gift_type = 'MMP'>
    <cfset gift_frequency = 'Single'>
	<cfset gift_day = "">
    <cfset gift_notes = "">
        
	<!--- set source --->
	<cfset donation_source = 'MMP 2015 OnPanel Form'>
    
    <cfset donEmailTemplate = 'DonEmail'>
	
    
    <!--- scrub some variables for db loading --->
    <cftry>
    
    
    	<!--- we have event information -- query for donation confirmation text --->
        <cfquery name="ConstructEventDonText" datasource="#APPLICATION.DSN.Superhero#">
        SELECT TextApprovedBody FROM Hero_EventText 
        WHERE Event = 'MMP' AND TextName = '#donEmailTemplate#'
        </cfquery>
        
        <!--- get the supporter name and email --->
        <cfquery name="selectMember" datasource="#APPLICATION.DSN.Superhero#">
        SELECT SupFName, SupLName, SupEmail, Don_Notify 
        FROM Hero_Members WHERE SuppID = #SupID#
        </cfquery>
                
        <!--- get the event name and necessary emails --->
        <cfquery name="selectEventName" datasource="#APPLICATION.DSN.Superhero#">
        SELECT Event_Name, Staff_email, Event_Email, Don_Notify, 
        Don_cc, EventCurrentYear
        FROM Hero_Event WHERE Event = 'MMP'
        </cfquery>
        
        <!--- update the confirmation texts --->
        <cfset emailConfirmationText = ConstructEventDonText.TextApprovedBody>
        <cfset emailConfirmationEvent = ' to the #selectEventName.Event_Name#'>
        <cfset emailConfirmationSupporting = '#selectMember.SupFName# #selectMember.SupLName#'>
        <cfset Message = '#selectMember.SupFName# #selectMember.SupLName#'>

    	<!--- TAX receipt options for processor ---->
        <!--- use receipt type for Ink/No Ink --->
        <!--- TODO: HK receipting options --->
        <!--- receipt types
			TAX = TAX RECEIPT
			AWK = AWKNOWLEDGMENT RECEIPT
			TAX-HK = Hong Kong 
			TAX-IF = Ink Friendly
			TAX-ANNUAL = Annual Receipt for monthly gift
			TAX-HK-ANNUAL = Annual Receipt for monthly gift on HK page
			NONE = None requested / ineligible
			--->
		
        
		<cfif gift_frequency EQ 'single'>
            <cfif pty_tax EQ "no">
                <cfset receipt_type = 'NONE'>
            <cfelse>
                <cfif IsDefined('pty_ink')>
                    <cfif pty_ink EQ 'yes'>
                        <cfset receipt_type = 'TAX-IF'>
                    <cfelse>
                        <cfset receipt_type = 'TAX'>
                    </cfif>
                <cfelse>
                    <cfset receipt_type = 'TAX'>
                </cfif>
            </cfif>
        <cfelse>
            <cfif pty_tax EQ "no">
                <cfset receipt_type = 'NONE'>
            <cfelse>
                <cfset receipt_type = 'TAX-ANNUAL'>
            </cfif>        
        </cfif>
        
    	<!--- legacy: receipt generator method
			- check for receipt status 
			- append 'no receipt' to frequency for no receipt--->
        <cfif pty_tax EQ "no">
			<cfset gift_frequency="#gift_frequency# - No Receipt">
        <cfelse>
        	<cfset gift_frequency="#gift_frequency#">
        </cfif>
        
        <cfif gift_frequency EQ 'single'>
        	<cfset gift_frequency = 'Single'>
        </cfif>
    
        
        <!--- add to Hero_Donate AMount --->
        <cfif gift_frequency EQ 'monthly'>
			<cfset Hero_Donate_Amount = post_dollaramount * 12>
        <cfelse>
            <cfset Hero_Donate_Amount = post_dollaramount>
        </Cfif> 
        
        <!--- TYS options --->
        <cfif IsDefined('Show')>
            
			<cfif Show EQ 'Yes'>
				<cfset Show = 1>
			<cfelse>
				<cfset Show = 0>
			</cfif>
            
		<cfelse>
            
			<cfset Show = 0>
            
		</cfif>
        
        <!--- we want to insert first as anonymous - 
			donor updates the scroll on confirmation page --->
		<cfset DName = 'Anonymous'>
        <!--- 2013-03-01 Default now shows donor name
			until the donor changes it on the confirmation screen --->
		<cfset DName = '#fname# #lname#'>
        
        <!--- new method --- pty_subscr_r ---->
        <cfif pty_subscr_r EQ 1>
            <cfset SOC_subscribe = 1>
            <cfset news_subscribe = 1>
            <cfset AR_subscribe = 0>
        <cfelse>
            <cfset SOC_subscribe = 0>
            <cfset news_subscribe = 0>
            <cfset AR_subscribe = 0>
        </cfif>
                
    <cfcatch type="any">
    
    <cfmail to="csweeting@bcchf.ca" from="error@bcchf.ca" subject="error scrubbing donation form data" type="html">
    Error scrubbing donation form data
    Message: #cfcatch.Message#
    Detail: #cfcatch.Detail#
    <cfdump var="#cfcatch#" label="catch">
    <cfdump var="#form#" hide="POST_CARD_NUMBER,POST_CVV,FIELDNAMES,js_bcchf_cardnumber,js_bcchf_cvv,bcchf_cvv,bcchf_cc_number" label="transaction">
    </cfmail>
    
    </cfcatch>
    </cftry>
    
    
    <!--- attempt charge --->
	<cfset chargeAttempt = 0>
    <cfset attemptCharge = 0>
    <cfset returnMSG = 'beginAttempt-charging'>
    
    <cfset rqst_transaction_approved = 1>

	<!--- ---------------------------- start of database processing  -------------------------------------------- --->
    <!--- NOT approved --->
    <cfif rqst_transaction_approved NEQ 1>
    
    	<!--- abort and show messages --->
    	<cfset chargeAproved = 0>
        <cfset exact_respCode = rqst_exact_respCode>
        <cfset returnMSG = 'charging-notapproved'>
        
        
    <cfelse>
    <!--- charge approved --->
    
    	<cfset chargeAproved = 1>
        <cfset returnMSG = 'charging-approved'>

        
       
        
        <!--- Try to Insert Successful Record Into Database --->
        <cftry>
                
        <!--- Add into Hero_Donate Only --->
        
        
        <!--- Monthly * 12 in SHP --->
    	<cfif gift_frequency EQ 'Monthly'
			OR gift_frequency EQ 'Monthly - No Receipt'>
            
            <cfset Hero_Donate_Amount = post_dollaramount * 12>
            
		<cfelse>
        
			<cfset Hero_Donate_Amount = post_dollaramount>
            
		</cfif>
    
		<!--- insert into hero_donate --->
    	<cfquery name="insertHeroDonation" datasource="#APPLICATION.DSN.Superhero#">
		INSERT INTO Hero_Donate (Event, Campaign, TeamID, Name, Type, Message, Show, DonTitle, DonFName, DonLName, DonCompany, Email, don_date, Amount, SupID, JDPins, JDButtons, pge_UUID, AddDate, UserAdd, LastChange, LastUser, dtnSource, Gift_Type) 
		VALUES ('MMP', 
        	2015, 
            #TeamID#, 
            '#Dname#', 
            'in Support of', 
            'Message', 
            #Show#, 
            '#Title#', 
			'#Fname#',
            '#Lname#',  
        	'', 
            '#ptc_Email#', 
            #CreateODBCDatetime(pty_Date)#, 
            #Hero_Donate_Amount#, 
            #SupID#, 
            0, 
            0, 
            '#variables.newUUID#', 
            #CreateODBCDatetime(pty_Date)#,
            'Online', 
            #CreateODBCDatetime(pty_Date)#,
            'Online',
            'MMP onPanel',
            'Pledge')
		</cfquery>
        
        
        <!--- if the try block fails --->
        <!--- send email with details to isbcchf --- log transaction --->
        <cfcatch type="any">
			<cfmail to="csweeting@bcchf.ca" from="error@bcchf.ca" subject="error recording transaction data" type="html">
            Error recording database data into tblDonation
            Message: #cfcatch.Message#
            Detail: #cfcatch.Detail#
            <cfdump var="#cfcatch#" label="catch">
            <cfdump var="#form#" hide="POST_CARD_NUMBER,POST_CVV,FIELDNAMES,POST_DOLLARAMOUNT,js_bcchf_cardnumber,js_bcchf_cvv">
            </cfmail>
        </cfcatch>
        </cftry>
        
      
                
        
        <!--- ---------------------------- end of database processing -------------------------------------------- --->

        <!--- send return message to browser window that the transaction is complete --->
        
        
        <!--- message about frequency  --->
        <cfset chargeMSG = gift_frequency>
        <!--- after inserting in DB and sending emails --->
        <cfset returnSuccess = 1>
        
    </cfif>
    <!--- ---------------------------- end of if charging approved  -------------------------------------------- --->



	<cfset supporterMSG = ''>
    <cfset regMSG = ''>
    <cfset reg_u_MSG = ''>
    <cfset teamMSG = ''>
    <cfset emMSG = ''>




	<!--- this is the structure of the return message --->
	<cfset SHPregReturnMSG = {
		Success = returnSuccess,
		ChargeAttmpt = {
			cAttempted = chargeAttempt,
			cApproved = chargeAproved,
			cMSG = chargeMSG
			},
		SHPprocess = {
			SupMSG = supporterMSG,
			RegMSG = regMSG,
			Reg_u_MSG = reg_u_MSG,
			TeamMSG = teamMSG,
			emMSG = emMSG
		},
		Message = returnMSG,
		UUID = variables.newUUID,
		SupID = SupID
		} />  
            
    <cfreturn SHPregReturnMSG>

</cffunction>



<cffunction
name="ParseHTMLTag"
access="public"
returntype="struct"
output="false"
hint="Parses the given HTML tag into a ColdFusion struct.">
 
<!--- Define arguments. --->
<cfargument
name="HTML"
type="string"
required="true"
hint="The raw HTML for the tag."
/>
 
<!--- Define the local scope. --->
<cfset var LOCAL = StructNew() />
 
<!--- Create a structure for the taget tag data. --->
<cfset LOCAL.Tag = StructNew() />
 
<!--- Store the raw HTML into the tag. --->
<cfset LOCAL.Tag.HTML = ARGUMENTS.HTML />
 
<!--- Set a default name. --->
<cfset LOCAL.Tag.Name = "" />
 
<!---
Create an structure for the attributes. Each
attribute will be stored by it's name.
--->
<cfset LOCAL.Tag.Attributes = StructNew() />
 
 
<!---
Create a pattern to find the tag name. While it
might seem overkill to create a pattern just to
find the name, I find it easier than dealing with
token / list delimiters.
--->
<cfset LOCAL.NamePattern = CreateObject(
"java",
"java.util.regex.Pattern"
).Compile(
"^<(\w+)"
)
/>
 
<!--- Get the matcher for this pattern. --->
<cfset LOCAL.NameMatcher = LOCAL.NamePattern.Matcher(
ARGUMENTS.HTML
) />
 
<!---
Check to see if we found the tag. We know there
can only be ONE tag name, so using an IF statement
rather than a conditional loop will help save us
processing time.
--->
<cfif LOCAL.NameMatcher.Find()>
 
<!--- Store the tag name in all upper case.---> 
<cfset LOCAL.Tag.Name = UCase(
LOCAL.NameMatcher.Group( JavaCast('int',1) )
) />
 
</cfif>
 
 
<!---
Now that we have a tag name, let's find the
attributes of the tag. Remember, attributes may
or may not have quotes around their values. Also,
some attributes (while not XHTML compliant) might
not even have a value associated with it (ex.
disabled, readonly).
--->
<cfset LOCAL.AttributePattern = CreateObject(
"java",
"java.util.regex.Pattern"
).Compile(
"\s+(\w+)(?:\s*=\s*(""[^""]*""|[^\s>]*))?"
)
/>
 
<!--- Get the matcher for the attribute pattern. --->
<cfset LOCAL.AttributeMatcher = LOCAL.AttributePattern.Matcher(
ARGUMENTS.HTML
) />
 
 
<!---
Keep looping over the attributes while we
have more to match.
--->
<cfloop condition="LOCAL.AttributeMatcher.Find()">
 
<!--- Grab the attribute name. --->
<cfset LOCAL.Name = LOCAL.AttributeMatcher.Group( JavaCast('int',1) ) />
 
<!---
Create an entry for the attribute in our attributes
structure. By default, just set it the empty string.
For attributes that do not have a name, we are just
going to have to store this empty string.
--->
<cfset LOCAL.Tag.Attributes[ LOCAL.Name ] = "" />
 
<!---
Get the attribute value. Save this into a scoped
variable because this might return a NULL value
(if the group in our name-value pattern failed
to match).
--->
<cfset LOCAL.Value = LOCAL.AttributeMatcher.Group( JavaCast('int',2) ) />
 
<!---
Check to see if we still have the value. If the
group failed to match then the above would have
returned NULL and destroyed our variable.
--->
<cfif StructKeyExists( LOCAL, "Value" )>
 
<!---
We found the attribute. Now, just remove any
leading or trailing quotes. This way, our values
will be consistent if the tag used quoted or
non-quoted attributes.
--->
<cfset LOCAL.Value = LOCAL.Value.ReplaceAll(
"^""|""$",
""
) />
 
<!---
Store the value into the attribute entry back
into our attributes structure (overwriting the
default empty string).
--->
<cfset LOCAL.Tag.Attributes[ LOCAL.Name ] = LOCAL.Value />
 
</cfif>
 
</cfloop>
 
 
<!--- Return the tag. --->
<cfreturn LOCAL.Tag />
</cffunction>



<!--- Error Message Handler -- recieves error message detials and sends error emails--->
<cffunction name="sendERRmsg" access="private" returntype="boolean">
	
	<cfargument name="eDetails" type="string" required="yes">
    
    
    <cftry>
    
		<cfset errorEmailSent = 1>
        <cfset errorEMail = 'csweeting@bcchf.ca'>
        <cfset errorPriroiry = 1>
        <cfset errorSubject = 'Error on Donation Form'>
        <cfset errorFullMessage = 'Error on Donation Form'>
    
    	<cfset eDetMSG = DeserializeJSON(eDetails)>
        
    	<cfif eDetMSG.eML EQ 1>
        	<cfset errorSubject = 'P2:Error - Scrubbing donation form data in processDonation'>
        	<cfset errorFullMessage = 'Error scrubbing donation form data. Priority Level 2.<br />
				A Donation Form was submitted, but some data is not right, which may cause subsequent errors during this transaction.<br />
				Transaction is permitted to proceed; immediate action not required, unless multiple errors of this nature start to be thrown.<br />
				'>
        <cfelseif eDetMSG.eML EQ 2>
        	<cfset errorSubject = 'P3: Error - Recording backup data attempt record in processDonation'>
        	<cfset errorFullMessage = 'Error recording backup data - trying to record attempt record. Priority Level 3.<br />
				A Donation Form was submitted, but the attemt record was unable to be saved in 0log_donation.<br />
				Transaction is permitted to proceed; immediate action not required.<br />
				'>
        <cfelseif eDetMSG.eML EQ 3>
        	<cfset errorSubject = 'P3: Error - Checking fraud data in processDonation'>
        	<cfset errorFullMessage = 'Error checking fraud data. Priority Level 3.<br />
				A Donation Form was submitted, but the processor ws unable to check for fraudulent attempts.<br />
				Transaction is permitted to proceed; immediate action not required.<br />
				'>
        <cfelseif eDetMSG.eML EQ 4>
        	<cfset errorSubject = 'P1: Error - Communicating with e-xact'>
        	<cfset errorFullMessage = '<strong>!!*** ---- error in exact process. Priority Level 1. ---- ***!!</strong><br />
				A Donation Form was submitted, but communication with E-xact failed.<br />
				<strong>Immediate action required</strong>.<br />
				The cause of this error needs to be determined, this type of error could block our ability to process transactions.<br />
				May be caused by a short outage with E-xact, in which case service will return with no further action required, however investigation is required.<br />
				'>
        <cfelseif eDetMSG.eML EQ 5>
        	<cfset errorSubject = 'P3: Error - Recording backup data in processDonation'>
        	<cfset errorFullMessage = 'Error recording backup data - trying to record recieved data. Priority Level 3.<br />
				A Donation Form was submitted - data submitted and recieved from E-xact, but the processor ws unable save the returned E-xact message in 1log_donation.<br />
				Transaction is permitted to proceed; immediate action not required.<br />
				'>
        <cfelseif eDetMSG.eML EQ 6>
        	<cfset errorSubject = 'P3: Error - Checking IP data in processDonation'>
        	<cfset errorFullMessage = 'Error recording backup data - checking the IP on a failed record. Priority Level 3.<br />
				A Donation Form was submitted, transaction DECLINED, but the processor ws unable to record the IP to check for subsequent fraudulent activity.<br />
				Transaction is completed; immediate action not required.<br />
				'>
        <cfelseif eDetMSG.eML EQ 7>
        	<cfset errorSubject = 'P3: Error - Removing IP from blocker trace in processDonation'>
        	<cfset errorFullMessage = 'Error removing IP from blocker trace table. Priority Level 3.<br />
				A Donation Form was submitted, transaction APPROVED, but the processor ws unable to update the IP table to check for subsequent fraudulent activity.<br />
				Transaction is completed; immediate action not required.<br />
				'>
        <cfelseif eDetMSG.eML EQ 8>
        	<cfset errorSubject = 'P3: Error - Recording donation form data in processDonation'>
        	<cfset errorFullMessage = 'Error recording backup data - trying to create txt file of transaction. Priority Level 3.<br />
				A Donation Form was submitted, transaction APPROVED, but the donation form record was unable to be saved in dumpDirectory.<br />
				Transaction is completed; immediate action not required.<br />
				'>
        <cfelseif eDetMSG.eML EQ 9>
        	<cfset errorSubject = 'P2: Error - Recording donation transaction data in processDonation'>
        	<cfset errorFullMessage = 'Error recording database data into tblGeneral. Priority Level 2.<br />
				A Donation Form was submitted, transaction APPROVED, but the donation was not recorded in the database.<br />
				Transaction is completed; immediate action not required, unless multiple errors of this nature start to be thrown.<br />
				'>
        <cfelseif eDetMSG.eML EQ 10>
        	<cfset errorSubject = 'P3: Error - Recording Additional Transaction Details in processDonation'>
        	<cfset errorFullMessage = 'Error updating database data into tblGeneral. Priority Level 3.<br />
				A Donation Form was submitted, transaction APPROVED, critical transaction details recorded, but the processor ws unable to record the additional transaction details.<br />
				Transaction is completed; immediate action not required, unless multiple errors of this nature start to be thrown.<br />
				'>
        <cfelseif eDetMSG.eML EQ 11>
        	<cfset errorSubject = 'P3: Error - Sending Donor Triggered Emails in processDonation'>
        	<cfset errorFullMessage = 'Error sending donation notification emails to DS. Priority Level 3.<br />
				A Donation Form was submitted, transaction APPROVED, but the notification email to DS was not sent.<br />
				Transaction is completed; immediate action not required, unless multiple errors of this nature start to be thrown.<br />
				'>
        <cfelseif eDetMSG.eML EQ 12>
        	<cfset errorSubject = 'P1: Error - Creating Transaction at PayPal in processDonation'>
        	<cfset errorFullMessage = '<strong>!!*** ---- error in PayPal process. Priority Level 1. ---- ***!!</strong><br />
				A Donation Form was submitted, but communication with PayPal failed (creation).<br />
				<strong>Immediate action required</strong>.<br />
				The cause of this error needs to be determined, this type of error could block our ability to process PayPal transactions.<br />
				May be caused by a short outage with PayPal, in which case service will return with no further action required, however investigation is required.<br />
				'>
        <cfelseif eDetMSG.eML EQ 13>
        	<cfset errorSubject = 'P1: Error - Recording PayPal transaction Details'>
        	<cfset errorFullMessage = '<strong>!!*** ---- error in PayPal process. Priority Level 1. ---- ***!!</strong><br />
				A Donation Form was submitted, creation in PayPal completed, but not recorded in the database.<br />
				The cause of this error needs to be determined, this type of error could block our ability to process PayPal transactions.<br />
				'>
        <cfelseif eDetMSG.eML EQ 14>
        <cfelseif eDetMSG.eML EQ 15>
        <cfelseif eDetMSG.eML EQ 16>
        </cfif>
        
        
                
        <cfset errorPriroiry = eDetMSG.eP>
    
    	<cfmail to="#errorEMail#" from="error@bcchf.ca" subject="#errorSubject#!" type="html" priority="#errorPriroiry#">
        #errorFullMessage#
        <cfdump var="#eDetMSG.cfcatch#" label="catch">
        <cfdump var="#CGI#" label="CGI Scope">
        </cfmail>
        
    
    <cfcatch type="any">
    
    	<cfmail to="csweeting@bcchf.ca" from="error@bcchf.ca" subject="Error in Error Procedure" type="html" priority="1">
        ERROR in ERROR procedure
        <cfdump var="#cfcatch#" label="catch">
        </cfmail>
    </cfcatch>
    </cftry>
    
    
<cfreturn errorEmailSent>

</cffunction>


<!--- json return will be requested --->
<cffunction name="executePayPalTransaction" access="remote">
    
    <cfargument name="PayerID" type="string" required="yes">
    <cfargument name="PaymentID" type="string" required="yes">
    <cfargument name="UUID" type="string" required="yes">
    <cfargument name="Event" type="string" required="yes">
    <cfargument name="qString" type="string" required="yes">
	<cfargument name="js_bcchf_gift_details" type="string" required="no">
    
    <cfset sup_pge_UUID = UUID>
    <cfset Event = Event>
    
	
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
    <cfset payDetail["payer_id"] = PayerID>
    
    <cfhttp 
    result="result"
    method="post"
    url="#apiendPoint#v1/payments/payment/#PaymentId#/execute/" 
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
            
            <cfset gift_notes = '#selectDonor.gift_notes# #js_bcchf_gift_details#'>
            
            <!---
            <cfquery name="updateNotes" datasource="#APPLICATION.DSN.Superhero#">
            UPDATE tblGeneral SET gift_notes = '#gift_notes#'
            WHERE pge_UUID = '#sup_pge_UUID#';
            </cfquery> --->
            
            <cfquery name="updateNotes" datasource="#APPLICATION.DSN.general#">
            UPDATE tblGeneral SET gift_notes = '#gift_notes#'
            WHERE pge_UUID = '#sup_pge_UUID#';
            </cfquery>
            
            
            
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
                
                
                <!--- insert into hero_donate if necessary --->
                <cfquery name="insertHeroDonation" datasource="#APPLICATION.DSN.Superhero#">
                INSERT INTO Hero_Donate (Event, Campaign, TeamID, Name, Type, Message, Show, DonTitle, DonFName, DonLName, DonCompany, Email, don_date, rqst_authorization_num, Amount, SupID, JDPins, JDButtons, pge_UUID, AddDate, UserAdd, LastChange, LastUser) 
                VALUES ('#Event#', #gDetail.tCampaign#, #gDetail.tTeamID#, '#gDetail.tDName#', '#gDetail.tstype#', '', #gDetail.tsShow#, '#selectGDetail.pty_title#', '#selectGDetail.pty_fname#', '#selectGDetail.pty_lname#', '#selectGDetail.pty_companyname#', '#selectGDetail.ptc_email#', #CreateODBCDateTime(selectGDetail.pty_Date)#, '#SHPevent.ID#', #gDetail.Hero_Donate_Amount#, #gDetail.tSupID#, #selectGDetail.JD_pin#, #selectGDetail.JD_Button#, '#selectPayPal.pge_UUID#', #add_date#, 'Online', #add_date#, 'Online')
                </cfquery>
            
            
                </cfif>
            
            
            
            
            </cfif>
            
            
            
            
        
        <cfcatch type="any">
        
        <cfmail to="csweeting@bcchf.ca" from="task@bcchf.ca" subject="Pay Pal DB Connect Error" type="html">
        <cfdump var="#cfcatch#" label="error">
        </cfmail>
        
        </cfcatch>
        </cftry>
        
        
        
        <!--- activate eCard if necesary --->
        
        
        
        <!--- email notifications --->
        <!---- 1. FIRST TO FOUNDATION IN ALL CASES --->
        <cfset FDNnotifyEmail = FDNnotifyEmail(sup_pge_UUID)>
		
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
        
        	<cfset ICEnotifyEmail = ICEnotifyEmail(sup_pge_UUID)>
        
        <cfelseif Event EQ 'WOT'>
        
        	<!--- 				 
			<cfif (hiddenTributeType EQ 'hon-WOT' OR hiddenTributeType EQ 'mem-WOT')>
			
				<cfset WOTnotifyEmail = WOTnotifyEmail(variables.newUUID)>
			
			</cfif>--->
		
		<cfelseif Event EQ 'JeansDay'>
        
        	<cfset JeansDayNotifyEmail = JeansDayNotifyEmail(sup_pge_UUID)>
        
        <cfelse>
        
        	<cfset supNotifyEmail = SHPnotifyEmail(sup_pge_UUID)>
            
        </cfif>
        
        
        <cfset chargeAproved = 1>
        <cfset chargeMSG = ''>
        
        
    <cfelseif result.responseheader.status_code EQ 400>    
    <!--- 400 status code recieved ---
        --- pass back to donation form with message
        --- this will allow another attempt with CCrd details --->
        
        <cfset chargeAproved = 0>
        <cfset chargeMSG = 'PayPalCancel'>
        
        <!--- error executing --->
    <cfmail to="csweeting@bcchf.ca" from="paypalprocess@bcchf.ca" subject="PayPal Fail on Execute" type="html">
    <p>Did not recieve 200 status code on execution.</p>
    <cfdump var="#result#">
    </cfmail>
        
        
        
    <cfelse>
    
    	<cfset chargeAproved = 0>
        <cfset chargeMSG = 'Error'>
    
    <!--- error executing --->
    <cfmail to="csweeting@bcchf.ca" from="paypalprocess@bcchf.ca" subject="PayPal Fail on Execute" type="html">
    <p>Did not recieve 200 status code on execution.</p>
    <cfdump var="#result#">
    </cfmail>
    
    
    
    </cfif>

	<!--- set url for completion pages --->
    <cfif Event EQ 'HolidaySnowball'>
    	<cfset payCompleteURL = 'https://secure.bcchf.ca/donate/completeDonation-snowball.cfm?UUID=#sup_pge_UUID#&Event=#Event#'>
    <cfelse>
    	<cfset payCompleteURL = 'https://secure.bcchf.ca/donate/completeDonation-mobile.cfm?UUID=#sup_pge_UUID#&Event=#Event#'>
    </cfif>


	<!--- return message --->
    <cfset ChargeAttmpt = {
		cAttempted = 1,
		cApproved = chargeAproved,
		cMSG = chargeMSG,
		exact_respCode = '',
		ipBlocker = 0,
		goodXDS = 1,
		ppEXURL = '#payCompleteURL#',
		ppID = '' 
		} />

	<!--- this is the structure of the return message --->
    <cfset SHPdonationReturnMSG = {
	Success = 1,
	ChargeAttmpt = ChargeAttmpt,
	Message = '',
	EventToken = Event,
	UUID = sup_pge_UUID,
	tGenTwoID = 0
	} />
            
    <cfreturn SHPdonationReturnMSG>

</cffunction>



</cfcomponent>