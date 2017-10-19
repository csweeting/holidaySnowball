<cftry>
<cfoutput>
<cfsilent>

<cfhttp
result="result"
method="get"
url="http://secure.bcchf.ca/API/api.cfm/event/#THIS.EVENT.gift_type#/RecentDon.json"
username="SHPAPI"
password="NoPassPublic">

<cfhttpparam type="url" name="rDons" value="9" />

</cfhttp>




<!--- --->
<cfif result.responseheader.Status_Code EQ 200>

 
<cfset SHPevent = DeserializeJSON(toString( result.fileContent ))>
<cfset honRollDsplay = 1>

<cfelse>
 
<cfset honRollDsplay = 0> 

</cfif> 

</cfsilent>

<!---  
<cfdump var="#result#" expand="yes">
<cfdump var="#SHPevent#" expand="no">  --->

<cfset HRAPIlen = ArrayLen(SHPevent.recentDon)>

<cfset HRdisplayLen = HRlen>
<cfif HRdisplayLen GT HRAPIlen>
	<cfset HRdisplayLen = HRAPIlen>
</cfif>

<!--- --->
<cfif honRollDsplay EQ 1>

<div class="bcchf_honour #HRloc#">
<ul>
    <li><h3>Honour Roll</h3></li>
    
    <cfloop index="t" from="1" to="#HRdisplayLen#">
    <cfif SHPevent.recentDon[t].RemScroll EQ 0>
    <li>
        <p><span>#DollarFormat(SHPevent.recentDon[t].Amount)#</span>
        <cfif SHPevent.recentDon[t].frequency EQ 'Monthly'>
        <em>Monthly gift</em>
        </cfif></p>
        <p>Donated by #SHPevent.recentDon[t].Name#</p>
        <cfif SHPevent.recentDon[t].ShowMSG EQ 1>
        <p><small>#SHPevent.recentDon[t].Message#</small></p>
        </cfif>
    </li>
    </cfif>
    </cfloop>
    
</ul>
</div>

<cfelse>

<div class="bcchf_honour #HRloc#">
<ul>
    <li><h3>Honour Roll</h3></li>
    
    <li>Error loading Honour Roll
    </li>
    
</ul>
</div> 



</cfif>
    
</cfoutput>

<cfcatch type="any">


<!---  ---></li>
</ul>
</div>
<cfdump var="#cfcatch#" expand="no">
</cfcatch>
</cftry>
