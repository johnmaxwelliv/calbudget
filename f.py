def median(seq):
    seq.sort()
    return seq[len(seq) / 2]

def db12(s):
    cur = ''
    result = ''
    for c in s:
        if c in '1234567890':
            cur += c
        elif cur:
            result += str(int(cur) / 12)
            cur = ''
            result += c
        else:
            result += c
    if cur:
        result += str(int(cur) / 12)
    result += c
    return result

def e(s):
    nocommas = ''
    for c in s:
        if c != ',':
            nocommas += c
    return round(eval(nocommas) / 12)

def points(data):
    cur = ''
    result = []
    for c in data:
        if c in '1234567890':
            cur += c
        elif c == ' ' and cur:
            result.append(int(cur))
            cur = ''
    if cur:
        result.append(int(cur))
    return [item / 12 for item in result]

def t(data):
    p = points(data)
    print """
            'Typical for $25K/yr salary': %d,
            'Typical for $40K/yr salary': %d,
            'Typical for $60K/yr salary': %d,
    """ % (p[0], (p[1] + p[2]) / 2, p[3])

def m(data):
    p = points(data)
    return (max(p), median(p), min(p))
