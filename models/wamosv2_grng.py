import matplotlib.pyplot as plt
import numpy as np
import os


# read data
# construct data bins
# calculate mu and sigma
# plot

def get_data():
    files = os.listdir("data/")
    datafile = open(rf"data/{files[-1]}")
    metadata = datafile.readline()
    datastring = datafile.readline()
    datafile.close()

    mu = metadata.split(", ")[1].split("=")[1]
    sigma = metadata.split(", ")[2].split("=")[1]
    data = datastring.split(", ")
    del data[-1] # empty string
    return { 'mu':mu, 'sigma':sigma, 'data':data } 


def count_data(data):
    counted_data = { str(i):0 for i in range(-100, 400)}
    for x in data:
        counted_data[x] += 1
    return counted_data


def main():
    data = get_data()
    counted_data = count_data(data['data'])
    plt.bar(counted_data.keys(), counted_data.values())
    plt.xticks(np.arange(-100,400,50))
    plt.show()


if __name__ == "__main__":
    main()