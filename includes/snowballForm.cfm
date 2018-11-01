<cfoutput>

<cfset dOptions.single[1] = 300>
<cfset dOptions.single[2] = 200>
<cfset dOptions.single[3] = 150>
<cfset dOptions.single[4] = 50>
<cfset dOptions.single[5] = 25>
<cfset dSingleDefault = 150>

<cfset dOptions.monthly[1] = 100>
<cfset dOptions.monthly[2] = 50>
<cfset dOptions.monthly[3] = 30>
<cfset dOptions.monthly[4] = 25>
<cfset dOptions.monthly[5] = 20>
<cfset dMonthlyDefault = 25>


<cfif (THIS.Event.token EQ 'DM')
	AND THIS.EVENT.TeamID NEQ 0  
	AND THIS.EVENT.displayAMT NEQ 0>
        
	<cfset dSingleDefault = THIS.EVENT.displayAMT>
        
	<cfif THIS.EVENT.displayAMT EQ 500>
        
		<cfset dOptions.single[1] = 5000>
		<cfset dOptions.single[2] = 2500>
		<cfset dOptions.single[3] = 1500>
		<cfset dOptions.single[4] = 1000>
		<cfset dOptions.single[5] = 500>
            
	<cfelse>
        
		<cfset dOptions.single[1] = 10000>
		<cfset dOptions.single[2] = 5000>
		<cfset dOptions.single[3] = 2500>
		<cfset dOptions.single[4] = 1500>
		<cfset dOptions.single[5] = 1000>
        
	</cfif>
 	
</cfif>
<cfif THIS.Event.token EQ 'DM' AND THIS.EVENT.TeamID EQ 13479>
	<cfset dOptions.single[1] = 125>
	<cfset dOptions.single[2] = 85>
	<cfset dOptions.single[3] = 65>
	<cfset dOptions.single[4] = 45>
	<cfset dOptions.single[5] = 25>
</cfif>   

<form class="js_bcchf_donation" name="js_bcchf_donation" id="js_bcchf_donation" action="" method="post">
            

<!-- Step 1 - Your Donation -->
<div class="bcchf_step js_bcchf_step">
    <!-- Step 1 - Your Donation form content-->
    <section class="bcchf_step left bcchf_step1">
    <cfif NOT IsDefined("pty_date")><cfset pty_date= "#Now()#"></cfif>
    <!--- donation ID --->
    <input type="hidden" name="sup_pge_UUID" id="sup_pge_UUID" value="#sup_pge_UUID#" />
    <!--- gift type --->
    <input type="hidden" name="hiddenGiftType" id="hiddenGiftType" value="#THIS.EVENT.gift_type#" />
    <!--- gift date --->
    <input type="hidden" name="donationDate" value="#pty_date#" />
    <!--- email referal token --->
    <input type="hidden" name="emailReferal" value="#THIS.EVENT.emailReferral#" />
                            
    <input type="hidden" name="App_verifyToken" value="#APPLICATION.AppVerifyXDS#" />	
    <input type="hidden" name="uaosname" id="uaosname" value="" />
    <input type="hidden" name="uaosversion" id="uaosversion" value="" />
    <input type="hidden" name="uabrowsername" id="uabrowsername" value="" />
    <input type="hidden" name="uabrowsermajor" id="uabrowsermajor" value="" />
    <input type="hidden" name="uabrowserversion" id="uabrowserversion" value="" />
    <input type="hidden" name="uadevicename" id="uadevicename" value="" />
    <input type="hidden" name="uadevicetype" id="uadevicetype" value="" />
    <input type="hidden" name="uadevicevendor" id="uadevicevendor" value="" />
    
    <input type="hidden" name="ePhilanthropySource" id="ePhilanthropySource" value="#THIS.EVENT.ePhilSource#" />
    
    <input type="hidden" name="hiddenDonationPCType" id="hiddenDonationPCType" value="#hiddenDonationPCTypeDef#" />
    <input type="hidden" name="hiddenDonationType" id="hiddenDonationType" value="#THIS.EVENT.hiddenDonationType#" />
    <input type="hidden" name="hiddenFreqDay" id="hiddenFreqDay" value="1" />
    <input type="hidden" name="hiddenGiftAmount" id="hiddenGiftAmount" value="#THIS.EVENT.gift_onetime_other_value#" />
    <input type="hidden" name="hiddenTributeType" id="hiddenTributeType" value="#THIS.EVENT.hiddenTributeType#" />	
        
    <input type="hidden" name="hiddenEventToken" id="hiddenEventToken" value="#THIS.EVENT.token#" />
    <input type="hidden" name="hiddenEventCurrentYear" id="hiddenEventCurrentYear" value="#THIS.EVENT.CurrentYear#" />
    <input type="hidden" name="hiddenTeamID" id="hiddenTeamID" value="#THIS.EVENT.TeamID#" />
    <input type="hidden" name="hiddenSupID" id="hiddenSupID" value="#THIS.EVENT.SupID#" />
    <input type="hidden" name="hiddentype" id="hiddentype" value="#THIS.EVENT.SupportType#">
    
    <input type="hidden" id="bcchf_encouragement_msg" name="bcchf_encouragement_msg" value="">
        
    <cfif IsDefined('sup_pge_UUID') AND sup_pge_UUID NEQ ''>
    <!--- there is an ID in the URL, load info --->
    
    	<h3>Your Donation</h3>
        <p class="bcchf_message"><em>Fields marked with * are required.</em></p>

        <!-- Donation type -->
        <section>
            <label class="bcchf_stack_label">The donation I'd like to make is*:</label>
            <input type="radio" id="bcchf_monthly" name="bcchf_donation_type" value="Monthly" <cfif THIS.EVENT.hiddenDonationType EQ 'monthly'>checked</cfif> required/>
            <label class="bcchf_btn" for="bcchf_monthly">Monthly</label>
            <input type="radio" id="bcchf_once" name="bcchf_donation_type" value="Single" <cfif THIS.EVENT.hiddenDonationType EQ 'single'>checked</cfif> required/>
            <label class="bcchf_btn" for="bcchf_once">One-time</label>
            <p class="bcchf_message error hide"><em></em></p>
        </section>

		<!--- amount set from lookup in JS --->
        <!-- Donation amount -->
        <section class="js_bcchf_donation_amt_container" data-nav-action="next">
            <label class="bcchf_stack_label">Please accept my gift of*:</label>
            
            <!-- Monthly donation amounts -->
            <div class="bcchf_radio">
                <input type="radio" id="bcchf_100" name="bcchf_gift_amount" data-monthly="100" data-once="300" value="100" required/>
                <div class="bcchf_radio_label">
                    <div class="bcchf_radio_top">
                        <div class="bcchf_check center vertical_align"></div>
                    </div>
                    <div class="bcchf_radio_bottom">
                        <p class="vertical_align js_bcchf_donation_amt">$100/mo.</p>
                    </div>
                </div>
                <label for="bcchf_100"></label>
            </div>
            <div class="bcchf_radio">
                <input type="radio" id="bcchf_50" name="bcchf_gift_amount" data-monthly="50" data-once="200" value="50"  required/>
                <div class="bcchf_radio_label">
                    <div class="bcchf_radio_top">
                        <div class="bcchf_check center vertical_align"></div>
                    </div>
                    <div class="bcchf_radio_bottom">
                        <p class="vertical_align js_bcchf_donation_amt">$50/mo.</p>
                    </div>
                </div>
                <label for="bcchf_50"></label>
            </div>
            <div class="bcchf_radio">
                <input type="radio" id="bcchf_30" name="bcchf_gift_amount" data-monthly="30" data-once="150" value="30" data-once_default="true" required/>
                <div class="bcchf_radio_label">
                    <div class="bcchf_radio_top">
                        <div class="bcchf_check center vertical_align"></div>
                    </div>
                    <div class="bcchf_radio_bottom">
                        <p class="vertical_align js_bcchf_donation_amt">$30/mo.</p>
                    </div>
                </div>
                <label for="bcchf_30"></label>
            </div>
            <div class="bcchf_radio">
                <input type="radio" id="bcchf_25" name="bcchf_gift_amount" data-monthly="25" data-once="50" value="25" data-monthly_default="true" checked required/>
                <div class="bcchf_radio_label">
                    <div class="bcchf_radio_top">
                        <div class="bcchf_check center vertical_align"></div>
                    </div>
                    <div class="bcchf_radio_bottom">
                        <p class="vertical_align js_bcchf_donation_amt">$25/mo.</p>
                    </div>
                </div>
                <label for="bcchf_25"></label>
            </div>
            <div class="bcchf_radio">
                <input type="radio" id="bcchf_20" name="bcchf_gift_amount" data-monthly="20" data-once="25" value="20" required/>
                <div class="bcchf_radio_label">
                    <div class="bcchf_radio_top">
                        <div class="bcchf_check center vertical_align"></div>
                    </div>
                    <div class="bcchf_radio_bottom">
                        <p class="vertical_align js_bcchf_donation_amt">$20/mo.</p>
                    </div>
                </div>
                <label for="bcchf_20"></label>
            </div>
            <div class="bcchf_radio">
                <input type="radio" class="js_bcchf_radio_with_text" id="bcchf_other" name="bcchf_gift_amount" value="" required/>
                <div class="bcchf_radio_label">
                    <div class="bcchf_radio_top">
                        <div class="bcchf_check center vertical_align"></div>
                    </div>
                    <div class="bcchf_radio_bottom">
                        <p class="vertical_align">Other...</p>
                        <input type="text" name="bcchf_other_amt" id="bcchf_other_amt" />
                    </div>
                </div>
                <label for="bcchf_other"></label>
            </div>
            
            
            
            <p class="bcchf_message error"><em></em></p>
        </section>

        <!-- Donation monthly frequency -->
        <section class="js_bcchf_monthly" data-nav-action="next">
            <label class="bcchf_stack_label">Each month make my donation on*:</label>
            <input type="radio" id="bcchf_1st" name="bcchf_donation_on" value="1" checked required/>
            <label class="bcchf_btn" for="bcchf_1st">1st</label>

            <input type="radio" id="bcchf_15th" name="bcchf_donation_on" value="15" required/>
            <label class="bcchf_btn" for="bcchf_15th">15th</label>
            <p class="bcchf_message error"><em></em></p>
        </section>
        
        
        
        <cfif THIS.EVENT.tribType_display EQ 'none'>
        <input type="hidden" name="bcchf_donation_honour" id="bcchf_support" value="support">
        </cfif>
        <!-- Donation in honour of -->
        <section class="bcchf_in_honour<cfif THIS.EVENT.tribType_display EQ 'none'> hide</cfif>">
            <label class="bcchf_stack_label">Please make my donation*:</label>
            <input type="radio" id="bcchf_general" name="bcchf_donation_honour" value="general" <cfif THIS.EVENT.gift_tributeType_generalCHKstatus EQ 'yes'>checked</cfif> required/>
            <label class="bcchf_btn" for="bcchf_general">General</label>

            <input type="radio" id="bcchf_in_honour" name="bcchf_donation_honour" value="honour" <cfif THIS.EVENT.gift_tributeType_honCHKstatus EQ 'yes'>checked</cfif> required/>
            <label class="bcchf_btn" for="bcchf_in_honour">In Honour</label>

            <input type="radio" id="bcchf_in_memory" name="bcchf_donation_honour" value="memory" <cfif THIS.EVENT.gift_tributeType_memCHKstatus EQ 'yes'>checked</cfif> required/>
            <label class="bcchf_btn" for="bcchf_in_memory">In Memory</label>
			<!--- --->
            <input type="radio" id="bcchf_pledge" name="bcchf_donation_honour" value="pledge" <cfif THIS.EVENT.gift_tributeType_pledgeCHKstatus EQ 'yes'>checked</cfif> required/>
            <label class="bcchf_btn" for="bcchf_pledge">Pledge Payment</label>
            
            <p class="bcchf_message error"><em></em></p>

            <!-- If in honour of is chosen, show this -->
            <div class="bcchf_input_container js_bcchf_donation_honour js_bcchf_in_honour hide">
                <label for="bcchf_in_honour_name">In Honour of*:</label>
                <input type="text" id="bcchf_in_honour_name" name="bcchf_in_honour_name" required/>
                <p class="bcchf_message error hide"><em>Your first name must not contain spaces.</em></p>
            </div>

            <!-- If in memory of is chosen, show this -->
            <div class="bcchf_input_container js_bcchf_donation_honour js_bcchf_in_memory hide">
                <label for="bcchf_in_memory_name">In Memory of*:</label>
                <input type="text" id="bcchf_in_memory_name" name="bcchf_in_memory_name" required/>
                <p class="bcchf_message error hide"><em>Your first name must not contain spaces.</em></p>
            </div>

            <!-- If in honour of or memory of is chosen, show this -->
            <div class="bcchf_checkbox_container js_bcchf_donation_honour js_bcchf_in_memory js_bcchf_in_honour hide">
                <div class="bcchf_checkbox">
                    <input type="checkbox" id="bcchf_acknowledgement" name="bcchf_acknowledgement" value="1" />
                    <label for="bcchf_acknowledgement"></label>
                </div>
                <p>I would like to send an acknowledgement message once I've completed my donation.</p>
            </div>

            <!-- if pledge payment is chosen, show this -->
            <div class="bcchf_input_container js_bcchf_donation_honour js_bcchf_pledge hide">
                <label for="bcchf_donor_id">Donor ID:</label>
                <input id="bcchf_donor_id" name="bcchf_donor_id" type="text" />
                <p class="bcchf_donor_help">Your Donor ID can be found on the bottom right of your detached pledge form.</p>
                <span class="bcchf_valid_checkmark"></span>
                <p class="bcchf_message error hide"><em></em></p>
            </div>
        </section>

        <!-- Compelled by -->
        <div class="bcchf_input_container bcchf_dropdown_container bcchf_dropdown_stacked">
            <div class="bcchf_text_container">
                <label for="bcchf_compelledby">What compelled you to give today?</label>
                <div class="bcchf_dropdown js_bcchf_custom_select">
                    <!-- This ul will serve as the select tag and li as options. It must match the element in select tag underneath -->
                    <!-- csweeting: we'll need to add conditionals here to load the previously selected option in this area -->
                    <ul class="">
                        <li data-value="" class="active"><span>Optional</span></li>
                        <li data-value="I work at BC Children’s Hospital">I work at BC Children’s Hospital</li>
                        <li data-value="I’ve been impacted by the care provided">I’ve been impacted by the care provided</li>
                        <li data-value="I saw a billboard/outdoor ad">I saw a billboard/outdoor ad</li>
                        <li data-value="I received mail or an email">I received mail or an email</li>
                        <li data-value="I saw it on social media">I saw it on social media</li>
                        <li data-value="I saw the TV commercial">I saw the TV commercial</li>
                        <li data-value="My workplace fundraises">My workplace fundraises</li>
                        <li data-value="I saw it at a store">I saw it at a store</li>
                        <li data-value="Someone told me about the snowball fight">Someone told me about the snowball fight</li>
                        <li data-value="Other">Other</li>
                    </ul>
                    <!-- This is hidden due to select tag being unstyleable -->
                    <select name="bcchf_compelledby" id="bcchf_compelledby">
                        <option value="" selected="selected">Optional</option>
                        <option value="I work at BC Children’s Hospital">I work at BC Children’s Hospital</option>
                        <option value="I’ve been impacted by the care provided">I’ve been impacted by the care provided</option>
                        <option value="I saw a billboard/outdoor ad">I saw a billboard/outdoor ad</option>
                        <option value="I received mail or an email">I received mail or an email</option>
                        <option value="I saw it on social media">I saw it on social media</option>
                        <option value="I saw the TV commercial">I saw the TV commercial</option>
                        <option value="My workplace fundraises">My workplace fundraises</option>
                        <option value="I saw it at a store">I saw it at a store</option>
                        <option value="Someone told me about the snowball fight">Someone told me about the snowball fight</option>
                        <option value="Other">Other</option>
                    </select>
                    
                    <label class="bcchf_dropdown_arrow">&nbsp;</label>
                </div>
            </div>
        </div>

        <!-- Encouragement message -->
        <section class="bcchf_encouragement">
            <div class="bcchf_text_container js_bcchf_text_container">
                <label class="bcchf_stack_label">Enter a message of encouragement (Optional).</label>
                <textarea id="bcchf_encouragement_msg" name="bcchf_encouragement_msg">#THIS.EVENT.topHeaderDonationSupportMessage#</textarea>
                <p class="align_right"><small><span class="js_bcchf_textbox_counter">0</span>/180 Characters</small></p>
                <p class="bcchf_message error hide"><em>Your first name must not contain spaces.</em></p>
            </div>

            <div class="bcchf_checkbox_container">
                <div class="bcchf_checkbox">
                    <input type="checkbox" id="bcchf_hide_message" name="bcchf_hide_message" value="1"/>
                    <label for="bcchf_hide_message"></label>
                </div>
                <p>Do not show my message in the honour roll.</p>
            </div>
        </section>

        <!-- Donor name -->
        <section class="bcchf_donor_name">
            <div class="js_bcchf_donor_container js_bcchf_personal">
                <div class="bcchf_input_container">
                    <label for="bcchf_donor_first_name">Your First Name:</label>
                    <input type="text" id="bcchf_donor_first_name" name="bcchf_donor_first_name" value="#SUPPORTER.fName#" />
                    <!--- <span class="bcchf_valid_checkmark"></span> --->
                    <a href="js_bcchf_corporate" class="js_bcchf_donor_corporate">Corporate Donation?</a>
                    <p class="bcchf_message error hide"><em>Your first name must not contain spaces.</em></p>
                </div>

                <div class="bcchf_input_container">
                    <label for="bcchf_donor_last_name">Your Last Name:</label>
                    <input type="text" id="bcchf_donor_last_name" name="bcchf_donor_last_name" value="#SUPPORTER.lName#" />
                    <!--- <span class="bcchf_valid_checkmark"></span> --->
                    <p class="bcchf_message error hide"><em></em></p>
                </div>
            </div>

            <div class="bcchf_input_container js_bcchf_donor_container js_bcchf_corporate hide">
                <label for="bcchf_donor_company_name">Your Company Name:</label>
                <input type="text" id="bcchf_donor_company_name" name="bcchf_donor_company_name"/>
                <!--- <span class="bcchf_valid_checkmark"></span> --->
                <a href="js_bcchf_personal" class="js_bcchf_donor_personal">Personal Donation?</a>
                <p class="bcchf_message error hide"><em></em></p>
            </div>

            <div class="bcchf_checkbox_container">
                <div class="bcchf_checkbox">
                    <input type="checkbox" id="bcchf_hide_name" name="bcchf_hide_name" value="1"/>
                    <label for="bcchf_hide_name"></label>
                </div>
                <!--- 
                <cfif THIS.EVENT.token EQ 'MW'>
                <p style="padding-top:1px;">Do not show my name in the honour roll <br />that displays both online and on the Miracle Weekend televised scroll.</p>
                <cfelse> </cfif>--->
                <p>Do not show my name in the honour roll.</p>
                
            </div>
        </section>

        <!-- Special instructions -->
        <section>
            <div class="bcchf_text_container js_bcchf_text_container">
                <label class="bcchf_stack_label">Are there any special instructions for your donation?</label>
                <textarea id="bcchf_special_instr" name="bcchf_special_instr"></textarea>
                <p class="align_right"><small><span class="js_bcchf_textbox_counter">0</span>/180 Characters</small></p>
            </div>
        </section>
    
    <cfelse>
    <!---- no ID --- default donation form --->
    
        <h3>Your Donation</h3>
        <p class="bcchf_message"><em>Fields marked with * are required.</em></p>

        <!-- Donation type -->
        <section>
            <label class="bcchf_stack_label">The donation I'd like to make is*:</label>
            <input type="radio" id="bcchf_monthly" name="bcchf_donation_type" value="Monthly" <cfif THIS.EVENT.hiddenDonationType EQ 'monthly'>checked</cfif> required/>
            <label class="bcchf_btn" for="bcchf_monthly">Monthly</label>
            <input type="radio" id="bcchf_once" name="bcchf_donation_type" value="Single" <cfif THIS.EVENT.hiddenDonationType EQ 'single'>checked</cfif> required/>
            <label class="bcchf_btn" for="bcchf_once">One-time</label>
            <!--- <cfif IsDefined('URL.lp')><cfelse>
            <input type="radio" id="bcchf_tribute" name="bcchf_donation_type" value="hon/mem" <cfif THIS.EVENT.hiddenDonationType EQ 'hom/mem'>checked</cfif> required/>
            <label class="bcchf_btn" for="bcchf_tribute">In Honour / Memory</label>
            </cfif> --->
            <p class="bcchf_message error hide"><em></em></p>
        </section>

        <!-- Donation amount -->
        <section class="js_bcchf_donation_amt_container" data-nav-action="next">
            <label class="bcchf_stack_label">Please accept my gift of*:</label>
            <!-- Monthly donation amounts -->
            <div class="bcchf_radio">
                <input type="radio" id="bcchf_100" name="bcchf_gift_amount" data-monthly="100" data-once="#dOptions.single[1]#" value="100" <cfif dOptions.single[1] EQ dSingleDefault>data-once_default="true"</cfif> required/>
                <div class="bcchf_radio_label">
                    <div class="bcchf_radio_top">
                        <div class="bcchf_check center vertical_align"></div>
                    </div>
                    <div class="bcchf_radio_bottom">
                        <p class="vertical_align js_bcchf_donation_amt">$100/mo.</p>
                    </div>
                </div>
                <label for="bcchf_100"></label>
            </div>
            <div class="bcchf_radio">
                <input type="radio" id="bcchf_50" name="bcchf_gift_amount" data-monthly="50" data-once="#dOptions.single[2]#" value="50" <cfif dOptions.single[2] EQ dSingleDefault>data-once_default="true"</cfif> required/>
                <div class="bcchf_radio_label">
                    <div class="bcchf_radio_top">
                        <div class="bcchf_check center vertical_align"></div>
                    </div>
                    <div class="bcchf_radio_bottom">
                        <p class="vertical_align js_bcchf_donation_amt">$50/mo.</p>
                    </div>
                </div>
                <label for="bcchf_50"></label>
            </div>
            <div class="bcchf_radio">
                <input type="radio" id="bcchf_30" name="bcchf_gift_amount" data-monthly="30" data-once="#dOptions.single[3]#" value="30" <cfif dOptions.single[3] EQ dSingleDefault>data-once_default="true"</cfif> required/>
                <div class="bcchf_radio_label">
                    <div class="bcchf_radio_top">
                        <div class="bcchf_check center vertical_align"></div>
                    </div>
                    <div class="bcchf_radio_bottom">
                        <p class="vertical_align js_bcchf_donation_amt">$30/mo.</p>
                    </div>
                </div>
                <label for="bcchf_30"></label>
            </div>
            <div class="bcchf_radio">
                <input type="radio" id="bcchf_25" name="bcchf_gift_amount" data-monthly="25" data-once="#dOptions.single[4]#" value="25" data-monthly_default="true" <cfif dOptions.single[4] EQ dSingleDefault>data-once_default="true"</cfif> checked required/>
                <div class="bcchf_radio_label">
                    <div class="bcchf_radio_top">
                        <div class="bcchf_check center vertical_align"></div>
                    </div>
                    <div class="bcchf_radio_bottom">
                        <p class="vertical_align js_bcchf_donation_amt">$25/mo.</p>
                    </div>
                </div>
                <label for="bcchf_25"></label>
            </div>
            <div class="bcchf_radio">
                <input type="radio" id="bcchf_20" name="bcchf_gift_amount" data-monthly="20" data-once="#dOptions.single[5]#" value="20" <cfif dOptions.single[5] EQ dSingleDefault>data-once_default="true"</cfif> required/>
                <div class="bcchf_radio_label">
                    <div class="bcchf_radio_top">
                        <div class="bcchf_check center vertical_align"></div>
                    </div>
                    <div class="bcchf_radio_bottom">
                        <p class="vertical_align js_bcchf_donation_amt">$20/mo.</p>
                    </div>
                </div>
                <label for="bcchf_20"></label>
            </div>
            <div class="bcchf_radio">
                <input type="radio" class="js_bcchf_radio_with_text" id="bcchf_other" name="bcchf_gift_amount" value="" required/>
                <div class="bcchf_radio_label">
                    <div class="bcchf_radio_top">
                        <div class="bcchf_check center vertical_align"></div>
                    </div>
                    <div class="bcchf_radio_bottom">
                        <p class="vertical_align">Other...</p>
                        <input type="text" name="bcchf_other_amt" />
                    </div>
                </div>
                <label for="bcchf_other"></label>
            </div>
            <p class="bcchf_message error"><em></em></p>
        </section>

        <!-- Donation monthly frequency -->
        <section class="js_bcchf_monthly" data-nav-action="next">
            <label class="bcchf_stack_label">Each month make my donation on*:</label>
            <input type="radio" id="bcchf_1st" name="bcchf_donation_on" value="1st" checked required/>
            <label class="bcchf_btn" for="bcchf_1st">1st</label>

            <input type="radio" id="bcchf_15th" name="bcchf_donation_on" value="15th" required/>
            <label class="bcchf_btn" for="bcchf_15th">15th</label>
            <p class="bcchf_message error"><em></em></p>
        </section>
        
        
        <!-- Donation in honour of -->
        <section class="bcchf_in_honour <cfif IsDefined('URL.lp')>hide<cfelse></cfif>">
            <!-- in honour or memory option -->
            <div class="bcchf_checkbox_container">
                <div class="bcchf_checkbox">
                    <input type="checkbox" id="bcchf_tribute" name="bcchf_tribute" value="1" />
                    <label for="bcchf_tribute"></label>
                </div>
                <p>I would like to dedicate my gift in honour/memory of someone special<br /><strong><small>For gifts of $200 or more, we’ll add your loved one’s name to our Tribute Tree in the lobby of the hospital.</small></strong></p>
            </div>
            
            
            <div class="js_bcchf_donation_honmem js_tribute hide">
            <!--- <input type="radio" id="bcchf_general" name="bcchf_donation_honour" value="general" <cfif THIS.EVENT.gift_tributeType_generalCHKstatus EQ 'yes'>checked</cfif> required/>
            <label class="bcchf_btn" for="bcchf_general">General</label>
			--->
            <input type="radio" id="bcchf_in_honour" name="bcchf_donation_honour" value="honour" <cfif THIS.EVENT.gift_tributeType_honCHKstatus EQ 'yes'>checked</cfif> required/>
            <label class="bcchf_btn" for="bcchf_in_honour">In Honour</label>

            <input type="radio" id="bcchf_in_memory" name="bcchf_donation_honour" value="memory" <cfif THIS.EVENT.gift_tributeType_memCHKstatus EQ 'yes'>checked</cfif> required/>
            <label class="bcchf_btn" for="bcchf_in_memory">In Memory</label>
			<!--- 
            <input type="radio" id="bcchf_pledge" name="bcchf_donation_honour" value="pledge" <cfif THIS.EVENT.gift_tributeType_pledgeCHKstatus EQ 'yes'>checked</cfif> required/>
            <label class="bcchf_btn" for="bcchf_pledge">Pledge Payment</label>--->
            
            <p class="bcchf_message error"><em></em></p>
            </div>

            <!-- If in honour of is chosen, show this -->
            <div class="bcchf_input_container js_bcchf_donation_honour js_bcchf_in_honour hide">
                <label for="bcchf_in_honour_name">In Honour of*:</label>
                <input type="text" id="bcchf_in_honour_name" name="bcchf_in_honour_name" required/>
                <p class="bcchf_message error hide"><em>Your first name must not contain spaces.</em></p>
            </div>

            <!-- If in memory of is chosen, show this -->
            <div class="bcchf_input_container js_bcchf_donation_honour js_bcchf_in_memory hide">
                <label for="bcchf_in_memory_name">In Memory of*:</label>
                <input type="text" id="bcchf_in_memory_name" name="bcchf_in_memory_name" required/>
                <p class="bcchf_message error hide"><em>Your first name must not contain spaces.</em></p>
            </div>

            <!-- If in honour of or memory of is chosen, show this -->
            <div class="bcchf_checkbox_container js_bcchf_donation_honour js_bcchf_in_memory js_bcchf_in_honour hide">
                <div class="bcchf_checkbox">
                    <input type="checkbox" id="bcchf_acknowledgement" name="bcchf_acknowledgement" value="1" />
                    <label for="bcchf_acknowledgement"></label>
                </div>
                <p>I would like to send an acknowledgement card once I've completed my donation.</p>
            </div>

            <!-- if pledge payment is chosen, show this -->
            <div class="bcchf_input_container js_bcchf_donation_honour js_bcchf_pledge hide">
                <label for="bcchf_donor_id">Donor ID:</label>
                <input id="bcchf_donor_id" name="bcchf_donor_id" type="text" />
                <p class="bcchf_donor_help">Your Donor ID can be found on the bottom right of your detached pledge form.</p>
                <span class="bcchf_valid_checkmark"></span>
                <p class="bcchf_message error hide"><em></em></p>
            </div>
        </section>


        <!-- Compelled by -->
        <div class="bcchf_input_container bcchf_dropdown_container bcchf_dropdown_stacked">
            <div class="bcchf_text_container">
                <label for="bcchf_compelledby">What compelled you to give today?</label>
                <div class="bcchf_dropdown js_bcchf_custom_select">
                    <!-- This ul will serve as the select tag and li as options. It must match the element in select tag underneath -->
                    <!-- csweeting: no conditionals required here, fresh load here -->
                    <ul class="">
                        <li data-value="" class="active"><span>Optional</span></li>
                        <li data-value="I work at BC Children’s Hospital">I work at BC Children’s Hospital</li>
                        <li data-value="I’ve been impacted by the care provided">I’ve been impacted by the care provided</li>
                        <li data-value="I saw a billboard/outdoor ad">I saw a billboard/outdoor ad</li>
                        <li data-value="I received mail or an email">I received mail or an email</li>
                        <li data-value="I saw it on social media">I saw it on social media</li>
                        <li data-value="I saw the TV commercial">I saw the TV commercial</li>
                        <li data-value="My workplace fundraises">My workplace fundraises</li>
                        <li data-value="I saw it at a store">I saw it at a store</li>
                        <li data-value="Someone told me about the snowball fight">Someone told me about the snowball fight</li>
                        <li data-value="Other">Other</li>
                    </ul>
                    <!-- This is hidden due to select tag being unstyleable -->
                    <select name="bcchf_compelledby" id="bcchf_compelledby">
                        <option value="" selected="selected">Optional</option>
                        <option value="I work at BC Children’s Hospital">I work at BC Children’s Hospital</option>
                        <option value="I’ve been impacted by the care provided">I’ve been impacted by the care provided</option>
                        <option value="I saw a billboard/outdoor ad">I saw a billboard/outdoor ad</option>
                        <option value="I received mail or an email">I received mail or an email</option>
                        <option value="I saw it on social media">I saw it on social media</option>
                        <option value="I saw the TV commercial">I saw the TV commercial</option>
                        <option value="My workplace fundraises">My workplace fundraises</option>
                        <option value="I saw it at a store">I saw it at a store</option>
                        <option value="Someone told me about the snowball fight">Someone told me about the snowball fight</option>
                        <option value="Other">Other</option>
                    </select>
                    
                    <label class="bcchf_dropdown_arrow">&nbsp;</label>
                </div>
            </div>
        </div>		
        
        
        <!-- Encouragement message -->

        <!-- Donor name -->
        <section class="bcchf_donor_name hide">
            <div class="js_bcchf_donor_container js_bcchf_personal">
                <div class="bcchf_input_container">
                    <label for="bcchf_donor_first_name">Your First Name:</label>
                    <input type="text" id="bcchf_donor_first_name" name="bcchf_donor_first_name"/>
                    <!--- <span class="bcchf_valid_checkmark"></span> --->
                    <a href="js_bcchf_corporate" class="js_bcchf_donor_corporate" tabindex="-1">Corporate Donation?</a>
                    <p class="bcchf_message error hide"><em>Your first name must not contain spaces.</em></p>
                </div>

                <div class="bcchf_input_container">
                    <label for="bcchf_donor_last_name">Your Last Name:</label>
                    <input type="text" id="bcchf_donor_last_name" name="bcchf_donor_last_name"/>
                    <!--- <span class="bcchf_valid_checkmark"></span> --->
                    <p class="bcchf_message error hide"><em></em></p>
                </div>
            </div>

            <div class="bcchf_input_container js_bcchf_donor_container js_bcchf_corporate hide">
                <label for="bcchf_donor_company_name">Your Company Name:</label>
                <input type="text" id="bcchf_donor_company_name" name="bcchf_donor_company_name"/>
                <!--- <span class="bcchf_valid_checkmark"></span> --->
                <a href="js_bcchf_personal" class="js_bcchf_donor_personal" tabindex="-1">Personal Donation?</a>
                <p class="bcchf_message error hide"><em></em></p>
            </div>

            
        </section>

        <!-- Special instructions -->
        <section>
            <div class="bcchf_text_container js_bcchf_text_container">
                <label class="bcchf_stack_label">Are there any special instructions for your donation?</label>
                <textarea id="bcchf_special_instr" name="bcchf_special_instr"></textarea>
                <p class="align_right"><small><span class="js_bcchf_textbox_counter">0</span>/180 Characters</small></p>
            </div>
        </section>
    </cfif>
    </section>
    <!-- Step 1 - Your Donation form content-->

	

    
    
    <div class="clearfix"></div>
    <button type="button"  class="bcchf_next js_bcchf_next">Continue</button>
</div>
<!-- Step 1 - Your Donation -->


<!-- Step 2 - Your Information -->

<div class="bcchf_step js_bcchf_step ignore_validation">
    <h3>Your Information</h3>
    <p class="bcchf_message"><em>Fields marked with * are required.</em></p>

    <section>
        <!-- Company name -->
        <div class="bcchf_input_container">
            <label for="bcchf_company_name">Company Name:</label>
            <input type="text" id="bcchf_company_name" name="bcchf_company_name" value="#SUPPORTER.cName#" />
            <span class="bcchf_valid_checkmark"></span>
            <p class="bcchf_message error hide"><em></em></p>
        </div>
        
        <!-- If in honour of or memory of is chosen, show this -->
            <div class="bcchf_checkbox_container" style="padding-bottom:15px;">
                <div class="bcchf_checkbox">
                    <input type="checkbox" id="bcchf_corptax" name="bcchf_corptax" value="1" />
                    <label for="bcchf_corptax"></label>
                </div>
                <p>Please send a corporate tax receipt.</p>
            </div>

        <!-- Salutation -->
        <div class="bcchf_input_container bcchf_dropdown_container js_bcchf_input_container">
            <label for="bcchf_salutation">Salutation*:</label>
            <div class="bcchf_dropdown js_bcchf_custom_select">
                <!-- This ul will serve as the select tag and li as options. It must match the element in select tag underneath -->
                <ul class="">
                    <li <cfif SUPPORTER.TAXtitle EQ ''>class="active"</cfif> data-value=""><span>Please select one...</span></li>
                    <li <cfif SUPPORTER.TAXtitle EQ 'Mr.'>class="active"</cfif> data-value="Mr.">Mr.</li>
                    <li <cfif SUPPORTER.TAXtitle EQ 'Mrs.'>class="active"</cfif> data-value="Mrs.">Mrs.</li>
                    <li <cfif SUPPORTER.TAXtitle EQ 'Ms.'>class="active"</cfif> data-value="Ms.">Ms.</li>
                    <li <cfif SUPPORTER.TAXtitle EQ 'Miss'>class="active"</cfif> data-value="Miss">Miss</li>
                    <li <cfif SUPPORTER.TAXtitle EQ 'Mr. and Mrs.'>class="active"</cfif> data-value="Mr. and Mrs.">Mr. and Mrs.</li>
                    <li <cfif SUPPORTER.TAXtitle EQ 'Dr.'>class="active"</cfif> data-value="Dr.">Dr.</li>
                    <li <cfif SUPPORTER.TAXtitle EQ 'None'>class="active"</cfif> data-value="None">None</li>
                </ul>
                <!-- This is hidden due to select tag being unstyleable -->
                <select name="bcchf_salutation" id="bcchf_salutation" required>
                    <option value="">Please select one...</option>
                
                	<option value="Mr." <cfif SUPPORTER.TAXtitle EQ 'Mr.'>selected="selected"</cfif>>Mr. </option>							
              		<option value="Mrs." <cfif SUPPORTER.TAXtitle EQ 'Mrs.'>selected="selected"</cfif>>Mrs. </option>
              		<option value="Ms." <cfif SUPPORTER.TAXtitle EQ 'Ms.'>selected="selected"</cfif>>Ms. </option>
              		<option value="Miss" <cfif SUPPORTER.TAXtitle EQ 'Miss'>selected="selected"</cfif>>Miss </option>
              		<option value="Mr. and Mrs." <cfif SUPPORTER.TAXtitle EQ 'Mr. and Mrs.'>selected="selected"</cfif>>Mr. &amp; Mrs.</option>
              		<option value="Dr." <cfif SUPPORTER.TAXtitle EQ 'Dr.'>selected="selected"</cfif>>Dr. </option>							
              		<option value="None" <cfif SUPPORTER.TAXtitle EQ 'None'>selected="selected"</cfif>>None </option>
                
                </select>
                
                <label class="bcchf_dropdown_arrow">&nbsp;</label>
            </div>
            <span class="bcchf_valid_checkmark"></span>
            <p class="bcchf_message error"><em></em></p>
        </div>

        <!-- First name -->
        <div class="bcchf_input_container js_bcchf_input_container">
            <label for="bcchf_first_name">First Name*:</label>
            <input type="text" id="bcchf_first_name" name="bcchf_first_name" value="#SUPPORTER.fName#" required/>
            <span class="bcchf_valid_checkmark"></span>
            <p class="bcchf_message error hide"><em></em></p>
        </div>

        <!-- Middle initial -->
        <div class="bcchf_input_container">
            <label for="bcchf_info_initial">Middle Initial:</label>
            <input type="text" id="bcchf_info_initial" name="bcchf_middle_initial" maxlength="1"/>
            <span class="bcchf_valid_checkmark"></span>
            <p class="bcchf_message error hide"><em></em></p>
        </div>

        <!-- Last name -->
        <div class="bcchf_input_container js_bcchf_input_container">
            <label for="bcchf_last_name">Last Name*:</label>
            <input type="text" id="bcchf_last_name" name="bcchf_last_name" value="#SUPPORTER.lName#" required/>
            <span class="bcchf_valid_checkmark"></span>
            <p class="bcchf_message error hide"><em></em></p>
        </div>

        <!-- Email -->
        <div class="bcchf_input_container js_bcchf_input_container">
            <label for="bcchf_email" >Email*:</label>
            <input type="email" id="bcchf_email" name="bcchf_email" value="#SUPPORTER.email#" required/>
            <span class="bcchf_valid_checkmark"></span>
            <p class="bcchf_message error hide"><em></em></p>
        </div>

        <!-- Confirm email -->
        <div class="bcchf_input_container js_bcchf_input_container">
            <label for="bcchf_email_confirm">Confirm Email*:</label>
            <input type="email" id="bcchf_email_confirm" name="bcchf_email_confirm" value="#SUPPORTER.email#" required/>
            <span class="bcchf_valid_checkmark"></span>
            <p class="bcchf_message error hide"><em></em></p>
        </div>


        <!-- Address -->
        <div class="bcchf_input_container js_bcchf_input_container">
            <label for="bcchf_address">Address 1*:</label>
            <input type="text" id="bcchf_address" name="bcchf_address" value="#SUPPORTER.address#" required/>
            <span class="bcchf_valid_checkmark"></span>
            <p class="bcchf_message error hide"><em></em></p>
        </div>

        <!-- Address 2 -->
        <div class="bcchf_input_container">
            <label for="bcchf_address2">Address 2:</label>
            <input type="text" id="bcchf_address2" name="bcchf_address2" value="" />
            <span class="bcchf_valid_checkmark"></span>
            <p class="bcchf_message error hide"><em></em></p>
        </div>

        <!-- City -->
        <div class="bcchf_input_container js_bcchf_input_container">
            <label for="bcchf_city">City*:</label>
            <input type="text" id="bcchf_city" name="bcchf_city" value="#SUPPORTER.city#" required/>
            <span class="bcchf_valid_checkmark"></span>
            <p class="bcchf_message error hide"><em></em></p>
        </div>

        
        <!-- Province -->
        <div class="bcchf_input_container js_bcchf_input_container">
            <label for="bcchf_province">Province*:</label>
            <input type="text" id="bcchf_province" name="bcchf_province" value="#SUPPORTER.prov#" required/>
            <span class="bcchf_valid_checkmark"></span>
            <p class="bcchf_message error hide"><em></em></p>
        </div>

        
        <!-- Postal Code -->
        <div class="bcchf_input_container js_bcchf_input_container">
            <label for="bcchf_postal_code">Postal Code*:</label>
            <input type="text" id="bcchf_postal_code" name="bcchf_postal_code" value="#SUPPORTER.post#" required/>
            <span class="bcchf_valid_checkmark"></span>
            <p class="bcchf_message error hide"><em>Please enter your postal code.</em></p>
        </div>

        
        <!-- Province -->
        <div class="bcchf_input_container js_bcchf_input_container">
            <label for="bcchf_country">Country*:</label>
            <input type="text" id="bcchf_country" name="bcchf_country" value="#SUPPORTER.country#" required/>
            <span class="bcchf_valid_checkmark"></span>
            <p class="bcchf_message error hide"><em></em></p>
        </div>

        
        <!-- Phone -->
        <div class="bcchf_input_container js_bcchf_input_container">
            <label for="bcchf_phone">Phone*:</label>
            <input type="text" id="bcchf_phone" name="bcchf_phone" value="#SUPPORTER.phone#" required/>
            <span class="bcchf_valid_checkmark"></span>
            <p class="bcchf_message error hide"><em>Please enter your phone number.</em></p>
        </div>
    </section>
    <button type="button" class="bcchf_next js_bcchf_next">Continue</button>
    <p><a href="" class="bcchf_return js_bcchf_return">Back to previous page</a></p>

</div>
<!-- Step 2 - Your Information -->


<!-- Step 3 - Your Payment Details -->

<div class="bcchf_step bcchf_step3 js_bcchf_step ignore_validation">

    <h3>Your Payment Details</h3>
    <p class="bcchf_message" id="s3topMSG"><em>Your card will not be charged until you've had a chance to review all the information in the next and final step.</em></p>

    <!-- Tax receipt choices -->
    <section>
        <label class="bcchf_stack_label">Would you like BCCHF to provide you with a tax receipt?:</label>
        <input type="radio" id="bcchf_receipt_yes" name="bcchf_receipt" value="Yes" checked />
        <label class="bcchf_btn" for="bcchf_receipt_yes">Yes</label>
        <input type="radio" id="bcchf_receipt_no" name="bcchf_receipt" value="No"/>
        <label class="bcchf_btn" for="bcchf_receipt_no">No</label>
    </section>

    <!-- Payment details -->
    <section>
    	
        <p class="bcchf_payment_cta_monthly">Enter your credit card information below</p>
        
        <p class="bcchf_payment_cta hide">Enter your credit card information below or <a href="" class="bcchf_paypal replace"><span>Checkout with PayPal</span></a></p>
       

        <!-- Credit card number -->
        <div class="bcchf_input_container bcchf_cc_input js_bcchf_input_container">
            <label for="bcchf_cc_number1">Card Number*:</label>
            <input type="text" maxlength="16" id="bcchf_cc_number" value="" name="bcchf_cc_number" required/>
            <span class="bcchf_valid_checkmark"></span>
            <img class="cardoptions" src="images/icons/credit-cards.png" alt="Mastercard, Visa, or American Express"/>
            <p class="bcchf_message error hide"><em></em></p>
        </div>

        <!-- Credit card verification number -->
        <div class="bcchf_input_container js_bcchf_input_container">
            <label for="bcchf_cvv">CVV*:</label>
            <input type="text" id="bcchf_cvv" name="bcchf_cvv" value="" required maxlength="4"/>
            <span class="bcchf_valid_checkmark"></span>
            <p class="bcchf_message error hide"><em></em></p>
        </div>

        <!-- Cardholder Name -->
        <div class="bcchf_input_container js_bcchf_input_container">
            <label for="bcchf_cc_name">Cardholder*:</label>
            <input type="text" id="bcchf_cc_name" name="bcchf_cc_name" value="" required/>
            <span class="bcchf_valid_checkmark"></span>
            <p class="bcchf_message error hide"><em></em></p>
        </div>

        <!-- Expiry date -->
        <div class="bcchf_input_container js_bcchf_input_container">
            <label for="bcchf_expire_month">Expiry Date*:</label>
            <input type="text" class="js_bcchf_cc_expiry" id="bcchf_expire_month" name="bcchf_expire_month" placeholder="MM" maxlength="2" required/>
            <input type="text" class="js_bcchf_cc_expiry" id="bcchf_expire_year" name="bcchf_expire_year" placeholder="YY" maxlength="2" required/>
            <span class="bcchf_valid_checkmark"></span>
            <p class="bcchf_message error hide"><em></em></p>
        </div>

        <div class="bcchf_checkbox_container">
            <div class="bcchf_checkbox">
                <input type="checkbox" id="bcchf_allow_contact" name="bcchf_allow_contact" value="1"/>
                <label for="bcchf_allow_contact"></label>
            </div>
            <p>I allow the Foundation to contact me with information about my gift and how I can support BC&nbsp;Children's&nbsp;Hospital.</p>
        </div>
    </section>
    <button type="button" class="bcchf_next js_bcchf_next">Continue</button>
    <!--- <img src="images/icons/verisign.png" alt="VeriSign Secured" /> --->
    <p><a href="" class="bcchf_return js_bcchf_return">Back to previous page</a></p>
</div>
<!-- Step 3 - Your Payment Details -->


<!-- Final Step - Review your donation -->

<div class="bcchf_step bcchf_step_final js_bcchf_step">
    <h3>Review Your Donation</h3>
    <p class="bcchf_message"><em>After completing this step your card will be charged.</em></p>
    <p>Please review your information and make any necessary edits before submitting your dontation.</p>

    <section>
    <div style="display:none; font-family: 'Calibri', Verdana, Arial, sans-serif; line-height:1.3;" id="topExactMessage" class="error">
    
    </div>
    </section>
    
    
    <!-- Step 1 - Your Donation -->
    <section>
        <h4>Your Donation</h4>
        <ul class="js_bcchf_review">
            <li>Donation Type:  <span id="js_bcchf_donation_type"></span></li>
            <li>Amount:  $<span id="js_bcchf_gift_amount"></span></li>
            <li>Withdrawn on:  <span id="js_bcchf_donation_on"></span> of each month</li>
            <li>Special Instructions: <span id="js_bcchf_special_instr"></span></li>
        </ul>
        <button class="js_bcchf_goto" data-slide="0">Edit Your Donation</button>
    </section>

    <!-- Step 2 - Your Information -->
    <section>
        <h4>Your Information</h4>
        <ul class="js_bcchf_review">
            <li>Company Name: <span id="js_bcchf_company_name"></span></li>
            <li>Salutation: <span id="js_bcchf_salutation"></span></li>
            <li>First Name: <span id="js_bcchf_first_name"></span></li>
            <li>Last Name: <span id="js_bcchf_last_name"></span></li>
            <li>Email: <span id="js_bcchf_email"></span></li>
            <li>Address 1: <span id="js_bcchf_address"></span></li>
            <li>Address 2: <span id="js_bcchf_address2"></span></li>
            <li>City: <span id="js_bcchf_city"></span></li>
            <li>Province: <span id="js_bcchf_province"></span></li>
            <li>Postal Code: <span id="js_bcchf_postal_code"></span></li>
            <li>Country: <span id="js_bcchf_country"></span></li>
            <li>Phone: <span id="js_bcchf_phone"></span></li>
        </ul>
        <button class="js_bcchf_goto" data-slide="1">Edit Your Information</button>
    </section>

    <!-- Step 3 - Your Payment Details -->
    <section>
        <h4>Your Payment Details</h4>
        <ul class="js_bcchf_review">
            <li>Cardholder Name: <span id="js_bcchf_cc_name"></span></li>
            <li>Credit Card No: **** **** **** <span id="js_bcchf_cc_number"></span></li>
            <li>Expiry Date: <span id="js_bcchf_expire_month"></span> / <span id="js_bcchf_expire_year"></span></li>
        </ul>
        <button class="js_bcchf_goto" data-slide="2">Edit Your Payment Details</button>
    </section>
    
    <section>
    <div id="exactResponseNegative" style="display:none; font-family: 'Calibri', Verdana, Arial, sans-serif; line-height:1.3;" class="error">&nbsp;</div>
    </section>

    <button type="button" class="bcchf_next js_bcchf_submit">Submit Donation</button>
    <p><a href="" class="bcchf_return js_bcchf_return">Back to previous page</a></p>
</div>

</form>


                
</cfoutput>