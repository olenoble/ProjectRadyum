################################################################################################################
################################################################################################################
# Very basic toolkit to generate roomdata.asm and roominfo.asm
import os
from info import ROOM_INFO, DEFAULT_INFO

if __name__ == '__main__':
    filename = 'rooms.c'
    maxroom = 16

    ################################################################################################################
    ################################################################################################################
    # All variables
    room_length = 20
    room_height = 10
    door_refs = ['0xff0000ff', '0xff000000']  # closed and open door
    mapping = {door_refs[0]: ['0ch', '0fh', '0dh', '0eh', '00h'],  # closed doors (top, left, right, bottom, target)
               door_refs[1]: ['1ch', '1fh', '1dh', '1eh', '00h'],  # open doors (top, left, right, bottom, target)
               '0xffffffef': ['04h', '06h', '07h', '05h', '00h'],  # walls (top, left, right, bottom, target)

               '0xff837f83': ['07h'] * 4 + ['00h'],  # additional walls (facing left)
               '0xffa3a39f': ['06h'] * 4 + ['00h'],  # additional walls (facing right)
               '0xff3b3b3b': ['04h'] * 4 + ['00h'],  # additional walls (facing down)
               '0xff1f3b43': ['05h'] * 4 + ['00h'],  # additional walls (facing up)

               '0xff939393': ['08h'] * 4 + ['00h'],  # additional corner (top left)
               '0xffababab': ['09h'] * 4 + ['00h'],  # additional corner (top right)
               '0xff1b373b': ['0bh'] * 4 + ['00h'],  # additional corner (bottom left)
               '0xff23434b': ['0ah'] * 4 + ['00h'],  # additional corner (bottom right)

               # '0xff8cffeb': ['09h', '07h', '07h', '0ah', '00h'],  # additional walls (facing left)
               # '0xff26ffd8': ['08h', '06h', '06h', '0bh', '00h'],  # additional walls (facing right)
               '0xffff3f1b': ['02h'] * 4 + ['00h'],  # Blue modifiable tile
               '0xffff0fef': ['03h'] * 4 + ['00h'],  # Red modifiable tile
               }
    corners = ['08h', '09h', '0bh', '0ah']  # corners (top left, top right, bottom left, bottom right)

    shift_map = {0: 0, (room_height - 1): 3}
    edge_map = {0: 1, (room_length - 1): 2}

    shift_map_target = {0: 4, (room_height - 1): 4}
    edge_map_target = {0: 4, (room_length - 1): 4}
    spacing = 20
    header = '; ***************************************************************************************\n' + \
             '; ***************************************************************************************\n' + \
             '; ** Room data - contains only room data (starting + target)\n' + \
             '; ** Require ...\n\n\n.DATA\n' + \
             '                    ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n' + \
             '                    ; All room data\n' + \
             '                    ; 400 bytes per room (20x10 for current and for target room)\n\n' + \
             '                    ; Room 1\nALL_ROOMS_DATA      '

    data_ending = '\n\n                    db 400 * (TOTAL_NUMBER_ROOM-%i) dup (0)\n\n' \
                  '.CODE'

    header_info = '; ***************************************************************************************\n' + \
                  '; ***************************************************************************************\n' + \
                  '; ** Room data - contains only room data (starting + target)\n' + \
                  '; ** Require ...\n\n\n.DATA\n' + \
                  '                    ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n' + \
                  '                    ; All room info\n' + \
                  '                    ; for the info 2 bytes (flags + code) & 8 bytes for actions - ' \
                  '25*3 bytes for the message = 85 bytes per room\n' + \
                  'ALL_ROOMS_INFO      '

    info_ending = '\n\n                    db 85 * (TOTAL_NUMBER_ROOM-%i) dup (0)\n\n' \
                  '.CODE'

    info_default = '001b, '
    info_endclue = ', "$", (75 - %s) dup (0)'

    ################################################################################################################
    ################################################################################################################
    # Generate roomdata.asm / roominfo.asm

    # Load file
    with open(filename, 'rb') as f:
        txt = f.read()

    # Get the room data (ignore header)
    rawdata = txt.decode('utf8').split('] = {')[1]

    # Loop over each room
    roomiter = 1
    reachend = False
    remaining = rawdata
    output = header
    output_info = header_info
    while roomiter <= maxroom and not reachend:
        try:
            pos = remaining.index('{\n')
        except Exception as exc:
            pos = -1
            reachend = True

        if pos >= 0:
            # Get original room
            origroom = remaining[(pos + 2):]
            endorig = origroom.index('}')
            origroom = origroom[:endorig]
            # Then target room
            targetroom = remaining[(pos + 2 + endorig + 5):]
            endtarget = targetroom.index('}')
            targetroom = targetroom[:endtarget]
            # Extract remaining
            remaining = remaining[(pos + 2 + endorig + 1 + endtarget + 3):]

            # Now read the data properly and map it to ASM type data
            data_orig = origroom.split('\n')[:-1]
            for i in range(room_height):
                row_data = data_orig[i].split(', ')[:room_length]
                res_row = [mapping.get(x, [x] * 4)[shift_map.get(i, edge_map.get(j, 0))]
                           for j, x in enumerate(row_data)]

                # override corners
                if i == 0:
                    res_row[0] = corners[0]
                    res_row[-1] = corners[1]
                if i == room_height - 1:
                    res_row[0] = corners[2]
                    res_row[-1] = corners[3]

                output += 'db ' + ', '.join(res_row) + '\n' + ''.join([' '] * spacing)

            output += '\n                    '
            # Adding the target room
            door_count = 0
            data_target = targetroom.split('\n')[:-1]
            door_info = {}
            for i in range(room_height):
                row_data = data_target[i].split(', ')[:room_length]
                res_row = [mapping.get(x, [x] * 4)[shift_map_target.get(i, edge_map_target.get(j, 0))]
                           for j, x in enumerate(row_data)]

                # add doors
                doors = [i for i, x in enumerate(row_data) if x in door_refs]
                for j in doors:
                    door_count += 1
                    res_row[j] = '0%ih' % door_count
                    room_shift_vert = {0: 1, (room_height - 1): -1}
                    room_shift_horiz = {0: 6, (room_length - 1): -6}

                    door_info[door_count] = roomiter + room_shift_vert.get(i, room_shift_horiz.get(j))

                output += 'db ' + ', '.join(res_row) + '\n' + ''.join([' '] * spacing)

            # now add info
            room_reference = ROOM_INFO.get(roomiter, DEFAULT_INFO)
            passw = str(room_reference['ROOMPASS'])
            doorpass = room_reference['DOORPASS']
            clue = room_reference['CLUE']
            info_str = ''.join(['db ', info_default, ' ' * (2 - len(passw)), str(passw), ', '])
            info_str += ''.join(['%s, %s, ' % (v, str(doorpass.get(k, 0))) for k, v in door_info.items()]) + \
                        ('0, 0, ' * (4 - len(door_info)))
            info_str += '"' + clue + '"' + (info_endclue % str(len(clue) + 1))
            output_info += info_str + '\n                    '

        if (roomiter + 1) <= maxroom and not reachend:
            output += '\n\n                    '
            output += '; Room %i\n' % (roomiter + 1)
            output += '                    '
        roomiter += 1

    # write file
    output += data_ending % maxroom
    with open('roomdata.asm', 'w') as f:
        f.write(output)

    output_info += info_ending % maxroom
    with open('roominfo.asm', 'w') as f:
        f.write(output_info)

    print('Done ')
