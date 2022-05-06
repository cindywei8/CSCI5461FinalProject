from turtle import color
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sn
import scipy.io
from sklearn.metrics.pairwise import euclidean_distances
from mpl_toolkits.axes_grid1 import make_axes_locatable


def main():
    S_matrices = ["data1_mECS_SMat.txt", "data2_Kolod_SMat.txt", 
                "data3_Pollen_SMat.txt", "data4_Usoskin_SMat.txt"]
    true_labels = ["data1_mECS_TrueLabels.txt", "data2_Kolod_TrueLabels.txt", 
                    "data3_Pollen_TrueLabels.txt", "data4_Usoskin_TrueLabels.txt"]

    dataset = ['Test_1_mECS.mat', 'Test_2_Kolod.mat', 'Test_3_Pollen.mat', 'Test_4_Usoskin.mat']
    dataset_names = ["Buettner", "Kolodziejczyk", "Pollen", "Usoskin"]
    vmax_ls = [0.1, 0.01, 0.1, 0.01]

    fig, axs = plt.subplots(3, 4, figsize=(15,8))
    r = 0

    for i in range(4):
        S = np.loadtxt(S_matrices[i], delimiter=',')
        mat = scipy.io.loadmat('data/'+dataset[i])
        true_labs = np.loadtxt(true_labels[i])
        # uniq_labs, indices = np.unique(true_labels, return_index=True)
        # ticks = []
        

        eucld = euclidean_distances(mat['in_X'])
        pccoeff = np.corrcoef(mat['in_X'])

        idx = np.argsort(true_labs)
        _, indices = np.unique(true_labs[idx], return_index=True)
        S_ordered = S[idx][:,idx]
        labs_ordered = true_labs[idx]
        eucld_ordered = eucld[idx][:,idx]
        pccoeff_ordered = pccoeff[idx][:,idx]

        # for j in range(len(labs_ordered)):
        #     if j in indices:
        #         ticks.append(labs_ordered[j])
        #     else:
        #         ticks.append("")
        # print(len(ticks))

        max_s = np.max(S_ordered)
        min_s = np.min(S_ordered)
        # print(max_s, min_s)
        sn.heatmap(S_ordered, vmax=vmax_ls[i], vmin=0, cmap='Oranges', ax=axs[0,i],xticklabels=False, yticklabels=False)
        axs[0,i].set_title(dataset_names[i])
        sn.heatmap(eucld_ordered, cmap='Oranges', ax=axs[1,i], xticklabels=False, yticklabels=False)
        sn.heatmap(pccoeff_ordered, cmap='Oranges', ax=axs[2,i], xticklabels=False, yticklabels=False)
        
        for n in range(1,len(indices)):
            axs[0,i].axvline(x=indices[n],linewidth=0.7, color='b', alpha=0.7)
            axs[1,i].axvline(x=indices[n],linewidth=0.7, color='b', alpha=0.7)
            axs[2,i].axvline(x=indices[n],linewidth=0.7, color='b', alpha=0.7)
            axs[0,i].axhline(y=indices[n],linewidth=0.7, color='b', alpha=0.7)
            axs[1,i].axhline(y=indices[n],linewidth=0.7, color='b', alpha=0.7)
            axs[2,i].axhline(y=indices[n],linewidth=0.7, color='b', alpha=0.7)
        
    axs[0,0].set_ylabel("SIMLR")
    axs[1,0].set_ylabel("Euclidean")
    axs[2,0].set_ylabel("Pearson")
    plt.show()

if __name__ == "__main__":
    main()
