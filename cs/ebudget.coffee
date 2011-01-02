l = (output) ->
    console.log(output)

Line = {
    'id': ->
        result = ''
        for c in this.name
            if c == ' '
                result += '-'
            else
                result += c
        return result
    'cost': (income) ->
        if this.portion?
            return income * this.portion
    'amount': ->
        interm = ''
        for c in $('#' + this.id()).val()
            if c != ','
                interm += c
        return parseInt(interm, 10)
}

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

for item in items
    for prop of Line
        item[prop] = Line[prop]

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

for deduction in deductions
    for prop of Line
        deduction[prop] = Line[prop]

getTotal = ->
    total = 0
    for item in items
        total += item.amount()
    return total

lowestThatFits = (lower, upper, criterion, tolerance) ->
    guess = (upper + lower) / 2
    if (upper - lower) < tolerance
        return guess
    if criterion(guess)
        return lowestThatFits(lower, guess, criterion, tolerance)
    else
        return lowestThatFits(guess, upper, criterion, tolerance)

update = ->
    lowerBound = getTotal()
    for deduction in deductions
        lowerBound += deduction.cost(lowerBound)
    actualTotal = lowestThatFits(lowerBound, lowerBound * 2,
        (income) ->
            for deduction in deductions
                income -= deduction.cost(income)
            for item in items
                income -= item.amount()
            return income >= 0
        , 0.1)
    $('#your-total').html(actualTotal)

$(document).ready(->
    for item in items
        $("#items").append("
        <div class='ctrlHolder'>
          <div class='info'>
            <label for=''>${ item.name }</label>
            <p class='formHint'>${ if item.desc? then item.desc else '' }</p>
          </div>
          <div class='textInputHolder'><span class='dollar'>$</span><input name='' id='${ item.id() }' class='textInput small' value='${ item.default }' size='35' maxlength='50' type='text' /></p>
        </div>
        ")
        $('#' + item.id()).change(update)
    for deduction in deductions
        $("#deductions").append("
        <div class='ctrlHolder'>
          <div class='info'>
            <label for=''>${ deduction.name }</label>
            <p class='formHint'>${ if deduction.desc? then deduction.desc else '' }</p>
          </div>
          <input name='' id='${ deduction.id() }' data-default-value='Placeholder text' size='35' maxlength='50' type='text' class='textInput small'/>
        </div>
        ")
    $("#spreadsheet").append('<tr> <td>Total</td> <td id="default-total">' + String(getTotal()) + '</td> <td id="your-total"></td> </tr>')
    update()
)
