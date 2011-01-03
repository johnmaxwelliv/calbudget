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
                if c != ',' and c != '$'
                    interm += c
            if interm
                this.amount = parseInt(interm, 10)
            else
                this.amount = 0
        if this.onRead?
            this.onRead()
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
            if c not in ['1', '2', '3', '4', '5', '6', '7', '8', '9', '0', ',', '$']
                return false
        return true
    'sanitize': ->
        if not this.valid()
            this.reset()
}

expenses = [
    {
        'name': 'Rent',
        'desc': 'Your monthly rent',
        'examples': {
            'Typical rent in San Francisco area': 1069,
            'Typical rent in Los Angeles area': 927,
            'Typical rent in San Diego area': 924,
        },
    },
    {
        'name': 'Savings',
        'desc': "Money you're stashing away",
        'examples': {
            '$50 per month': 50,
            '$150 per month': 150,
        },
        'postPrep': ->
            this.input.parent().append("
            <table id='forecast' class='formHint'>
              <tr><th>Years</th><td>15</td><td>30</td><td>45</td></tr>
              <tr><th>Amount you'll have (assumes 1% annual interest)</th><td id='a15'>$0</td><td id='a30'>$0</td><td id='a45'>$0</td></tr>
            </table>
            ")
            this.a15 = $('#a15')
            this.a30 = $('#a30')
            this.a45 = $('#a45')
        ,
        'forecastAhead': (years) ->
            deposits = years * 12
            rate = 1.00082954
            result = 0
            for i in [1...(deposits + 1)]
                result *= rate
                result += this.amount
            return result
        ,
        'onRead': ->
            this.a15.html('$' + withCommas(Math.round(this.forecastAhead(15))))
            this.a30.html('$' + withCommas(Math.round(this.forecastAhead(30))))
            this.a45.html('$' + withCommas(Math.round(this.forecastAhead(45))))
        ,
    },
    {
        'name': 'Auto Loan Payment / Lease Payment',
        'desc': "Loan payments are typically higher than lease payments, but you own the car in full once you're done paying them.  To learn more about buying versus leasing, read <a href=\"http://www.consumerreports.org/cro/money/credit-loan/auto-lease-or-buy-4-08/overview/auto-lease-or-buy-ov.htm\">this</a>",
        'examples': {
            'Typical loan payment': 437,
            'Typical lease payment': 240,
        },
    },
    {
        'name': 'Cell Phone',
        'desc': 'Monthly cell phone bill',
        'examples': {
            'Typical monthly bill': 63,
        }
    },
    {
        'name': 'Entertainment',
        'desc': 'Budget allocated for events, home entertainment, pets, toys, hobbies, etc',
        'examples': {
            'Typical for $25K/yr salary': 125,
            'Typical for $40K/yr salary': 165,
            'Typical for $60K/yr salary': 217,
        },
    },
    {
        'name': 'Groceries',
        'desc': 'Cost of the food you eat at home',
        'examples': {
            'Typical for $25K/yr salary': 249,
            'Typical for $40K/yr salary': 263,
            'Typical for $60K/yr salary': 312,
        },
    },
    {
        'name': 'Restaurants',
        'desc': 'Cost of the eating out',
        'examples': {
            'Typical for $25K/yr salary': 118,
            'Typical for $40K/yr salary': 158,
            'Typical for $60K/yr salary': 222,
        },
    },
    {
        'name': "Renter's Insurance",
        'desc': 'Repays you for damaged or stolen valuables, and protects you if you are responsible for injury or property damage to others',
        'examples': {
            "Typical renter's insurance": 9,
        },
    },
    {
        'name': 'Auto Insurance',
        'desc': 'Provides protection against traffic collision damage and liability',
        'examples': {
            "Typical auto insurance": 77,
        },
    },
    {
        'name': 'Health Insurance',
        'desc': 'Helps pay medical bills in the event of injury or illness',
        'examples': {
            "Typical health insurance": 90,
        },
    },
    {
        'name': 'Life Insurance (optional)',
        'desc': 'Pays family members in the event of your death',
        'examples': {
            "No life insurance": 0,
            "Typical life insurance": 12,
        },
    },
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
        $('#your-total').html(withCommas(Math.round(actualTotal)))
        for tax in taxes
            tax.output.html(withCommas(Math.round(tax.cost(actualTotal))))

withCommas = (n) ->
    interm = String(n)
    len = interm.length
    result = [interm.charAt(0)]
    magicMod = len % 3
    for i in [1...len]
        if i % 3 == magicMod
            result.push(',')
        result.push(interm.charAt(i))
    return result.join('')

makeID = (str) ->
    result = ''
    for i in [0...str.length]
        c = str.charAt(i)
        if c == ' '
            result += '-'
        else if c != '(' and c != ')' and c != '/' and c != "'"
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
        if line.postPrep?
            l('doing postPrep')
            line.postPrep()
        else
            l('no postPrep')
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
