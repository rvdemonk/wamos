
#calculate gas cost of tx in usd
def calc_tx_cost(gaspriceGwei, maticUsdPrice, gasUsed):
    gaspriceEth = gaspriceGwei / 10**9
    tx_cost = gaspriceEth * maticUsdPrice * gasUsed
    print(tx_cost)
    return tx_cost

def main():
    calc_tx_cost(100, 1, 500000)

main()