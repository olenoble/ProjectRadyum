################################################################################################################
################################################################################################################
# tool to read the qr-code generated there:
from info import ROOM_INFO, DEFAULT_INFO

if __name__ == '__main__':
    filename = 'qrcode.txt'
    is_html = False
    block_mapping = {'▄': '0dch',  # 220
                     '█': '0dbh',  # 219
                     '▀': '0dfh',  # 223
                     ' ': '020h'
                     }

    # Load file
    with open(filename, 'rb') as f:
        txt = f.read()
    rawdata = txt.decode('utf8').split('\r\n')

    if is_html:
        # to implement
        print('uh')
    else:
        out = ''
        for row in rawdata:
            rowmap = [block_mapping[x] for x in row]
            row_txt = 'db ' + ', '.join(rowmap) + ', 13, 10\n'
            out += row_txt

    with open('qrcode.asm', 'w') as f:
        f.write(out)

        print(txt)
