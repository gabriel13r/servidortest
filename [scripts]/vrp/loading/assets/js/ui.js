$(window).load(function() {
  $("#preloader").fadeOut(200);
});

var tips = [];
setInterval(function() {
  var r = Math.floor(Math.random() * tips.length);
  $(".tip-text").fadeOut(200, function() {
    $(".tip-text").html(tips[r]);
    $(this).fadeIn(200);
  });
  
}, 10000);

$(function(){   
    $(document).keydown(function(objEvent) {        
        if (objEvent.ctrlKey) {          
            if (objEvent.keyCode == 65) {                         

                return false;
            }            
        }        
    });
}); 