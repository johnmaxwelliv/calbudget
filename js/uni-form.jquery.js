jQuery.fn.budgetForm = function(settings) {
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
$(document).ready(function() {
    jQuery('form').budgetForm();
});

