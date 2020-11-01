# We store the info as follows . For each room (key), we get a dict, with keys/values
# ROOMPASS: refers to which password the room should unlock (if none = 0)
# DOORPASS: dict with keys being door number (numbering goes for top left corner, left to right and then down)
# CLUE: string
# INFO: purely for debugging (pathfinding test - on each room, we indicate where each player can go, e.g.
#       'INFO': {'G': [(2, 'E')], 'S': [(1, 'N'), (4, 'S')]} means that player G can take door 2 to go east
#       and player 'S' can take door 1 (north) or door 4 (south)
# SOLVER: also for debugging / pathfinding purposed - indicates which player must solve the room

DEFAULT_INFO = {'ROOMPASS': 0,
                'DOORPASS': {},
                'CLUE': '',
                }

CODE_REFERENCES = {1: "D11",
                   2: "D12",
                   3: "D13",
                   4: "D21",
                   5: "D22",
                   6: "D23",
                   7: "D31",
                   8: "D32",
                   9: "D33",

                   10: "S11",
                   11: "S12",
                   12: "S13",
                   13: "S21",
                   14: "S22",
                   15: "S23",
                   16: "S31",
                   17: "S32",
                   18: "S33",

                   19: "G11",
                   20: "G12",
                   21: "G13",
                   22: "G21",
                   23: "G22",
                   24: "G23",
                   25: "G31",
                   26: "G32",
                   27: "G33",
                   }


def ref2num(x):
    ref = list(CODE_REFERENCES.values())
    num = list(CODE_REFERENCES.keys())
    return num[ref.index(x)]


ROOM_INFO = {1: {'ROOMPASS': 0,
                 'DOORPASS': {},
                 'CLUE': 'Il vous manque une case',
                 'INFO': {'S': [(1, 'N')]}
                 },
             2: {'ROOMPASS': ref2num('S32'),  # 17
                 'DOORPASS': {1: ref2num('G11')},
                 'CLUE': 'Vous devriez utiliser vosdoigts',
                 'INFO': {'S': [(1, 'N'), (2, 'W')]},
                 'SOLVER': 'S'
                 },
             3: {'ROOMPASS': ref2num('S11'),
                 'DOORPASS': {},
                 'CLUE': 'Un peu de perspective',
                 'SOLVER': 'S'
                 },
             4: {'ROOMPASS': ref2num('D23'),
                 'DOORPASS': {},
                 'CLUE': 'Il suffirait de peu pour etre juste',
                 'SOLVER': 'D'
                 },
             5: {'ROOMPASS': ref2num('D31'),
                 'DOORPASS': {2: ref2num('G23')},
                 'CLUE': 'Transcendance',
                 'INFO': {'D': [(2, 'S')]},
                 'SOLVER': 'D'
                 },
             6: {'ROOMPASS': 0,
                 'DOORPASS': {},
                 'CLUE': 'Il vous manque une case',
                 'INFO': {'D': [(1, 'W')]}
                 },
             7: {'ROOMPASS': ref2num('S12'),
                 'DOORPASS': {},
                 'CLUE': 'Soyons clair et mettons  les points sur les i',
                 'SOLVER': 'S'
                 },
             8: {'ROOMPASS': ref2num('S21'),
                 'DOORPASS': {1: ref2num('D12'),
                              3: ref2num('D32')},
                 'CLUE': 'Le temps est ecoule',
                 'INFO': {'S': [(1, 'W'), (3, 'S')]},
                 'SOLVER': 'S'
                 },
             9: {'ROOMPASS': ref2num('D22'),
                 'DOORPASS': {},
                 'CLUE': 'Content Pas Content',
                 'SOLVER': 'D'
                 },
             10: {'ROOMPASS': 0,
                  'DOORPASS': {},
                  'CLUE': 'Vous ne devriez pas etre ici',
                  },
             11: {'ROOMPASS': ref2num('D32'),
                  'DOORPASS': {2: ref2num('G33')},
                  'CLUE': 'Pauvre Blinky',
                  'INFO': {'D': [(2, 'E')]},
                  'SOLVER': 'D'
                  },
             12: {'ROOMPASS': ref2num('D13'),
                  'DOORPASS': {3: ref2num('S21')},
                  'CLUE': 'Par ici la sortie',
                  'INFO': {'D': [(1, 'W'), (3, 'S')]},
                  'SOLVER': 'D'
                  },
             13: {'ROOMPASS': ref2num('G22'),
                  'DOORPASS': {},
                  'CLUE': 'Kori o tokasu',
                  'SOLVER': 'G'
                  },
             14: {'ROOMPASS': ref2num('S23'),
                  'DOORPASS': {1: ref2num('D13')},
                  'CLUE': 'Retour a la racine',
                  'INFO': {'S': [(1, 'N')]},
                  'SOLVER': 'S'
                  },
             15: {'ROOMPASS': 0,
                  'DOORPASS': {3: ref2num('S31')},
                  'CLUE': 'A l\'identique.           Mais surtout a gauche',
                  'INFO': {'S': [(1, 'N')],
                           'D': [(3, 'E')]},
                  # 'SOLVER': 'S'
                  },
             16: {'ROOMPASS': ref2num('D33'),
                  'DOORPASS': {2: ref2num('D23')},
                  'CLUE': 'Dans la continuite',
                  'INFO': {'S': [(2, 'W')],
                           'D': [(4, 'S')]},
                  'SOLVER': 'D'
                  },
             17: {'ROOMPASS': 0,
                  'DOORPASS': {},
                  'CLUE': 'Un miroir vers l\'infini',
                  'INFO': {'D': [(2, 'S')]},
                  # 'SOLVER': 'D'
                  },
             18: {'ROOMPASS': ref2num('D12'),
                  'DOORPASS': {2: ref2num('G31')},
                  'CLUE': 'Remplissez moi jusqu\'au  bord',
                  'INFO': {'D': [(2, 'W')]},
                  'SOLVER': 'D'
                  },
             19: {'ROOMPASS': ref2num('G12'),
                  'DOORPASS': {2: ref2num('G13'),
                               3: ref2num('D22')},
                  'CLUE': 'America !',
                  'INFO': {'S': [(2, 'W')],
                           'G': [(3, 'E')]},
                  'SOLVER': 'G'
                  },
             20: {'ROOMPASS': ref2num('S31'),
                  'DOORPASS': {2: ref2num('D11')},
                  'CLUE': 'Transcendance',
                  'INFO': {'S': [(2, 'S')]},
                  'SOLVER': 'S'
                  },
             21: {'ROOMPASS': ref2num('S13'),
                  'DOORPASS': {2: ref2num('G21')},
                  'CLUE': 'Franchir la ligne',
                  'INFO': {'S': [(2, 'S')]},
                  'SOLVER': 'S'
                  },
             22: {'ROOMPASS': 0,
                  'DOORPASS': {1: ref2num('G22')},
                  'CLUE': 'De la Suede a la Norvege',
                  'INFO': {'S': [(1, 'W'), (3, 'S')]},
                  # 'SOLVER': 'S'
                  },
             23: {'ROOMPASS': ref2num('D21'),
                  'DOORPASS': {2: ref2num('S13'),
                               3: ref2num('G32')},
                  'CLUE': 'C\'est bon les beignets.  Mais je prefererais un   donut',
                  'INFO': {'D': [(2, 'E'), (3, 'W')]},
                  'SOLVER': 'D'
                  },
             24: {'ROOMPASS': ref2num('G11'),
                  'DOORPASS': {3: ref2num('G12')},
                  'CLUE': 'Vive La reine ?',
                  'INFO': {'D': [(3, 'S')]},
                  'SOLVER': 'G'
                  },
             25: {'ROOMPASS': ref2num('S22'),
                  'DOORPASS': {},
                  'CLUE': 'Complementaire',
                  'INFO': {'S': [(1, 'N')], 'G': [(4, 'E')]},
                  'SOLVER': 'S'
                  },
             26: {'ROOMPASS': 0,
                  'DOORPASS': {},
                  'CLUE': 'This is the end.         Go towards the light!',
                  },
             27: {'ROOMPASS': ref2num('G13'),
                  'DOORPASS': {4: ref2num('S22')},
                  'CLUE': 'Compression horizontale',
                  'INFO': {'G': [(3, 'S')], 'D': [(4, 'S')]},
                  'SOLVER': 'G'
                  },
             28: {'ROOMPASS': ref2num('S33'),
                  'DOORPASS': {},
                  'CLUE': 'XOR a droite',
                  'INFO': {'D': [(3, 'S')]},
                  'SOLVER': 'S'
                  },
             29: {'ROOMPASS': ref2num('D11'),
                  'DOORPASS': {1: ref2num('D21')},
                  'CLUE': 'Miroir Miroir',
                  'INFO': {'G': [(1, 'N')],
                           'D': [(4, 'S')]},
                  'SOLVER': 'D'
                  },
             30: {'ROOMPASS': ref2num('G21'),
                  'DOORPASS': {1: ref2num('D33')},
                  'CLUE': '4 rotations a droite',
                  'INFO': {'G': [(1, 'E')]},
                  'SOLVER': 'G'
                  },
             31: {'ROOMPASS': ref2num('G23'),
                  'DOORPASS': {2: ref2num('D31')},
                  'CLUE': 'Trop rapide... Reduit le tempo par deux',
                  'INFO': {'G': [(2, 'E')]},
                  'SOLVER': 'G'
                  },
             32: {'ROOMPASS': 0,
                  'DOORPASS': {2: ref2num('S23')},
                  'CLUE': 'Il vous manque une case',
                  'INFO': {'G': [(1, 'N'), (2, 'S')]}
                  },
             33: {'ROOMPASS': ref2num('G31'),
                  'DOORPASS': {1: ref2num('S32'),
                               2: ref2num('S33')},
                  'CLUE': 'Rotation a 45 degres.',
                  'INFO': {'G': [(1, 'N'), (2, 'E')]},
                  'SOLVER': 'G'
                  },
             34: {'ROOMPASS': 0,
                  'DOORPASS': {},
                  'CLUE': 'Pas content, content',
                  'INFO': {'G': [(1, 'N')]}
                  },
             35: {'ROOMPASS': ref2num('G33'),
                  'DOORPASS': {1: ref2num('S11'),
                               2: ref2num('S12')},
                  'CLUE': 'Completez l\'escargot',
                  'INFO': {'G': [(1, 'N'), (2, 'E')]},
                  'SOLVER': 'G'
                  },
             36: {'ROOMPASS': ref2num('G32'),
                  'DOORPASS': {},
                  'CLUE': 'Gliders... Game of Life',
                  'SOLVER': 'G'
                  },
             }

if __name__ == "__main__":
    # very basic checks for the codes (making sure each code is assigned once only
    nopass = 0
    allpass = [1] * 27
    allrequest = [1] * 27

    for i in range(1, 37):
        r = ROOM_INFO[i]
        if r['ROOMPASS'] == 0:
            nopass += 1
        else:
            allpass[r['ROOMPASS'] - 1] -= 1

        code = r.get('DOORPASS', {})
        for c in list(code.values()):
            if c:
                allrequest[c - 1] -= 1
            else:
                print('Found None is request pass in room %i' %i)

    # Check the allocation of password when solving room - nopass should be 36 - 27 = 9
    # allpass should be a vector of zeros
    print('Is allocation complete ? %s' % (nopass == 9))
    print('Overallocated codes in rooms --> %s' % ([(i, x) for i, x in enumerate(allpass) if x < 0]))
    print('Unallocated codes in rooms --> %s' % ([(i, x) for i, x in enumerate(allpass) if x > 0]))
    print('Overrequested codes --> %s' % ([(CODE_REFERENCES[i+1], x) for i, x in enumerate(allrequest) if x < 0]))
    print('Unrequested codes --> %s' % ([(CODE_REFERENCES[i + 1], x) for i, x in enumerate(allrequest) if x > 0]))
