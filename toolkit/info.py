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
             5: {'ROOMPASS': 0,
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

             }
