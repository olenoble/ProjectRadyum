
import os

if __name__ == '__main__':
    filename = 'rooms.c'
    maxroom = 10

    mapping = {'0xff0000ff': ['0ch', '0fh', '0dh', '0eh'],  # closed doors (top, left, right, bottom)
               '0xff000000': ['1ch', '1fh', '1dh', '1eh'],  # open doors (top, left, right, bottom)
               '0xffffffef': ['04h', '06h', '07h', '05h'],  # walls (top, left, right, bottom)
               '0xffff3f1b': '02h',                         # Blue modifiable tile
               '0xffff0fef': '03h',                         # Red modifiable tile
               }
    corners = ['04h', '06h', '07h', '05h']  # corners (top left, top right, bottom left, bottom right)

    # Load file
    with open(filename, 'rb') as f:
        txt = f.read()

    # Get the room data (ignore header)
    rawdata = txt.decode('utf8').split('] = {')[1]

    # Remove closing brackets (we only need to locate the opening ones)
    # rawdata = rawdata.replace('},', '').replace('};', '').replace('}', '')

    # Loop over each room
    roomiter = 1
    reachend = False
    remaining = rawdata
    output = 'ALL_ROOMS_DATA      '
    while roomiter <= maxroom and not reachend:
        try:
            pos = remaining.index('{\n')
        except Exception as exc:
            pos = -1
            reachend = True

        if pos >= 0:
            # Get original room
            origroom = remaining[(pos+2):]
            endorig = origroom.index('}')
            origroom = origroom[:endorig]
            # Then target room
            targetroom = remaining[(pos+2 + endorig+1):]
            endtarget = targetroom.index('}')
            targetroom = targetroom[:endtarget]
            # Extract remaining
            remaining = remaining[(pos+2 + endorig+1 + endtarget+3):]

            # Now read the data properly and map it to ASM type data
            data_orig = origroom.split('\n')[:-1]

            # # we override the corners first
            # data_orig[0][0] = corners[0]
            # data_orig[0][-1] = corners[1]
            # data_orig[-1][0] = corners[2]
            # data_orig[-1][-1] = corners[3]

            shift_map = {0: 0,
                         9: 3
                         }
            edge_map = {0: 1,
                        19: 2
                        }

            for i in range(10):
                row_data = data_orig[i].split(', ')[:-1]
                res_row = [mapping.get(x, [x] * 4)[shift_map.get(i, edge_map.get(j, 0))]
                           for j, x in enumerate(row_data)]
                ', '.join(res_row)
                output += 'db ' + ', '.join(res_row) + '\n' + ''.join([' '] * 20)

    # write file
    with open('room.asm', 'w') as f:
        f.write(output)

