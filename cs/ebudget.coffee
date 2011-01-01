l = (output) ->
    console.log(output)

items = [
    {
        'name': 'a',
        'default': 1,
    },
    {
        'name': 'b',
        'default': 2,
    }
]

deductions = [
    {
        'name': 'Medicare',
        'desc': 'Goes to finance Medicare, which provides health insurance for seniors',
        'portion': 0.0145,
    },
    {
        'name': 'State Disability Insurance',
        'desc': "Pays for California's disability income replacement program",
        'portion': 0.011,
    },
    {
        'name': 'Social Security (FICA)',
        'desc': 'Pays for several social welfare programs, including retirement benefits',
        'portion': 0.062,
    },
    {
        'name': 'State Income Tax (approximate)',
        'desc': 'Money for the state of California',
        'portion': 0.03,
    },
    {
        'name': 'Federal Income Tax (approximate)',
        'desc': 'Money for the federal government',
        'portion': 0.15,
    },
]

getTotal = ->
    total = 0
    for item in items
        total += parseInt($('#' + item.name).val(), 10)
    return total

update = ->
    $('#your-total').html(getTotal())

$(document).ready(->
    for item in items
        $("#spreadsheet").append("
        <div class='ctrlHolder'>
          <label for=''>${ item.name }</label>
          <input name='' id='${ item.name }' value='${ item.default }' size='35' maxlength='50' type='text' class='textInput small'/>
          <p class='formHint'>This is a form hint.</p>
        </div>
        ")
        $('#' + item.name).change(update)
    $("#spreadsheet").append('<tr> <td>Total</td> <td id="default-total">' + String(getTotal()) + '</td> <td id="your-total"></td> </tr>')
    update()
)
