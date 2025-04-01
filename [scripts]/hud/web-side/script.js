const gears = ['R', 'N', '1', '2', '3', '4', '5', '6']

var cortagiro = new ldBar("#barcortagiro",
    {
        "value": 90,
        "fill-background-extrude": 0,
        "fill-background": '#00000050',
        "fill": 'blue',
        "fill-dir": 'ltr',
        "type": 'fill',
        "min": 1,
        "max": 100,
    }
);

$(function () {
    var container = $("#container");
    var oldGear
    var oldSpeed
    var marchanova;

    window.addEventListener('message', function (event) {
        var item = event.data;
        var data = event.data;

        if (item.hudoff == true) {
            $('body').css('display', 'none');
        } else {
            $('body').css('display', 'block');
        }


        if (data.action == "talking") {
            if (data.boolean) {
                $('#microp').css('animation', 'animateCinto 1s linear infinite');
            } else {
                $('#microp').css('animation', 'unset');

            }
        }

        let radio = document.querySelector('.radio')
        if (data.action == "channel") {
            if (data.radio && data.radio != undefined) {
                radio.innerHTML = `
                <span>${data.radio} MHz</span>`
            } else if (!data.radio) {
                radio.innerHTML = `
                <span>DESLIGADO</span>`
            }
        }

        let voice = document.querySelector('.voice')
        if (data.action == "proximity") {
            if (data.voice) {
                if (data.voice == 1) {
                    $('.voice').fadeIn();
                    voice.innerHTML = `

                    <span>Sussurando</span>`
                } else if (data.voice == 2) {
                    $('.voice').fadeIn();
                    voice.innerHTML = `

                    <span>Normal</span>`
                } else if (data.voice == 3) {
                    $('.voice').fadeIn();
                    voice.innerHTML = `
   
                    <span>Gritando</span>`
                }
            }
        }


        if (item.lock == 'fecharcarro') {
            if (item.status == true) {
                $("#lock img").css("filter", "drop-shadow(0px 0px 6px #ff0000ce)")
                $('#lock img').attr('src', 'svg/tranca2.svg')

            } else if (item.status == false) {
                $("#lock img").css("filter", "drop-shadow(0px 0px 6px #09ff00ce)")
                $('#lock img').attr('src', 'svg/tranca.svg')
            }
        }

        switch (item.action) {
            case 'update':
                if ($(".velocimeterHud").is(":visible")) {
                    $(".velocimeterHud").fadeOut()
                    $("#barcortagiro").css("opacity","0")
                }
                barcortagiro
                if (data.health <= 1) {
                    setCircle("0", 'lifeFill')
                } else {
                    setCircle(data.health, 'lifeFill')
                }

                setCircle(data.armour, 'shieldFill')
                setCircle(data.thirst, 'waterFill')
                setCircle(data.hunger, 'foodFill')
                setCircle(data.stamina, 'stressFill')
                $(".playerHud").fadeIn('slow')
                $(".outline").fadeOut('slow')



                break;
            case 'inCar':
                if (!$(".velocimeterHud").is(":visible")) {
                    $(".velocimeterHud").fadeIn('slow')
                    $(".playerHud").fadeIn('slow')
                    $("#barcortagiro").css("opacity","1")


                }

                if (data.health <= 1) {
                    setCircle("0", 'lifeFill')
                } else {
                    setCircle(data.health, 'lifeFill')
                }

                setCircle(data.armour, 'shieldFill')
                setCircle(data.thirst, 'waterFill')
                setCircle(data.hunger, 'foodFill')
                setCircle(data.stamina, 'stressFill')
                $(".outline").fadeIn('slow')

                break
        }

        if (item.action == "horarios") {
            let hour = document.querySelector('.hour')
            hour.textContent = `${data.time}`

            // let location = document.querySelector('.location')
            // location.innerHTML = `${data.street} | ${data.direction}`

        }

        if (item.only == "updateSpeed") {
            let velo = document.querySelector('.velo');
            velo.textContent = data.speed

            if (Number(data.speed) <= 9) { velo.innerHTML = `00<b>${data.speed.toFixed(0)}</b>` }
            else if (Number(data.speed) <= 99) { velo.innerHTML = `0<b>${data.speed.toFixed(0)}</b>` }
            else { velo.innerHTML = `<b>${data.speed.toFixed(0)}</b>` }

            setProgressSpeed(data.speed / 2.95, '.progress-speed');
            setProgressSpeed(data.fuel * 0.62, '.progress-fuel');
            setCircle(data.engine, 'engineFill')

            if (data.gear === 7) data.gear = 0

            let gear = gears[data.gear]

            $('.carMarch').html(gear)

            $('#iconfuel span').html(item.fuel + "%")
            $('.engineCircle span').html(item.engine + "%")

            if (data.farol && data.farol == "off") {
                $("#farol img").attr('src', 'svg/farolbaixo.svg')
            } else if (data.farol && data.farol == "normal") {
                $("#farol img").attr('src', 'svg/farolmedio.svg')
            } else if (data.farol && data.farol == "alto") {
                $("#farol img").attr('src', 'svg/farolalto.svg')
            }


            cortagiro.set(item.rpm)
            let seatbelt = document.querySelector('.seatbelt')

            if (data.seatbelt == 1) {
                seatbelt.classList.add('activeBelt')
                seatbelt.classList.remove('removeBelt')
                $('.seatbelt').attr('src', 'svg/cintoaberto.svg')
            } else if (data.seatbelt == 0) {
                seatbelt.classList.add('removeBelt')
                seatbelt.classList.remove('activeBelt')
                $('.seatbelt').attr('src', 'svg/cintofechado.svg')
            };
        }
    });




});


function setProgressSpeed(value, element) {
    var circle = document.querySelector(element);
    var radius = circle.r.baseVal.value;
    var circumference = radius * 2 * Math.PI;
    var percent = value * 100 / 220;

    circle.style.strokeDasharray = `${circumference} ${circumference}`;
    circle.style.strokeDashoffset = `${circumference}`;
    const offset = circumference - ((-percent * 73) / 100) / 100 * circumference;
    circle.style.strokeDashoffset = -offset;
}

function setCircle(percentage, fillClass) {
    let circle = document.querySelector(`.${fillClass}`)
    let calc = (113 * (100 - percentage)) / 100
    circle.style.strokeDashoffset = calc
}




