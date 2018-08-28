<cfoutput>  
<!--- this is the layout of the receipt..
	2018 updates woth fonts
	single BCCHF option ---> 
 		
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
    <html>
    <head>
    <link href="http://fonts.googleapis.com/css?family=Roboto" rel="stylesheet">
    
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
div##authSig,
div##imageText, div##imageTag, div##imageWill {
	position: absolute ;
	font-family: 'Roboto',Verdana, Geneva, sans-serif;
}


div##logo {
	left: 30px ;
	top: 5px ;
	width: 250px ;
}

div##title {
	left: 350px ;
	top: 40px ;
	width: 400px ;
}

div##donorAddress {
	left: 50px ;
	top: 190px ;
	width: 500px ;
	font-size: 16px;
	line-height:20px;
}

<cfset donorTop = 270>
<cfset receiptInfoTop = 340>

div##donorTitle {
	left: 50px ;
	top: 270px ;
	width: 200px ;
	font-size: 16px;
	line-height:20px;
	font-weight:bold;
}

div##donor {
	left: 225px ;
	top: 270px ;
	width: 500px ;
	font-size: 16px;
	line-height:20px;
	font-weight:bold;
}

div##receiptInfoTitle {
	left: 50px ;
	top: 340px ;
	width: 200px ;
	font-size: 16px;
	line-height:20px;
}

div##receiptInfo {
	left: 200px ;
	top: 340px ;
	width: 150px ;
	font-size: 16px;
	line-height:20px;
}

div##receiptAmountTitle {
	left: 400px ;
	top: 340px ;
	width: 300px ;
	font-size: 16px;
	line-height:20px;
}

div##receiptAmount{
	left: 655px ;
	top: 340px ;
	width: 100px ;
	font-size: 16px;
	line-height:20px;
	text-align:right;
}

div##authSig{
	left: 400px;
	top: 430px;
	width: 364px;
	text-align:left;
	font-size: 16px;
	line-height:20px;
}

div##cutLine {
	left: 30px ;
	top: 500px ;
	width: 500px ;
}

div##receiptGraphic {
	left: 50px ;
	top: 545px ;
	width: 400px ;
	text-align:center;
}



<cfif GIFT.RECEIPT.inkFriendly EQ 'no'>
	<cfset footerTop = 1025>
<cfelse>
	<cfset footerTop = 520>
</cfif>

<cfset footerAddressTop = footerTop + 30>

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
	color:##2a3f51;
}

div##imageText{
	left:100px;
	top: 750px;
	width: 300px ;
	font-size: 13px;
	line-height:15px;
	color:##2a3f51;
	
}
div##imageTag{
	left:100px;
	top: 870px;
	width: 500px ;
	font-size: 16px;
	line-height:18px;
	color:##2a3f51;
	font-weight:bold;
	
}
div##imageWill{
	left:100px;
	top: 910px;
	width: 300px ;
	font-size: 11px;
	line-height:14px;
	color:##e68a3f;
	
}


.taxReceiptTitle{
	font-size:20px;
	line-height:23px;
	font-weight:bold;
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
.footO{
	color:##e68a3f;
	font-size:12px;
	line-height:14px;
	font-weight:bold;
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
<div class="taxReceiptCRA">Per Canada Revenue Agency: canada.ca/charities-giving</div>
<div class="taxReceiptCRALoc">Receipt issued from 938 West 28th Avenue, Vancouver, BC V5Z 4H4</div>
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
Teri Nicholas, MSW, RSW<br />
President & CEO
</div>
<cfif GIFT.RECEIPT.inkFriendly EQ 'no'>
<!--- 
<div id="cutLine">
<img src="http://secure.bcchf.ca/donate/receipt/graphics/cut.jpg" alt="cut" />
</div> --->

<div id="receiptGraphic">
<img src="http://secure.bcchf.ca/donate/receipt/graphics/#GIFT.RECEIPT.image#" alt="#GIFT.RECEIPT.imageAlt#" />
</div>
</cfif>

<!--- 
<div id="footerWill">
Please consider leaving a gift to BC Children's Hospital Foundation in your will.
</div>---->

<div id="imageText">
Your donation will open up new possibilities in children's health. Because of you, we can advance innovative research, provide kids specialized care that's tailored to their needs, and comfort families during their toughest days.
</div>
<div id="imageTag">
Thanks for helping us aim higher.
</div>

<div id="imageWill">
You can create a lasting legacy with a gift to<br />
BC Children's Hospital Foundation in your Will.
</div>


<div id="footerAddress">
938 West 28th Avenue, Vancouver, BC V5Z 4H4 &nbsp; &nbsp; <span class="footO">t</span> 604.875.2444 &nbsp; &nbsp; <span class="footO">tf</span> 1.888.663.3033 &nbsp; &nbsp; <span class="footO">w</span> bcchf.ca
</div>


<cfelse>
<!--- unknown scenario --->
</cfif>
     
    </body>
    </html>
    </cfoutput>