$(document).ready(function () {
	var notifyNumber = 0;
	window.addEventListener("message", function (event) {
		var html = `
		<div class="notify" id="${event.data.css}">
			<img src="src/img/${event.data.css}.png" />
				<div class="text">
					<span>${event.data.title ? event.data.title : event.data.css}</span>
					<p>${event["data"]["mensagem"]}</p>
				</div>
			<div class="bar">
				<div class="fill ${notifyNumber}"></div>
			</div>
		</div>
		`;

		$(html).fadeIn(500).appendTo(`.${event.data.position === undefined ? "normal" : `${event.data.position}`}`).delay(event["data"]["timer"]).fadeOut(500);
		$(`.${notifyNumber}`).css('transition', `width ${event["data"]["timer"]}ms`);

		setTimeout(() => {
			$(`.${notifyNumber}`).css('width', '0%');
			notifyNumber += 1;
		}, 100);
	});
});