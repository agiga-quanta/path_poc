__author__ = "Nghia Doan"
__company__ = "Agiga Quanta Inc."
__copyright__ = "Copyright 2021"
__version__ = "0.2.0"
__maintainer__ = "Nghia Doan"
__email__ = "nghia71@gmail.com"
__status__ = "Development"


from collections import defaultdict
import re


def p_tag_src(regex, t):
    return regex['ex'].search(t)


def p_tag_sub(regex, t):
    return regex['ex'].sub(regex['to'], t)


def p_tag_eta(regex, t):
    found = False
    result_dict = defaultdict(list)

    matches = regex['ex'].finditer(t)
    for match_groups in matches:
        for key in regex['keys']:
            match = match_groups.group(key)
            if match:
                result_dict[key].append(match.strip() if 'strip' not in regex or not regex['strip'] else match.strip(regex['strip']))
                found = True
    
    if found:
        t = regex['ex'].sub('', t)

    return result_dict, t


def p_tag_sec(op, t, from_pos=0):
    match = op['ex'].search(t[from_pos:])
    if match:
        # print('--- [%s[%d:%d]]' % (t[match.start():match.end()], match.start(), match.end()))
        return { 'k': op['to'], 's': match.start() + from_pos, 'e': match.end() + from_pos }
    return t


def p_tag_sea(op, t):
    matches = op['ex'].finditer(t)
    if matches:

        result_list = []
        match_set = set()
        for match in matches:

            match_list = []
            ignore_match = False
            for k in op['to']:
                v = match.group(k).strip()
                if k == 'bullet' and v in match_set:
                    ignore_match = True
                    break
                match_set.add(v)
                match_list.append(v)
        
            if not ignore_match:
                result_list.append(match_list)
        
        return result_list

    return t


def p_tag_pos(op, t):
    match = op['ex'].search(t)
    if match:
        return {op['to']: match.start()}
    return t


def p_tag_etx(op, t):
    match = op['ex'].search(t)
    if match:
        # print('--- [%s]' % t[match.start():match.end()])
        return { k: match.group(k).strip() for k in op['to'] if match.group(k) }
    return t


FUNC_MAP = {
    'p_tag_src': p_tag_src,
    'p_tag_sub': p_tag_sub,
    'p_tag_eta': p_tag_eta,
    'p_tag_sec': p_tag_sec,
    'p_tag_pos': p_tag_pos,
    'p_tag_etx': p_tag_etx,
    'p_tag_sea': p_tag_sea,
}


def init_ops(regex_list):
    for regex in regex_list:
        regex['func'] = FUNC_MAP[regex['func']]
        regex['ex'] = re.compile(regex['ex']) if 'c' in regex and regex['c'] else re.compile(regex['ex'], re.IGNORECASE)
    return regex_list
