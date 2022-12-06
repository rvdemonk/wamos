from scipy.stats import norm
import matplotlib.pyplot as plt
import numpy as np
import time

# WAMO CONSTANTS
TRAITS = [
    "health",
    "stamina",
    "magic",
    "meeleeAttack",
    "meeleeDefence",
    "magicAttack",
    "magickDefence",
    "manaRegen",
    "stamRegen",
]
SP_TRAITS = ["fecundity", "deity"]

# POPULATION SETTINGS
MU = 50
SIGMA = 16
N = 1000


def create_gen(mu, sigma, n):
    """
    A generation of wam0s with normally distributed traits
    """
    pop_traits = [np.random.normal(mu, sigma, len(TRAITS)) for wamo in range(n)]
    pop_sp_traits = [np.random.normal(mu, sigma, len(SP_TRAITS)) for wamo in range(n)]
    return population


def breed_wamos(w1, w2):
    """
    Seed and parents? Child trait score = f(seed, parents seed)
    """
    pass


def main():
    start = time.time()
    population = create_gen(MU, SIGMA, N)
    print(f"\n{len(population)} wamos simulated\n")

    for i, trait in enumerate(TRAITS):
        print(f"{round(population[0][i])} | {trait} ")

    end = time.time()
    print("\n ---- finished in:", round(end - start, 2), "seconds")


if __name__ == "__main__":
    main()
