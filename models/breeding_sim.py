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

class WamoSimulator:

    def __init__(self, mu, sigma, n):
        self.mu = mu
        self.sigma = sigma
        self.n = n
        # self.population = 

    def display(w, population):
        print("\n -- displaying traits of Wam0 #", w)
        for i,trait in enumerate(TRAITS):
            print(f"{population[w][i]} | {trait}")
            

    def breed(w1, w2, population):
        new_traits = []
        for i,trait in enumerate(TRAITS):
            mu = (population[w1][i] + population[w2][i]) / 2
            sigma = abs(population[w1][i] - population[w2][i]) / 2
            score = np.random.normal(mu, sigma, 1)
            new_traits.append(score)
        return new_traits


    def create_gen(mu, sigma, n):
        """
        A generation of wam0s with normally distributed traits
        """
        population = [np.random.normal(mu, sigma, len(TRAITS)) for wamo in range(n)]
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
