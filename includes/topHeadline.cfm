<cfoutput>
<cfif THIS.EVENT.token EQ 'HolidaySnowball'>
	<h1>DONATE<cfif IsDefined('URL.lp')> TO PARTICIPATE</cfif></h1>
    <section class="bcchf_header">
        <p>Donating only takes a minute or two, and when you're done you'll get your snowball for the Big BC Snowball Fight for Kids. Thank you for participating and helping us make the holidays brighter for thousands of kids and their families.</p>
    </section>
<cfelse>
<cfif THIS.EVENT.topHeaderDonationSupportMessage EQ ''>
	<h1>DONATE NOW</h1>
<cfelse>
	<h1 style="padding-bottom:1px;">DONATE NOW</h1>
    <cfset THIS.EVENT.topHeaderDonationSupportMessage = Replace(THIS.EVENT.topHeaderDonationSupportMessage, '<br />', '')>
	<h2 style="padding-bottom:20px;">#THIS.EVENT.topHeaderDonationSupportMessage#</h2>
</cfif>


<section class="bcchf_header">
    <div class="bcchf_header_image">
	<cfif THIS.EVENT.token EQ 'MW'
		OR THIS.EVENT.token EQ 'MMP'>
        <img src="images/decorations/2017MWheader.png" />
    <cfelseif THIS.EVENT.token EQ 'Holiday'>
        <img src="images/decorations/GT_Holiday.jpg" width="150" />
	<cfelseif THIS.EVENT.token EQ 'Heart'>
        <img src="images/decorations/GT_Heart.jpg" width="150" />
	<cfelseif THIS.EVENT.token EQ 'GrindForKids'>
        <img src="https://secure.bcchf.ca/SuperheroPages/userImages/GrindForKids.png" width="150" />
    <cfelseif THIS.EVENT.token EQ 'Ocean'>
        <img src="https://secure.bcchf.ca/images/SuperheroPages/Ocean/OceanRadiothon.png" width="150" />  
    <cfelse>
        <img src="images/decorations/bcchf-header-1.jpg" />
    </cfif>
    </div>
    <cfif THIS.EVENT.token EQ 'SOC'>
    <h2>Helping Kids Shine.</h2>
    <cfelseif THIS.EVENT.token EQ 'Holiday'>
    <h2>Give a gift that really matters.</h2>
    <cfelseif THIS.EVENT.token EQ 'Heart'>
    <h2>Donors like you help us take care of children's hearts from all across BC.</h2>
    <cfelseif THIS.EVENT.token EQ 'May'>
    <h2>As long as kids need us, we need you.</h2>
    <cfelseif THIS.EVENT.token EQ 'Ocean'>
    <h2>On average, 7 kids from Vancouver Island get treated at BC Children's Hospital every single day.</h2>
    <cfelse>
    <h2>Donors like you help us take care of BC's sickest children.</h2>
	</cfif>
    
    <cfif THIS.EVENT.token EQ 'MW'
		OR THIS.EVENT.token EQ 'MMP'
		OR THIS.EVENT.token EQ 'GrindForKids'>
        
        <p>Your donation #THIS.EVENT.topHeaderDonationSupportMessage# will help provide critical funding for the most urgent health-care needs of BC's children and youth within and beyond the hospital's walls.</p>
    <cfelseif THIS.EVENT.token EQ 'Holiday'>
    	<p>Continuing to give kids in British Columbia personalized care with world-class caregivers, and life-saving equipment and facilities requires donations from people like you. Please think of those families who can't be home together this time of year, and give a gift that really matters.</p>
	<cfelseif THIS.EVENT.token EQ 'Heart'>
    	<p>With 10,000 patient visits annually, the pediatric cardiology program is one of the busiest at BC Children's Hospital.  Thank you for your support.</p>
    <cfelseif THIS.EVENT.token EQ 'May'>
    	<p>Our need is great. But the promise is so much greater. By helping support our areas of need you're improving lives across BC so that every kid can have a childhood.</p>
    <cfelseif THIS.EVENT.token EQ 'Ocean'>
    	<p>Your gift today will help purchase 45 temporal thermometers urgently needed in our Oncology department as well as support the critical research and lifesaving equipment that improves the lives of tens of thousands of young patients across BC.</p>
    <cfelse>
    	<p>Thank you for supporting the most urgent health needs of children in BC and the Yukon. Your generosity allows us to improve the lives of tens of thousands of patients and their families each year.</p>
	</cfif>

    <div class="clearfix"></div>
</section>
</cfif>
</cfoutput>