# simulating the derivation of wamo traits from bit shifting random words
import matplotlib.pyplot as plt


SEEDS = [
    78541660797044910968829902406342334108369226379826116161446442989268089806461,
    92458281274488595289803937127152923398167637295201432141969818930235769911599,
    105409183525425523237923285454331214386340807945685310246717412709691342439136,
    72984518589826227531578991903372844090998219903258077796093728159832249402700,
]


def count_trait_scores(seed):
    bits = 8
    step_size = 8
    score_counts = {}
    for i in range(0, 256, step_size):
        bscore = bin(seed >> i)[-bits:]
        score = int(bscore, 2)
        if score in score_counts:
            score_counts[score] += 1
        else:
            score_counts[score] = 1
    return score_counts


def plot_scores(counts):
    plt.bar(counts.keys(), counts.values())
    plt.show()


def main():
    counts = {i: count_trait_scores(SEEDS[i]) for i in range(len(SEEDS))}
    plot_scores(counts[1])


if __name__ == "__main__":
    main()
