document.onkeyup = (data) => {
    if (data["key"] === "Escape"){
        saveClose();
    }
};

$('#saveBtn').on('click', () => {
    saveClose();
});

function saveClose() {
    $.post("http://black_fps/saveInformantion",JSON.stringify({
        distance: document.getElementById("distance").value,
        light: document.getElementById("light").value,
        texture: document.getElementById("texture").value,
        shadow: document.getElementById("shadow").value
    }));
    $(".container").css("display","none");
}

window.addEventListener("message",function(event){
	switch (event["data"]["Action"]){
		case "Display":
			$(".container").css("display","flex");
            document.getElementById("distance").value = event["data"]["distance"]
            document.getElementById("light").value = event["data"]["light"]
            document.getElementById("texture").value = event["data"]["texture"]
            document.getElementById("shadow").value = event["data"]["shadow"]
            document.getElementById("title_playername").innerHTML = event["data"]['player_name'] + '.'
            document.querySelectorAll('.input_bg input').forEach(element => {
                updateValue(element);
            });
		    break;

        case "FpsValue":
            document.getElementById("fps_value").innerHTML = event["data"]["fps_value"]
            break;

        default:
            break;
	}
});

function updateValue(element) {
    const vMax = element.getAttribute("max");
    const pai = element.closest('.configs_block');
    pai.querySelector('.selected_percentage_box span').innerHTML = Math.round((element.value / vMax) * 100);
}