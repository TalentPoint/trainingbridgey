$(document).ready(function() {
  var navListItems = $('ul.setup-panel li a'),
      containers = $('.setup-content');

  containers.hide();

  navListItems.click(function(e) {
    e.preventDefault();
    var $target = $($(this).attr('href')),
      $item = $(this).closest('li');

    if (!$item.hasClass('disabled')) {
      navListItems.closest('li').removeClass('active');
      $item.addClass('active');
      containers.hide();
      $target.show();
    }
  });

  $('ul.setup-panel li.active a').trigger('click');

  $('#activate-step-2').on('click', function(e) {
    e.preventDefault();
    $('ul.setup-panel li:eq(1)').removeClass('disabled');
    $('ul.setup-panel li a[href="#step-2"]').trigger('click');
  })

  $('#activate-step-3').on('click', function(e) {
    e.preventDefault();
    $('ul.setup-panel li:eq(2)').removeClass('disabled');
    $('ul.setup-panel li a[href="#step-3"]').trigger('click');
  })

  $('#activate-step-4').on('click', function(e) {
    e.preventDefault();
    $('ul.setup-panel li:eq(3)').removeClass('disabled');
    $('ul.setup-panel li a[href="#step-4"]').trigger('click');
  })

  $('#activate-step-5').on('click', function(e) {
    e.preventDefault();
    $('ul.setup-panel li:eq(4)').removeClass('disabled');
    $('ul.setup-panel li a[href="#step-5"]').trigger('click');
  })

});
