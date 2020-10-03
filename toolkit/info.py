# We store the info as follows . For each room (key), we get a dict, with keys/values
# ROOMPASS: refers to which password the room should unlock (if none = 0)
# DOORPASS: dict with keys being door number (numbering goes for top left corner, left to right and then down)
# CLUE: string

DEFAULT_INFO = {'ROOMPASS': 0,
                'DOORPASS': {},
                'CLUE': '',
                }

ROOM_INFO = {1: {'ROOMPASS': 0,
                 'DOORPASS': {},
                 'CLUE': 'Il vous manque une case',
                 },
             2: {'ROOMPASS': 17,
                 'DOORPASS': {1: 1},
                 'CLUE': 'Vous devriez utiliser vosdoigts',
                 },
             3: {'ROOMPASS': 10,
                 'DOORPASS': {},
                 'CLUE': 'Un peu de perspective',
                 },
             4: {'ROOMPASS': 6,
                 'DOORPASS': {},
                 'CLUE': 'Il suffirait de peu pour etre juste',
                 },
             5: {'ROOMPASS': 7,
                 'DOORPASS': {2: 17},
                 'CLUE': 'Transcendance',
                 },
             6: {'ROOMPASS': 0,
                 'DOORPASS': {},
                 'CLUE': 'Il vous manque une case',
                 },
             7: {'ROOMPASS': 11,
                 'DOORPASS': {},
                 'CLUE': 'Soyons clair et mettons  les points sur les i',
                 },
             8: {'ROOMPASS': 13,
                 'DOORPASS': {1: 7},
                 'CLUE': 'Le temps est ecoule',
                 },
             9: {'ROOMPASS': 5,
                 'DOORPASS': {},
                 'CLUE': 'Content Pas Content',
                 },
             10: {'ROOMPASS': 0,
                  'DOORPASS': {},
                  'CLUE': 'Vous ne devriez pas etre ici',
                  },
             11: {'ROOMPASS': 8,
                  'DOORPASS': {},
                  'CLUE': 'Pauvre Blinky',
                  },
             12: {'ROOMPASS': 3,
                  'DOORPASS': {},
                  'CLUE': 'Par ici la sortie',
                  },
             13: {'ROOMPASS': 23,
                  'DOORPASS': {},
                  'CLUE': 'Kori o tokasu',
                  },
             14: {'ROOMPASS': 15,
                  'DOORPASS': {},
                  'CLUE': 'Retour a la racine',
                  },
             15: {'ROOMPASS': 0,
                  'DOORPASS': {},
                  'CLUE': 'A l\'identique.           Mais surtout a gauche',
                  },
             16: {'ROOMPASS': 9,
                  'DOORPASS': {},
                  'CLUE': 'Dans la continuite',
                  },
             17: {'ROOMPASS': 0,
                  'DOORPASS': {},
                  'CLUE': 'Un miroir vers l\'infini',
                  },
             18: {'ROOMPASS': 2,
                  'DOORPASS': {},
                  'CLUE': 'Remplissez moi jusqu\'au  bord',
                  },
             19: {'ROOMPASS': 20,
                  'DOORPASS': {},
                  'CLUE': 'America !',
                  },
             20: {'ROOMPASS': 16,
                  'DOORPASS': {2: 23},
                  'CLUE': 'Transcendance',
                  },
             21: {'ROOMPASS': 12,
                  'DOORPASS': {},
                  'CLUE': 'Franchir la ligne',
                  },

             22: {'ROOMPASS': 0,  # TODO
                  'DOORPASS': {},
                  'CLUE': 'TODO',
                  },
             23: {'ROOMPASS': 4,  # TODO
                  'DOORPASS': {},
                  'CLUE': 'C\'est bon les beignets. Mais je prefererais un donut',
                  },

             24: {'ROOMPASS': 19,
                  'DOORPASS': {},
                  'CLUE': 'Sequence a completer',
                  },
             25: {'ROOMPASS': 14,
                  'DOORPASS': {},
                  'CLUE': 'Complementaire',
                  },
             26: {'ROOMPASS': 0,
                  'DOORPASS': {},
                  'CLUE': 'This is the end',
                  },

             27: {'ROOMPASS': 21,  # TODO
                  'DOORPASS': {},
                  'CLUE': 'TODO',
                  },

             28: {'ROOMPASS': 18,
                  'DOORPASS': {},
                  'CLUE': 'XOR a droite',
                  },
             29: {'ROOMPASS': 1,
                  'DOORPASS': {},
                  'CLUE': 'Miroir Miroir',
                  },
             30: {'ROOMPASS': 22,
                  'DOORPASS': {},
                  'CLUE': '4 rotations a droite',
                  },

             31: {'ROOMPASS': 24,  # TODO
                  'DOORPASS': {},
                  'CLUE': 'TODO',
                  },

             32: {'ROOMPASS': 0,
                  'DOORPASS': {2: 5},
                  'CLUE': 'Il vous manque une case',
                  },

             33: {'ROOMPASS': 25,  # TODO
                  'DOORPASS': {},
                  'CLUE': 'TODO',
                  },
             34: {'ROOMPASS': 0,  # TODO
                  'DOORPASS': {},
                  'CLUE': 'TODO',
                  },
             35: {'ROOMPASS': 27,
                  'DOORPASS': {},
                  'CLUE': 'Completez l\'escargot',
                  },

             36: {'ROOMPASS': 26,
                  'DOORPASS': {},
                  'CLUE': 'Gliders... Game of Life',
                  },

             }


if __name__ == "__main__":
    nopass = 0
    allpass = [1] * 27

    for i in range(1, 37):
        r = ROOM_INFO[i]
        if r['ROOMPASS'] == 0:
            nopass += 1
        else:
            allpass[r['ROOMPASS'] - 1] -= 1

    # Check the allocation of password when solving room - nopass should be 36 - 27 = 9
    # allpass should be a vector of zeros
    print(nopass)
    print(allpass)
