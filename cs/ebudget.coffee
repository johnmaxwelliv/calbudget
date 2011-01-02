l = (output) ->
    console.log(output)

Line = {
    'id': ->
        result = ''
        for c in this.name
            if c == ' '
                result += '-'
            else if c == '(' or c == ')'
                result += ''
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

addItems = ->
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
    lowerBound = addItems()
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
    $('#your-total').html(Math.round(actualTotal))
    for deduction in deductions
        $('#' + deduction.id()).html(Math.round(deduction.cost(actualTotal)))

$(document).ready(->
    for line in items
        $("#items").append("
        <div class='ctrlHolder'>
          <div class='info'>
            <label for=''>${ line.name }</label>
            <p class='formHint'>${ if line.desc? then line.desc else '' }</p>
          </div>
          <div class='textInputHolder'>
            <span class='dollar'>$</span><input name='' id='${ line.id() }' class='textInput small' value='${ line.default }' size='35' maxlength='50' type='text' />
          </div>
        </div>
        ")
        $('#' + line.id()).change(update)
    for line in deductions
        $("#deductions").append("
        <div class='ctrlHolder'>
          <div class='info'>
            <label for=''>${ line.name }</label>
            <p class='formHint'>${ if line.desc? then line.desc else '' }</p>
          </div>
          <div class='textInputHolder'>
            <span class='dollar'>$</span><span id='${ line.id() }' class='output'></span>
          </div>
        </div>
        ")
    $("#spreadsheet").append("
    <div class='ctrlHolder'>
      <div class='info'>
        <label for=''>Gross Income Required</label>
        <p class='formHint'>The monthly income you'll need to afford everything</p>
      </div>
      <div class='textInputHolder outputHolder'>
        <span class='dollar'>$</span><span id='your-total' class='output'></span>
      </div>
    </div>
    ")
    update()
)
