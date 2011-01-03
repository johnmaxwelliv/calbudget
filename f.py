def median(seq):
    seq.sort()
    return seq[len(seq) / 2]

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
    return p[0], (p[1] + p[2]) / 2, p[3]

def m(data):
    p = points(data)
    return (max(p), median(p), min(p))
