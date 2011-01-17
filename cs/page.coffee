l = (output) ->
    console.log(output)

Line = {
    'flat': (income) ->
        return income * this.portion
    'payroll': (income) ->
        if income < this.limit
            return income * this.portion
        else
            return this.limit * this.portion
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
        'name': 'Auto Loan Payment / Lease Payment',
        'desc': "Loan payments are typically higher than lease payments, but you own the car in full once you're done paying them.  To learn more about buying versus leasing, read <a href=\"http://www.consumerreports.org/cro/money/credit-loan/auto-lease-or-buy-4-08/overview/auto-lease-or-buy-ov.htm\">this</a>",
        'examples': {
            'Typical loan payment': 437,
            'Typical lease payment': 240,
        },
    },
    {
        'name': 'Groceries',
        'desc': 'Cost of the food you eat at home',
        'examples': {
            'Typical for $25K/yr salary': 129,
            'Typical for $40K/yr salary': 137,
            'Typical for $60K/yr salary': 162,
        },
    },
    {
        'name': 'Restaurants',
        'desc': 'Cost of eating out',
        'examples': {
            'Typical for $25K/yr salary': 68,
            'Typical for $40K/yr salary': 91,
            'Typical for $60K/yr salary': 127,
        },
    },
    {
        'name': 'Apparel',
        'desc': 'Clothing and shoes',
        'examples': {
            'Typical for $25K/yr salary': 51,
            'Typical for $40K/yr salary': 60,
            'Typical for $60K/yr salary': 76,
        },
    },
    {
        'name': 'Cell Phone',
        'desc': 'Monthly cell phone bill',
        'examples': {
            'Typical monthly bill': 63,
        },
    },
    {
        'name': 'Repairs',
        'desc': 'Car, home, etc',
        'examples': {
            'Typical for $25K/yr salary': 93,
            'Typical for $40K/yr salary': 111,
            'Typical for $60K/yr salary': 154,
        },
    },
    {
        'name': 'Personal Care',
        'desc': 'Hair, nails, beard, etc',
        'examples': {
            'Typical for $25K/yr salary': 18,
            'Typical for $40K/yr salary': 21,
            'Typical for $60K/yr salary': 27,
        },
    },
    {
        'name': 'Other essential spending',
        'desc': 'Whatever else you need to spend money on',
        'examples': {
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
        'heading': '#discretionary',
    },
    {
        'name': 'Charitable Giving',
        'desc': 'Donations to charities',
        'examples': {
            'Typical for $25K/yr salary': 62,
            'Typical for $40K/yr salary': 102,
            'Typical for $60K/yr salary': 144,
        },
        'heading': '#discretionary',
    },
    {
        'name': 'Cable TV',
        'examples': {
            'Typical cable TV cost': 50,
        },
        'heading': '#discretionary',
    },
    {
        'name': 'Vacation Expenses',
        'desc': 'Food and lodging away from home',
        'examples': {
            'Average 1 vacation day/month': 244,
            'Average 2 vacation days/month': 488,
        },
        'heading': '#discretionary',
    },
    {
        'name': 'Entertainment',
        'desc': 'Budget allocated for other entertainment: events, pets, electronics, hobbies, etc',
        'examples': {
            'Typical for $25K/yr salary': 42,
            'Typical for $40K/yr salary': 64,
            'Typical for $60K/yr salary': 93,
        },
        'heading': '#discretionary',
    },
    {
        'name': 'Other discretionary spending',
        'desc': 'Whatever else you want to spend money on',
        'examples': {
        },
        'heading': '#discretionary',
    },
    {
        'name': "Renter's Insurance",
        'desc': 'Repays you for damaged or stolen valuables, and protects you if you are responsible for injury or property damage to others',
        'examples': {
            "Typical renter's insurance": 9,
        },
        'heading': '#insurance',
    },
    {
        'name': 'Auto Insurance',
        'desc': 'Provides protection against traffic collision damage and liability',
        'examples': {
            "Typical auto insurance": 77,
        },
        'heading': '#insurance',
    },
    {
        'name': 'Health Insurance',
        'desc': 'Helps pay medical bills in the event of injury or illness',
        'examples': {
            "Typical health insurance": 90,
        },
        'heading': '#insurance',
    },
    {
        'name': 'Life Insurance (optional)',
        'desc': 'Pays family members in the event of your death',
        'examples': {
            "Typical life insurance": 12,
        },
        'heading': '#insurance',
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
        'portion': 0.012,
        'limit': 7776,
    },
    {
        'name': 'Social Security (FICA)',
        'desc': 'Pays for several social welfare programs, including retirement benefits',
        'portion': 0.062,
        'limit': 8500,
    },
    {
        'name': 'State Income Tax',
        'desc': 'Money for the state of California',
        'portion': 0.03,
        'cost': (income) ->
            if income < 568 then 0.0 + .01 * (income - 0)
            else if income < 1348 then 5.2 + .02 * (income - 568)
            else if income < 2128 then 21.3 + .04 * (income - 1348)
            else if income < 2955 then 52.6 + .06 * (income - 2128)
            else if income < 3734 then 102.6 + .08 * (income - 2955)
            else 164.0 + .093 * (income - 3734)
        ,
    },
    {
        'name': 'Federal Income Tax',
        'desc': 'Money for the federal government',
        'cost': (income) ->
            if income < 697 then 0.1 * income
            else if income < 2833 then 69.4 + .15 * (income - 697)
            else if income < 6866 then 390.2 + .25 * (income - 2833)
            else if income < 14320 then 1398.2 + .28 * (income - 6866)
            else if income < 31137 then 3485.2 + .33 * (income - 14320)
            else 9035.2 + .35 * (income - 31137)
        ,
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
        $('#monthly-gross').html(withCommas(Math.round(actualTotal)))
        $('#annual-gross').html(withCommas(Math.round(actualTotal * 12)))
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
    if not line.cost?
        if line.limit?
            line.cost = line.payroll
        else
            line.cost = line.flat

$(document).ready(->
    for line in expenses
        prepExpense(line)
        options = ("<option value='${ line.examples[ex] }'>${ ex }</option>" for ex of line.examples)
        if line.heading?
            myDiv = $(line.heading)
        else
            myDiv = $("#expenses")
        myDiv.append("
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
            line.postPrep()
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
