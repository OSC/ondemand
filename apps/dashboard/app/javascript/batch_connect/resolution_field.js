import { ariaNotify } from "../utils";

export function updateResolutions() {
      $('[data-widget-type="resolution_field"]').each(function(_index, wrapper) {
      // Target elements
      const groupId = $(wrapper).children().attr('id');
      const id = groupId.slice(0, groupId.lastIndexOf('_group'));
      console.log(id)
      var $target  = $(wrapper).find(`#${id}_field`);
      var $targetX = $(wrapper).find(`#${id}_x_field`);
      var $targetY = $(wrapper).find(`#${id}_y_field`);
      var $targetR = $(wrapper).find(`#${id}_reset`);

      // Helper methods
      var setX = function(x) {
        y = getY();
        $target.val(x + 'x' + y);
        $targetX.val(x);
      };
      var setY = function(y) {
        x = getX();
        $target.val(x + 'x' + y);
        $targetY.val(y);
      };
      var getX = function() {
        return $target.val().split('x')[0];
      };
      var getY = function() {
        return $target.val().split('x')[1];
      };
      var resetXY = function(announce = false) {
        const defaultX = window.screen.width  * 0.8 | 0;
        const defaultY = window.screen.height * 0.8 | 0;
        setX(defaultX);
        setY(defaultY);
        if (announce)
          ariaNotify(`Resolution reset to ${defaultX} by ${defaultY} pixels.`);
      };

      // Set defaults if not already set
      if ( !$target.val() ) {
        resetXY();
      } else {
        setX(getX());
        setY(getY());
      }

      // Event listeners
      $targetX.on('change', () => {
        setX($targetX.val());
      });
      $targetY.on('change', () => {
        setY($targetY.val());
      });
      $targetR.on('click', () => {
        resetXY(true);
      });
    });
  }