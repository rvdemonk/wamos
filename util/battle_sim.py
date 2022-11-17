from random import randint


TRAITS = [
    'health',
    'meeleeAttack',
    'meeleeDefence',
    'magicAttack',
    'magicDefence',
    'rangeAttack',
    'rangeDefence',
    'stamina',
    'mana',
    'luck',
]

SPECIAL_TRAITS = [
    'fecundity',
    'powerRegen'
]

ABILITY = [
    'meeleeType',
    'magicType',
    'rangeType',
    'power',
    'accuracy',
    'range',
    'cost'
]

population = 100
wamos = [ {'wamoId': i,'traits': {},'abilities': []} for i in range(population)]


def generateTraits(wamos):
    for wamo in wamos:
        for trait in TRAITS:
            wamo['traits'][trait] = randint(0, 100)
        wamo['traits']['fecundity'] = randint(0, 12)
        wamo['traits']['powerRegen'] = randint(0, 25)
    return

def generateAbilities(wamos):
    for wamo in wamos:
        for i in range(4):
            ability = {}
            a_type = randint(0,10)
            if a_type < 4:
                ability['meeleeType'] = 1
                ability['magicType'] = 0
                ability['rangeType'] = 0
            elif a_type < 7:
                ability['meeleeType'] = 0
                ability['magicType'] = 1
                ability['rangeType'] = 0
            else:
                ability['meeleeType'] = 0
                ability['magicType'] = 0
                ability['rangeType'] = 1

            for stat in ABILITY[3:6]:
                ability[stat] = randint(0,100)

            ability['cost'] = randint(0,30)
            wamo['abilities'].append(ability)
    return

def print_abilities(i):
    for j,ability in enumerate(wamos[i]['abilities']):
        print(f"\nABILITY {i}")
        for stat, value in wamos[i]['abilities'][j].items():
            print(f"{stat}  {value}")

def simulate_attack():
    pass



def main():
    generateTraits(wamos)
    generateAbilities(wamos)
    print_abilities(0)

if __name__ == "__main__":
    main()
