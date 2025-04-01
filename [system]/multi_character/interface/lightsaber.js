var infotab;

$(document).ready(function(){
    let charAction = $("#content");
    window.addEventListener("message",function(event){
        let item = event.data;
        switch(item.action){
            case "showMenu":
				switch(item.type){
					case "haveChar":
						updateChars();
						$("#content").fadeIn(500);
						$("#menu-fade").fadeIn(750);
					break;

					case "noHaveChar":
						$("#content").fadeIn(500);
						$("#new-char").fadeIn(750);
					break;
				};
			break;

            case "hideMenu":
				$("#content").fadeOut(500);
			break;

            case "updateChars":
				updateChars();
			break;

			case "hideSpawnButton":
				$("#spawn-buttom").css('display', 'none');
				$("#spawn-buttomBanned").css('display', 'none');
			break;

			case "showSpawnButton":
				$("#spawn-buttom").fadeIn(1000);
				$("#spawn-buttomBanned").fadeIn(1000);
			break;
        };
    });
});

const formatarNumero = (n) => {
	var n = n.toString();
	var r = '';
	var x = 0;
	for (var i = n.length; i > 0; i--) {
		r += n.substr(i - 1, 1) + (x == 2 && i != 1 ? '.' : '');
		x = x == 2 ? 0 : x + 1;
	}
	return r.split('').reverse().join('');
}

const updateChars = () => {
    $.post("https://multi_character/getCharacters",JSON.stringify({}),(data) => {
		const nameList = data.chars.sort((a,b) => (a.name > b.name) ? 1: -1);

		$("#char-list").html(`
			${nameList.map((item) => (`	
				<div class="char" data-char-id="${item.id}">
					<div id='char-gender'><img src='${item.genderIcon}'/></div>
					<div id="char-name"><h2>${item.name} ${item.firstname}</h2></div>
					<div id='char-id'><h2>${item.id}</h2></div>
				</div>
			`)).join("")}
		`);
		for (let i = 0; i < data.slots; i++) {
			$("#char-list").append(`
				<div class="slot">
					<div id='slot-text'><h6>Criar personagem</h6></div>
				</div>
			`)
		}
	});
}

$(document).on('click','.char',function(){
	let $el = $(this)
	let isActive = $el.hasClass('active')
	$('.char').removeClass('active')
	if(!isActive) $el.addClass('active')
    let $em = $('.char.active')

    if($em) {
        $.post('https://multi_character/spawnChar',JSON.stringify({
			id: $el.attr('data-char-id')
		}),(data) => {

 					if (data.banned) 
 						{
 							$("#spawnar").fadeOut(500)
 								setTimeout(function(){
							$("#spawnarBanned").fadeIn(1000);
						}, 500);
 							var concMsg =  '<h6>FIM DO BANIMENTO: '+ data.expire +'</h6>'
							$('#spawn-buttomBanned').html(concMsg);					
 									}
 								else
 							{
 								var concMsg =  '<h6>FIM DO BANIMENTO: '+ data.expire +'</h6>'
 								$("#spawnarBanned").fadeOut(500)
 								$('#spawn-buttomBanned').html(concMsg);	
 							
 					setTimeout(function(){
 							
							$("#spawnar").fadeIn(1000);
						}, 500);
 					}


		});

    }
});

$(document).on('click', '.slot',function(){
	$.post('https://multi_character/newChar',JSON.stringify({
		
	}));
});

$(document).on('click', '#new-char-buttom',function(){
	$.post('https://multi_character/firstChar',JSON.stringify({
		
	}));
});

$(document).on('click','#spawn-buttom',function(){
	let $el = $('.char.active')
	let id = $el.attr('data-char-id')
	
	if($el) {
		if (id) {
			$.post('https://multi_character/joinInTheCity',JSON.stringify({
				id: id
			}))
		}	
	}
})