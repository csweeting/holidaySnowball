<cfoutput>  
<!--- this is the layout of the receipt..
	2 options - BCCHF or HK ---> 
 		
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
    <html>
    <head>
    <style type="text/css">

div##logo, div##logoHK,
div##title, div##titleHK,
div##donorTitle,
div##donor,
div##donorAddress,
div##donorAddressHK,
div##receiptInfo,
div##receiptInfoTitle,
div##receiptAmount,
div##receiptAmountTitle,
div##cutLine,
div##receiptGraphic,
div##receiptGraphicHKleft,
div##receiptGraphicHKright,
div##footerWill,
div##footerAddress, div##footerAddressHK,
div##CICHtag,
div##HKBCCHFtag,
div##authSig {
	position: absolute ;
	font-family: "futura-pt",Verdana, Geneva, sans-serif;
}


div##logo {
	left: 30px ;
	top: 5px ;
	width: 250px ;
}

div##logoHK {
	left: 280px ;
	top: 5px ;
	width: 250px ;
}

div##title {
	left: 350px ;
	top: 40px ;
	width: 400px ;
}

div##titleHK {
	left: 400px ;
	top: 190px ;
	width: 400px ;
}

div##donorAddress {
	left: 50px ;
	top: 190px ;
	width: 500px ;
	font-size: 16px;
	line-height:20px;
}

div##donorAddressHK {
	left: 50px ;
	top: 190px ;
	width: 500px ;
	font-size: 16px;
	line-height:20px;
}

<cfset donorTop = 270>
<cfset receiptInfoTop = 340>

<cfif GIFT.RECEIPT.issuer EQ 'HK'>
	<cfset donorTop = donorTop + 40>
	<cfset receiptInfoTop = receiptInfoTop + 40>
</cfif>

div##donorTitle {
	left: 50px ;
	top: #donorTop#px ;
	width: 200px ;
	font-size: 16px;
	line-height:20px;
}

div##donor {
	left: 225px ;
	top: #donorTop#px ;
	width: 500px ;
	font-size: 16px;
	line-height:20px;
}

div##receiptInfoTitle {
	left: 50px ;
	top: #receiptInfoTop#px ;
	width: 200px ;
	font-size: 12px;
	line-height:15px;
}

div##receiptInfo {
	left: 200px ;
	top: #receiptInfoTop#px ;
	width: 150px ;
	font-size: 12px;
	line-height:15px;
}

div##receiptAmountTitle {
	left: 400px ;
	top: 340px ;
	width: 300px ;
	font-size: 12px;
	line-height:15px;
}

div##receiptAmount{
	left: 625px ;
	top: 340px ;
	width: 100px ;
	font-size: 12px;
	line-height:15px;
	text-align:right;
}

div##authSig{
	left: 390px;
	top: 410px;
	width: 364px;
	text-align:center;
	font-size: 12px;
	line-height:16px;
}

div##cutLine {
	left: 30px ;
	top: 480px ;
	width: 500px ;
}

div##receiptGraphic {
	left: 50px ;
	top: 525px ;
	width: 400px ;
	text-align:center;
}

div##CICHtag {
	left: 50px;
	top: 525px;
	width: 800px;
	text-align: left;
	font-size: 14px;
	line-height: 18px;	
}

div##receiptGraphicHKleft {
	left: 50px ;
	top: 580px ;
	width: 200px ;
	text-align:left;
}

div##HKBCCHFtag{
	left: 475px;
	top: 590px;
	width: 350px;
	text-align:left;
	font-size: 14px;
	line-height: 18px;
}

div##receiptGraphicHKright {
	left: 475px ;
	top: 660px ;
	width: 200px ;
	text-align:left;
}

<cfif GIFT.RECEIPT.inkFriendly EQ 'no'>
	<cfset footerTop = 1055>
<cfelse>
	<cfset footerTop = 550>
</cfif>

<cfset footerAddressTop = footerTop + 30>
<cfset footerAddressTopHK = footerTop>

div##footerWill{
	left: 50px ;
	top: #footerTop#px ;
	width: 800px ;
	text-align:center;
	font-size:12px;
	line-height:14px;
}

div##footerAddress{
	left: 50px ;
	top: #footerAddressTop#px ;
	width: 800px ;
	text-align:center;
	font-size:12px;
	line-height:14px;
}

div##footerAddressHK{
	left: 50px ;
	top: #footerAddressTopHK#px ;
	width: 800px ;
	text-align:center;
	font-size:12px;
	line-height:14px;
}




.taxReceiptTitle{
	font-size:20px;
	line-height:23px;
}
.taxReceiptBN{
	font-size: 14px;
	line-height: 18px;
}
.taxReceiptCRA{
	font-size: 10px;
	line-height:14px;
}
.taxReceiptCRALoc{
	font-size: 10px;
	line-height:14px;
}


</style>
</head>
<body>

<cfif GIFT.RECEIPT.issuer EQ 'BCCHF'>
<!--- BCCHF Receipt --->

<div id="logo">
<img src="http://secure.bcchf.ca/donate/receipt/graphics/bcchf.jpg" alt="BCCHF" />
</div>

<div id="title">
<div class="taxReceiptTitle">#GIFT.RECEIPT.taxMessage#</div>
<div class="taxReceiptBN">Charitable BN## 11885 2433 RR0001</div>
<div class="taxReceiptCRA">Per Canada Revenue Agency: http://www.cra-arc.gc.ca/charitiesandgiving</div>
<div class="taxReceiptCRALoc">Receipt issued from 938 West 28th Ave, Vancouver, BC, V5Z 4H4</div>
</div>

<div id="donorAddress">
#GIFT.RECEIPT.donorName#<br />
#GIFT.RECEIPT.donorAddress#
</div>

<div id="donorTitle">
Re:<br />
Receipt issued to: <br />
</div>

<div id="donor">
#GIFT.RECEIPT.reSubject#<br />
#GIFT.RECEIPT.donorName#<br />
</div>


<div id="receiptInfoTitle">
Receipt No:<br />
Date received:<br />
Receipt issued:
</div>

<div id="receiptInfo">
#GIFT.RECEIPT.number#<br />
#DateFormat(GIFT.RECEIPT.recDate, "MM/DD/YYYY")#<br />
#DateFormat(Now(), "MM/DD/YYYY")#
</div>

<div id="receiptAmountTitle">
Amount received: <br />
Amount of advantage:<br />
Amount eligible for tax purposes:
</div>

<div id="receiptAmount">
#DollarFormat(GIFT.RECEIPT.totalAmount)#<br />
#DollarFormat(GIFT.RECEIPT.advAmount)#<br />
#DollarFormat(GIFT.RECEIPT.taxAmount)#<br />
</div>

<div id="authSig">
<img src="http://secure.bcchf.ca/donate/receipt/graphics/tnicholas.jpg" width="200" alt="Signature" /><br />
Teri Nicholas<br />
President & CEO
</div>
<cfif GIFT.RECEIPT.inkFriendly EQ 'no'>
<div id="cutLine">
<img src="http://secure.bcchf.ca/donate/receipt/graphics/cut.jpg" alt="cut" />
</div>

<div id="receiptGraphic">
<img src="http://secure.bcchf.ca/donate/receipt/graphics/#GIFT.RECEIPT.image#" alt="#GIFT.RECEIPT.imageAlt#" />
</div>
</cfif>

<div id="footerWill">
Please consider leaving a gift to BC Children's Hospital Foundation in your will.
</div>


<div id="footerAddress">
938 28th Ave W, Vancouver BC V5Z 4H4<br />
Telephone: 604-875-2444 &nbsp; &nbsp; Toll Free: 1-888-663-3033 &nbsp; &nbsp; Fax: 604-875-2596<br />
Website: <a href="http://www.bcchf.ca">www.bcchf.ca</a>
</div>

<cfelseif GIFT.RECEIPT.issuer EQ 'BCMHF'>
<!--- BCCHF Receipt --->

<div id="logo">
<img src="http://secure.bcchf.ca/donate/receipt/graphics/bcmhf.jpg" alt="BCMHF" />
</div>

<div id="title">
<div class="taxReceiptTitle">#GIFT.RECEIPT.taxMessage#</div>
<div class="taxReceiptBN">Charitable BN## 89287 7366 RR0001</div>
<div class="taxReceiptCRA">Per Canada Revenue Agency: http://www.cra-arc.gc.ca/charitiesandgiving</div>
<div class="taxReceiptCRALoc">Receipt issued from 938 West 28th Ave, Vancouver, BC, V5Z 4H4</div>
</div>

<div id="donorAddress">
#GIFT.RECEIPT.donorName#<br />
#GIFT.RECEIPT.donorAddress#
</div>

<div id="donorTitle">
Re:<br />
Receipt issued to: <br />
</div>

<div id="donor">
#GIFT.RECEIPT.reSubject#<br />
#GIFT.RECEIPT.donorName#<br />
</div>


<div id="receiptInfoTitle">
Receipt No:<br />
Date received:<br />
Receipt issued:
</div>

<div id="receiptInfo">
#GIFT.RECEIPT.number#<br />
#DateFormat(GIFT.RECEIPT.recDate, "MM/DD/YYYY")#<br />
#DateFormat(Now(), "MM/DD/YYYY")#
</div>

<div id="receiptAmountTitle">
Amount received: <br />
Amount of advantage:<br />
Amount eligible for tax purposes:
</div>

<div id="receiptAmount">
#DollarFormat(GIFT.RECEIPT.totalAmount)#<br />
#DollarFormat(GIFT.RECEIPT.advAmount)#<br />
#DollarFormat(GIFT.RECEIPT.taxAmount)#<br />
</div>

<div id="authSig">
<img src="http://secure.bcchf.ca/donate/receipt/graphics/tnicholas.jpg" width="200" alt="Signature" /><br />
Teri Nicholas<br />
President & CEO
</div>
<cfif GIFT.RECEIPT.inkFriendly EQ 'no'>
<div id="cutLine">
<img src="http://secure.bcchf.ca/donate/receipt/graphics/cut.jpg" alt="cut" />
</div>

<div id="receiptGraphic">
<img src="http://secure.bcchf.ca/donate/receipt/graphics/#GIFT.RECEIPT.image#" alt="#GIFT.RECEIPT.imageAlt#" />
</div>
</cfif>

<div id="footerWill">
&nbsp;
</div>


<div id="footerAddress">
938 28th Ave W, Vancouver BC V5Z 4H4<br />
Telephone: 604-875-2444 &nbsp; &nbsp; Toll Free: 1-888-663-3033 &nbsp; &nbsp; Fax: 604-875-2596<br />
Website: <a href="http://www.bcmhf.ca">www.bcmhf.ca</a>
</div>

<cfelseif GIFT.RECEIPT.issuer EQ 'HK'>
<!--- hong kong receipt --->

<div id="logoHK">
<img src="http://secure.bcchf.ca/donate/receipt/graphics/BCCHF-LTD-HK.jpg" alt="BCCHF Ltd." />
</div>

<div id="titleHK">
<div class="taxReceiptTitle">OFFICIAL DONATION RECEIPT<br />FOR HONG KONG TAX PURPOSES</div>
<div class="taxReceiptBN">Hong Kong Corporate Registration ##: 1215590</div>
</div>

<div id="donorAddressHK">
#DateFormat(Now(), "mmmm d, yyyy")#<br />
&nbsp;<br />
#GIFT.RECEIPT.donorName#<br />
#GIFT.RECEIPT.donorAddress#
</div>

<div id="donorTitle">
Re:<br />
Receipt issued to: <br />
</div>

<div id="donor">
#GIFT.RECEIPT.reSubject#<br />
#GIFT.RECEIPT.donorName#<br />
</div>


<div id="receiptInfoTitle">
Receipt No:
</div>

<div id="receiptInfo">
#GIFT.RECEIPT.number#
</div>

<div id="receiptAmountTitle">
Date received:<br />
Receipt issued:<br />
Amount received: 
</div>

<div id="receiptAmount">
#DateFormat(GIFT.RECEIPT.recDate, "MM/DD/YYYY")#<br />
#DateFormat(Now(), "MM/DD/YYYY")#<br />
#DollarFormat(GIFT.RECEIPT.totalAmount)# (CAD)
</div>

<div id="authSig">
<img src="http://secure.bcchf.ca/donate/receipt/graphics/tnicholas.jpg" width="200" alt="Signature" /><br />
Teri Nicholas<br />
President & CEO
</div>
<cfif GIFT.RECEIPT.inkFriendly EQ 'no'>
<div id="cutLine">
<img src="http://secure.bcchf.ca/donate/receipt/graphics/cut.jpg" alt="cut" />
</div>

<div id="CICHtag">To find out more about the Centre for International Child Health (CICH) and its partnership programs in China, please visit <a href="http://www.bcchildrens.ca/Professionals/CtrInternationalChildHealth">http://www.bcchildrens.ca/Professionals/CtrInternationalChildHealth</a></div>
<div id="receiptGraphicHKleft">
<img src="http://secure.bcchf.ca/donate/receipt/graphics/2012-HK-left.jpg" alt="" />
</div>
<div id="HKBCCHFtag">
To learn more about BC Children's Hospital Foundation, please visit <a href="http://www.bcchf.ca">www.bcchf.ca</a>
</div>
<div id="receiptGraphicHKright">
<img src="http://secure.bcchf.ca/donate/receipt/graphics/2012-HK-right.jpg" alt="" />
</div>
</cfif>
<!--- 
<div id="footerWill">
Please consider leaving a gift to BC Children's Hospital Foundation in your will.
</div>--->


<div id="footerAddressHK">
Children's Hospital Foundation Limited<br />
11th Floor, Central Building, 1-3 Pedder Street, Hong Kong<br />
Hong Kong: (852) 2523-5022<br />
Vancouver, BC: (604) 875-2444<br />
Website: <a href="http://www.bcchf.ca">www.bcchf.ca</a>
</div>

<cfelse>
<!--- unknown scenario --->
</cfif>
     
    </body>
    </html>
    </cfoutput>