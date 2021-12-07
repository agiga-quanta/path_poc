__author__ = "Nghia Doan"
__company__ = "Agiga Quanta Inc."
__copyright__ = "Copyright 2021"
__version__ = "0.2.0"
__maintainer__ = "Nghia Doan"
__email__ = "nghia71@gmail.com"
__status__ = "Development"


def p_tag_sub(op, t):
    return op['ex'].sub(op['to'], t)


def p_tag_rem(op, t):
    if 'i' in op:
        if op['i'].search(t):
            return t
    match = op['ex'].search(t)
    if match:
        # print('--- [%s]' % t[match.start():match.end()])
        return None
    return t


def p_tag_sec(op, t, from_pos=0):
    match = op['ex'].search(t[from_pos:])
    if match:
        # print('--- [%s[%d:%d]]' % (t[match.start():match.end()], match.start(), match.end()))
        return { 'k': op['to'], 's': match.start() + from_pos, 'e': match.end() + from_pos }
    return t


def p_tag_etx(op, t):
    match = op['ex'].search(t)
    if match:
        # print('--- [%s]' % t[match.start():match.end()])
        return { k: match.group(k).strip() for k in op['to'] if match.group(k) }
    return t


def p_tag_pos(op, t):
    match = op['ex'].search(t)
    if match:
        return {op['to']: match.start()}
    return t


def p_tag_eta(op, t):
    matches = op['ex'].finditer(t)
    if matches:
        return [ 
            [ match.group(k).strip() for k in op['to'] ] 
            for match in matches
        ]
    return t


OP_MAP = {
    'p_tag_etx': p_tag_etx,
    'p_tag_rem': p_tag_rem,
    'p_tag_sec': p_tag_sec,
    'p_tag_sub': p_tag_sub,
    'p_tag_pos': p_tag_pos,
    'p_tag_eta': p_tag_eta,
}
