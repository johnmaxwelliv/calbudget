l = (output) ->
    console.log(output)

Line = {
    'id': ->
        result = ''
        for i in [0...this.name.length]
            c = this.name.charAt(i)
            if c == ' '
                result += '-'
            else if c != '(' and c != ')'
                result += c
        return result
    'cost': (income) ->
        return income * this.portion
    'val': (arg) ->
        if arg?
            $('#' + this.id()).val(arg)
        else
            $('#' + this.id()).val()
    'updateAmount': ->
        if not this.valid()
            return 0
        interm = ''
        for c in this.val()
            if c != ','
                interm += c
        this.amount = parseInt(interm, 10)
        return this.amount
    'reset': ->
        this.val('0')
    'valid': ->
        if not this.val()
            return false
        v = this.val()
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

update = ->
    startTime = new Date()
    PID = startTime.getMilliseconds()
    latestPID = PID

    totalSpending = 0
    for item in items
        totalSpending += item.updateAmount()
    lowerBound = totalSpending
    for deduction in deductions
        lowerBound += deduction.cost(lowerBound)

    actualTotal = lowestThatFits(lowerBound, lowerBound * 2,
        (income) ->
            remaining = income
            for deduction in deductions
                remaining -= deduction.cost(income)
            remaining -= totalSpending
            return remaining >= 0
        , 10, PID)

    if actualTotal != false
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
        $('#' + line.id()).keyup(->
            update()
        )
        $('#' + line.id()).blur(->
            line.sanitize()
            update()
        )
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
