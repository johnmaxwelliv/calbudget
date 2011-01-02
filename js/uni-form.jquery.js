// Author: Ilija Studen for the purposes of Uni–Form

// Modified by Aris Karageorgos to use the parents function

// Modified by Toni Karlheinz to support input fields' text
// coloring and removal of their initial values on focus

// Modified by Jason Brumwell for optimization, addition
// of valid and invalid states and default data attribues

jQuery.fn.uniform = function(settings) {
    settings = jQuery.extend({
        focused_class  : 'focused',
        holder_class   : 'ctrlHolder',
        field_selector : 'input, textarea, select',
    }, settings);
  
    return this.each(function() {
        var form = jQuery(this)

        form.delegate(settings.field_selector,'focus',function() {
            form.find('.' + settings.focused_class).removeClass(settings.focused_class);

            var $input = $(this);

            $input.parents().filter('.'+settings.holder_class+':first').addClass(settings.focused_class);
        });

        form.delegate(settings.field_selector,'blur',function() {
            var $input = $(this);
            form.find('.' + settings.focused_class).removeClass(settings.focused_class);
        });
    });
};
// Auto set on page load...
$(document).ready(function() {
    jQuery('form').uniform();
});

