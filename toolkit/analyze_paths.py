################################################################################################################
################################################################################################################
# Simple pathfinder to test the logic
from info import ROOM_INFO, CODE_REFERENCES

players = {'S': {'status': [(0, 1, None, 0)]},
           'D': {'status': [(0, 6, None, 0)]},
           'G': {'status': [(0, 32, None, 0)]},
           }

move_shift = {'N': 1,
              'S': -1,
              'W': 6,
              'E': - 6
              }

final_room = 26

# list of already discovered code - if 1 then code was found
available_code = [1] + [0] * 27
code_used = [0] + [0] * 27

default_spacing = '    '


def whereWasCodeUsed(c):
    return [k for k, v in ROOM_INFO.items()
            if c in [CODE_REFERENCES.get(u) for u in v.get('DOORPASS', {}).values()]]


def carryon(name, status, room, spacing):
    print(spacing + 'Player %s is in room %i' % (name, room))
    prefix = spacing + 'Room %i - ' % room
    if room == final_room:
        print('   !!!!! You reached the end !!!!!')
        return [True]
    current = ROOM_INFO[room]

    # check is new pass was solved
    new_pass = name == current.get('SOLVER', '')
    if new_pass:
        if available_code[current['ROOMPASS']] == 0:
            print(prefix + 'Password %s (%i) was obtained' %
                  (CODE_REFERENCES[current['ROOMPASS']], current['ROOMPASS']))
            available_code[current['ROOMPASS']] += 1
        else:
            print(prefix + 'Password %s (%i) was already obtained' %
                  (CODE_REFERENCES[current['ROOMPASS']], current['ROOMPASS']))

    # check if way out
    wayout = current.get('INFO', {}).get(name)
    doorpass = current.get('DOORPASS', {})
    if wayout:
        for door in wayout:
            pass_req = doorpass.get(door[0])
            if pass_req:
                txt = prefix + 'Password %s (%i) is required for door %i, leading %s' \
                      % (CODE_REFERENCES[pass_req], pass_req, door[0], door[1])
                if available_code[pass_req] > 0:
                    print(txt + ' - Password is found!')
                    code_used[pass_req] += 1
                    status += carryon(name, status, room + move_shift[door[1]], spacing + default_spacing)
                else:
                    print(txt + ' - Password is not yet available')
                    status += [(pass_req, room + move_shift[door[1]], CODE_REFERENCES[pass_req], room)]
            else:
                print(prefix + 'Player %s is moving to room %i (no code required)' % (name, room + move_shift[door[1]]))
                status += carryon(name, status, room + move_shift[door[1]], spacing + default_spacing)
    else:
        print(prefix + 'This room is a dead-end...')

    return status


if __name__ == '__main__':
    player_list = ['S', 'D', 'G']

    good_to_go = True
    while good_to_go:
        for pn in player_list:
            print('#' * 100)
            print('Player %s is up' % pn)
            new_status = []
            curr_status = players[pn]['status']
            for s in curr_status:
                print('Trying to access room %i' % s[1])
                if available_code[s[0]] == 1:
                    print('Password %s (%i) is available' % (CODE_REFERENCES.get(s[0], 'default'), s[0]))
                    code_used[s[0]] += 1
                    new_status += carryon(pn, [], s[1], default_spacing)
                else:
                    print('Password %s (%i) is still not available' % (CODE_REFERENCES.get(s[0], 'default'), s[0]))
                    new_status += [s]

            if True in new_status:
                print('Taking player %s out of the game' % pn)
                player_list = [x for x in player_list if x != pn]
                players[pn]['status'] = [(0, 0, None, -1)]
            else:
                players[pn]['status'] = list(set(new_status))

        good_to_go = len(player_list) > 0
        print('@' * 100)
        print('End of turn')
        print('Players status --> %s' % {k: [(x[3], x[2]) for x in v['status']] for k, v in players.items()})
        print('Number of solved codes = %i' % sum(available_code[1:]))
        print('Solved codes = %s' % [CODE_REFERENCES[i] for i, x in enumerate(available_code) if i > 0 and x > 0])
        print('Unsolved codes = %s' % [CODE_REFERENCES[i] for i, x in enumerate(available_code) if i > 0 and x == 0])
        # have we solved the same code several times ?
        print('Oversolved codes = %s ' % [(i, x) for i, x in enumerate(available_code) if x > 1])

        usedup_codes = [CODE_REFERENCES[i] for i, x in enumerate(code_used) if x > 0 and i > 0]
        print('Number of used codes = %i ' % sum(code_used[1:]))
        print('Used codes --> %s' % [(x, whereWasCodeUsed(x)) for x in usedup_codes])
        print('Unused codes --> %s ' % [CODE_REFERENCES[i] for i, x in enumerate(code_used) if x == 0])
        print('Overused codes --> %s' % [(i, x) for i, x in enumerate(code_used) if x > 1 and i > 0])
        print('----> Moving to next round')

    print('done')
