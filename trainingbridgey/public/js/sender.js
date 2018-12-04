$(document).ready(function() {

  $(function() {
    $('#datetimepicker').datetimepicker({
      format: "YYYY-MM-DD HH:mm",
      sideBySide: true,
      ignoreReadonly: true
    });
  });

  $('.js-multiple').select2({
    placeholder: "Select required skills",
    width: "900px",
    closeOnSelect: true,
    allowClear: true,
  });

  $('.fakeAddress').click(function(e) {
    e.preventDefault();
    $('#address1').val("Fake House").focus().blur()
    $('#address2').val("Fake Street").focus().blur()
    $('#address3').val("Fake Country").focus().blur()
  });

})

function prepareDivs(index) {
  hideUnusedDivs();
  displayRequiredDiv(index);
};

function hideUnusedDivs() {
  var divsToHide = document.getElementsByClassName("skillDiv");
  for (var i = 0; i < divsToHide.length; i++) {
    divsToHide[i].style.display = "none";
    divsToHide[i].firstElementChild.disabled = true;
  }
}

function displayRequiredDiv(index) {
  var x = document.getElementById(index);
  x.style.display = "block";
  x.firstElementChild.disabled = false;
}
