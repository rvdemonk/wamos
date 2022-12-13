
#calculate gas cost of tx in usd
def calc_tx_cost(gaspriceGwei, maticUsdPrice, gasUsed):
    gaspriceEth = gaspriceGwei / 10**9
    tx_cost = gaspriceEth * maticUsdPrice * gasUsed
    print(f"gas cost: {tx_cost} USD")
    return tx_cost

def main():
    calc_tx_cost(50, 1, 100_000)

if __name__ == "__main__":
    main()
