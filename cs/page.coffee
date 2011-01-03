l = (output) ->
    console.log(output)

Line = {
    'cost': (income) ->
        return income * this.portion
    'readInput': ->
        if not this.valid()
            this.amount = 0
        else
            interm = ''
            v = this.input.val()
            for i in [0...v.length]
                c = v.charAt(i)
                if c != ','
                    interm += c
            this.amount = parseInt(interm, 10)
    'reset': ->
        this.input.val('0')
        this.select.val('0')
        this.amount = 0
    'valid': ->
        if not this.input.val()
            return false
        v = this.input.val()
        if v.length > 7
            return false
        for i in [0...v.length]
            c = v.charAt(i)
            if c not in ['1', '2', '3', '4', '5', '6', '7', '8', '9', '0', ',']
                return false
        return true
    'sanitize': ->
        if not this.valid()
            this.reset()
}

expenses = [
    {
        'name': 'Entertainment',
        'desc': 'Events, home entertainment, pets, toys, hobbies, etc.',
        'examples': {
            'Average for $60K/yr': 217,
            'Average for $40K/yr': 165,
            'Average for $25K/yr': 125,
        },
    }
]

taxes = [
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

lowestThatFits = (lower, upper, criterion, tolerance, PID) ->
    while (upper - lower) > tolerance
        if PID != latestPID
            return false
        guess = (upper + lower) / 2
        if criterion(guess)
            upper = guess
        else
            lower = guess
    return (upper + lower) / 2

latestPID = 0

updateCalculations = ->
    startTime = new Date()
    PID = startTime.getMilliseconds()
    latestPID = PID

    totalSpending = 0
    for expense in expenses
        totalSpending += expense.amount
    lowerBound = totalSpending
    for tax in taxes
        lowerBound += tax.cost(lowerBound)

    actualTotal = lowestThatFits(lowerBound, lowerBound * 2,
        (income) ->
            remaining = income
            for tax in taxes
                remaining -= tax.cost(income)
            remaining -= totalSpending
            return remaining >= 0
        , 1, PID)

    if actualTotal != false
        $('#your-total').html(Math.round(actualTotal))
        for tax in taxes
            tax.output.html(Math.round(tax.cost(actualTotal)))

makeID = (str) ->
    result = ''
    for i in [0...str.length]
        c = str.charAt(i)
        if c == ' '
            result += '-'
        else if c != '(' and c != ')'
            result += c
    return result

prepExpense = (line) ->
    line.amount = 0
    baseID = makeID(line.name)
    line.inputID = baseID + '-input'
    line.selectID = baseID + '-select'
    for method of Line
        line[method] = Line[method]

prepTax = (line) ->
    baseID = makeID(line.name)
    line.outputID = baseID + '-output'
    for method of Line
        line[method] = Line[method]

$(document).ready(->
    for line in expenses
        prepExpense(line)
        options = ("<option value='${ line.examples[ex] }'>${ ex }</option>" for ex of line.examples)
        $("#expenses").append("
        <div class='ctrlHolder'>
          <div class='info'>
            <label for=''>${ line.name }</label>
            <p class='formHint'>${ if line.desc? then line.desc else '' }</p>
          </div>
          <div class='selectInputHolder'>
            <select id='${ line.selectID }'><option value='0'>insert an example value...</option>${ options.join('') }</select>
          </div>
          <div class='textInputHolder'>
            <span class='dollar'>$</span><input name='' id='${ line.inputID }' class='textInput small' value='0' size='35' maxlength='50' type='text' />
          </div>
        </div>
        ")
        line.input = $('#' + line.inputID)
        line.select = $('#' + line.selectID)
        line.input.keyup(->
            line.select.val('0')
            line.readInput()
            updateCalculations()
        )
        line.input.blur(->
            if not line.valid()
                line.reset()
                # No need to updateCalculations as the line has been reporting its value as 0 anyway
        )
        line.select.change(->
            line.input.val(line.select.val())
            line.readInput()
            updateCalculations()
        )
    for line in taxes
        prepTax(line)
        $("#taxes").append("
        <div class='ctrlHolder'>
          <div class='info'>
            <label for=''>${ line.name }</label>
            <p class='formHint'>${ if line.desc? then line.desc else '' }</p>
          </div>
          <div class='textOutputHolder'>
            <span class='dollar'>$</span><span id='${ line.outputID }' class='output'></span>
          </div>
        </div>
        ")
        line.output = $('#' + line.outputID)
    updateCalculations()
)
