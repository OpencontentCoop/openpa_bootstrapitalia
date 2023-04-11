<div class="openpa-widget {$block.view} {if and(is_set($block.custom_attributes.color_style), $block.custom_attributes.color_style|ne(''))}color color-{$block.custom_attributes.color_style}{/if}">
	<h3 class="openpa-widget-title">{if $block.name}{$block.name} <img src="{'images/logo_COsmOs.png'|ezdesign(no)}" alt="logo-cosmos" width="40px" title="logo-cosmos" />{else}Chiedi a COsmOs <img src="{'images/logo_COsmOs.png'|ezdesign(no)}" alt="logo-cosmos" width="40px" title="logo-cosmos" />{/if}</h3>

	<div class="openpa-widget-content">
		<form id="cosmos" name="cosmos" method="post">
			<textarea style="width: 100%;resize: none; min-height: 90px;" name="question" id="question" cols="25" rows="10" placeholder="{ezini('Settings', 'Intro', 'cosmos.ini')}"></textarea>
			<input class="btn btn-success btn-block" type="button" onclick="ask();" value="Chiedi a COsmOs" />
		</form>
	</div>
</div>


<script>
  {literal}
	function ask(){
	  var xmlhttp;
	  if (window.XMLHttpRequest)
	  {// code for IE7+, Firefox, Chrome, Opera, Safari
		  xmlhttp=new XMLHttpRequest();
	  }else{// code for IE6, IE5
		  xmlhttp=new ActiveXObject("Microsoft.XMLHTTP");
	  }
	  xmlhttp.onreadystatechange=function(){
		  if (xmlhttp.readyState==4 && xmlhttp.status==200){
			  var response = xmlhttp.responseText;
			  var html = jQuery('<div>').html(response).find('#cosmos-ambiti h3').html();
			  //console.log( html );
			  $('#question').val(html);
			  //document.getElementById("question").innerHTML=html; //xmlhttp.responseText;
			  //console.log( xmlhttp.responseText );
		  }
	  }
	  var question = $('#question').val();
	  if ( $.trim( question ) == "" ) {
		alert("Inserisci il testo nella casella e clicca su \"chiedi a Cosmos\"");
	  }else{
		$('#question').val("Richiesta in corso. Attendere...");
		xmlhttp.open("/cosmos/ask?question=" + question, true);
		xmlhttp.send();
	  }
	}
	{/literal}
</script>
