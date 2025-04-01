let segundos = false;
let active = false;

$(function () {
    window.addEventListener("message", function (event) {
        var convertedMinutes = event.data.deathtimer
        var convertedSeconds = event.data.deathtimer
        convertedMinutes = Math.floor(event.data.deathtimer / 60)
        convertedSeconds = Math.floor(event.data.deathtimer % 60)
        var item = event.data;
        if (item.setDisplay) {
            $("#fainting").fadeIn(200);
            $("#popup-1").fadeIn(200);
            $('.progress span').css('width', '100%')
            let porcentage = ((convertedMinutes*60)+convertedSeconds) * 100 / 500;
            $('.progress span').css('width', porcentage+'%')
            progressBar()
            $("#clock").html(`${(convertedMinutes*60)+convertedSeconds} S`);
        } else {
            $("#fainting").fadeOut(1000);
            $("#popup-1").fadeOut(1000);
            active = false
        }
    });
});

function progressBar() {
    if(active) return;
    else{   
        // --console.log(active)
        active = true;
        $('.progress span').css('width', '0')
    }
}

function abrirModal() {
    if (segundos) return
    segundos = true;
    document.getElementById("popup-1").classList.toggle("active");
    setTimeout(function () { segundos = false }, 5000);
}

function fecharModal() {
    document.getElementById("popup-1").classList.toggle("active");
}

function simAceita() {
    document.getElementById("popup-1").classList.toggle("active");
    $.post("https://survival/ButtonRevive");
}