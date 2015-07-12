function sendCmd(cmd, callback) {
  cmd = $.trim(cmd)
  if (cmd.length > 0) {
    $.get('/mc_api/' + cmd)
    .done(function (data, textStatus, jqXHR) {
      callback(data);
    });
  }
}

function displayTemp() {
  sendCmd('get_temp', function (tempC) {
    var tempF = parseFloat(tempC) * 1.8 + 32;
    $('#mc-temp').html(tempF.toFixed(1));
  });
}

function displayDoorStatus() {
  sendCmd('get_door_status', function (status) {
    var doorBtn = $('#mc-door-toggle');
    if (status == 'unknown') {
      doorBtn.attr('disabled', 'disabled');
    } else if (status == 'open') {
      doorBtn.removeAttr('disabled');
      doorBtn.html('Close');
    } else if (status == 'closed') {
      doorBtn.removeAttr('disabled');
      doorBtn.html('Open');
    }
  });
}

$(function () {
  if ($('#mc-controls').length) {
    // user most likely is authorized to view controls
    displayTemp();
    displayDoorStatus();
    var doorStatusInterval = setInterval(displayDoorStatus, 5000);

    var doorBtn = $('#mc-door-toggle');
    doorBtn.click(function () {
      clearInterval(doorStatusInterval);
      doorBtn.attr('disabled', 'disabled');
      sendCmd('toggle_door', function () {
        // do nothing for now
      });
      setTimeout(function () { doorStatusInterval = setInterval(displayDoorStatus, 5000); }, 10000);
    });
  }
});
