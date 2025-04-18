window.addEventListener("load",function(){
	errdiv = document.createElement("div");
	if (true){
		errdiv.classList.add("console");
		document.body.appendChild(errdiv);
		window.onerror = function(errorMsg,url,lineNumber,column,errorObj){
			errdiv.innerHTML += '<br />Error: ' + errorMsg + ' Script: ' + url + ' Line: ' + lineNumber + ' Column: ' + column + ' StackTrace: ' +  errorObj;
		}
	}

	var wprompt = new WPrompt();
	var requestmgr = new RequestManager();
	var divs = {}

	requestmgr.onResponse = function(id,ok){ $.post("http://vrp/request",JSON.stringify({ act: "response", id: id, ok: ok })); }
	wprompt.onClose = function(){ $.post("http://vrp/prompt",JSON.stringify({ act: "close", result: wprompt.result })); }

	window.addEventListener("message",function(evt){
		var data = evt["data"];
		
		if(data["act"] == "set_div"){
			var div = divs[data.name];
			if(div)
				div.removeDom();

			divs[data.name] = new Div(data)
			divs[data.name].addDom();
		}
		if(data["act"] == "set_div_css"){
			var div = divs[data.name];
			if(div)
				div.setCss(data.css);
		}
		if(data["act"] == "set_div_content"){
			var div = divs[data.name];
			if(div)
				div.setContent(data.content);
		}

		if(data["act"] == "div_execjs"){
			var div = divs[data.name];
			if(div)
				div.executeJS(data.js);
		}
		if(data["act"] == "remove_div"){
			var div = divs[data.name];
			if(div)
			div.removeDom();
			delete divs[data.name];
		}

		if(data["act"] == "cfg"){
			cfg = data["cfg"]
		}

		if(data["act"] == "prompt"){
			wprompt.open(data["title"],data["text"]);
		}

		if(data["act"] == "request"){
			requestmgr.addRequest(data["id"],data["text"],data["time"]);
		}

		if(data["act"] == "event"){
			if(data["event"] == "Y"){
				requestmgr.respond(true);
			}
			else if(data["event"] == "U"){
				requestmgr.respond(false);
			}
		}

		if (data["death"] == true){
			$("#deathDiv").css("display","block");
		}

		if (data["death"] == false){
			$("#deathDiv").css("display","none");
		}

		if (data["deathtext"] !== undefined){
			$("#deathText").html(data["deathtext"]);
		}


		if (data["capuz"] == true){
			$("#capuzDiv").css("display","block");
		}

		if (data["capuz"] == false){
			$("#capuzDiv").css("display","none");
		}

		if (data["capuztext"] !== undefined){
			$("#capuzText").html(data["capuztext"]);
		}

		if (data["wanted"] == true){
			if($("#wantedDiv").css("display") === "none"){
				$("#wantedDiv").css("display","block");
			}
		}

		if (data["wanted"] == false){
			if($("#wantedDiv").css("display") === "block"){
				$("#wantedDiv").css("display","none");
			}
		}

		if (data["wantedTime"] !== undefined){
			$("#wantedDiv").html("As autoridades estão a sua procura, aguarde <b>"+parseInt(data["wantedTime"])+" segundos</b> até que tudo se acalme.");
		}

		if (data["repose"] == true){
			if($("#reposeDiv").css("display") === "none"){
				$("#reposeDiv").css("display","block");
			}
		}

		if (data["repose"] == false){
			if($("#reposeDiv").css("display") === "block"){
				$("#reposeDiv").css("display","none");
			}
		}
		
		if (data["reposeTime"] !== undefined){
			// $("#reposeDiv").html("Tratamento ocasionou lesões no corpo, aguarde <b>"+parseInt(data["reposeTime"])+" segundos</b> até tudo fique bem.");
		}

	});
});