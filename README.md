# Zero-Shot Learning to Index on Semantic Trees for Scalable Image Retrieval
This code is mainly for understanding our submitted TIP paper [Zero-Shot Learning to Index on Semantic Trees for Scalable Image Retrieval](https://github.com/kanshichao/LTI-ST). We will continue to maintain this project to further improve our work. Our results in the paper are produced based on the caffe framework, because more and more researchers are focusing on Pytorch to do their studies, and in order to facilitate more researchers to understand our idea, this project will based on the Pytorch framework to show our ideas. Note: the results produced with this code may be slightly higher than the results produced by caffe that showed in our paper, but this does not affect the effectiveness and novelty of our idea.

<img src="img/LTI-ST-framework.png" width="65%" height="65%"> 
<img src="img/semantic-tree-decode.png" width="65%" height="65%"> 

### Abstract

In this study, we develop a new approach, called zero-shot learning to index on semantic trees (LTI-ST), for efficient image indexing and scalable image retrieval. Our method learns to model the inherent correlation structure between visual representations using a binary semantic tree from training images which can be effectively transferred to new test images. Based on predicted correlation structure, we construct an efficient indexing scheme for the whole test image set. Unlike existing image index methods, our proposed LTI-ST method has the following two new characteristics. First, it  does not need to analyze the test images in the query database to construct the index structure. Instead, it is directly predicted by a network learned from the training set. This zero-shot capability is critical for flexible, distributed, and scalable implementation and deployment of the image indexing and retrieval services at large scales. Second, unlike the existing distance-based index methods, our index structure is learned using the LTI-ST deep neural network with binary encoding and decoding on a hierarchical semantic tree. Our extensive experimental results on benchmark datasets and ablation studies demonstrate that the proposed LTI-ST method outperforms existing index methods by a large margin while providing the above new capabilities which are highly desirable in practice. 

### Prepare the data and the pretrained model

For the quickly and easily understand our method, we first take the small data set **CUB** as an example of learning feature embedding. Experiments on the **SOP** and **ImageNet** in our paper can be conducted by following our instructions.

The following script will prepare the [CUB](http://www.vision.caltech.edu.s3-us-west-2.amazonaws.com/visipedia-data/CUB-200-2011/CUB_200_2011.tgz) dataset for training by downloading to the ./resource/datasets/ folder; which will then build the data list (train.txt test.txt):

```bash
./feature-embedding-scripts/prepare_cub.sh
```

The [SOP](https://arxiv.org/pdf/1511.06452.pdf) dataset can be downloaded from ftp://cs.stanford.edu/cs/cvgl/Stanford_Online_Products.zip, and the [ImageNet](https://arxiv.org/pdf/1409.0575.pdf) dataset can be downloaded from [this link](http://image-net.org/download).
 After preparing the training list and test list, replacing the file path in the files of configs, feature embedding results can be obtained by training the model following our examples and paprameter settings in our paper.

You can choose one of the **GoogleNet**, **Bn-Inception** and **ResNet-50** encoders by downloading the imagenet pretrained model of
[googlenet](https://download.pytorch.org/models/googlenet-1378be20.pth), [bninception](http://data.lip6.fr/cadene/pretrainedmodels/bn_inception-52deb4733.pth) and [resnet50](https://download.pytorch.org/models/resnet50-19c8e357.pth), and put them in the folder:  ~/.cache/torch/checkpoints/.


### Installation

```bash
sudo pip3 install -r requirements.txt
sudo python3 setup.py develop build
```
###  Train and Test the feature embedding network on CUB-200-2011 with MS-Loss based on the BN-Inception backbone

```bash
./feature-embedding-scripts/run_cub_bninception.sh
```
Trained models will be saved in the ./output-bninception-cub/ folder if using the default config.

###  Train and Test the feature embedding network on CUB-200-2011 with MS-Loss based on the ResNet50 backbone

```bash
./feature-embedding-scripts/run_cub_resnet50.sh
```
Trained models will be saved in the ./output-resnet50-cub/ folder if using the default config.

###  Train and Test the feature embedding network on CUB-200-2011 with MS-Loss based on the GoogleNet backbone

```bash
./feature-embedding-scripts/run_cub_googlenet.sh
```
Trained models will be saved in the ./output-googlenet-cub/ folder if using the default config.

More backbones (e.g., **ResNet-18**, **ResNet-34**, **ResNet-101**, **ResNet-152**) can be experimented by changing the backbone name in the files of configs, and more embedding losses (e.g., ranked list loss, soft triplet loss, angular loss etc.) can be experimented by changing the loss name in the defaults file of ltist_benchmark/config/.

### Semantic tree encoding

(1) Building tree by running the following script
```bash
matlab -nodesktop -nosplash semantic-tree-encoding/matlab-code/IndexTree_main.m
```

(2) Labeling schemes

a) hard and soft labeling

```bash
matlab -nodesktop -nosplash semantic-tree-encoding/matlab-code/hierarchical_relabeling_normalize.m
```

b) ranked labeling

```bash
matlab -nodesktop -nosplash semantic-tree-encoding/matlab-code/ranked_labeling_scheme.m
```

After generating semantic tree labels, they will be used to guide the index learning process.
PyTorch code will be added in other times

### Semantic tree decoding
PyTorch code will be added in other times

### End-to-end training examples
The end-to-end training will joint the feature embedding, semantic tree encoding, label prediction network, index prediction network, and semantic tree decoding in an end-to-end manner. PyTorch code will be added in other times

### Scalable Image Retrieval
Example code will be added in other times

### Citation

If you use this method or this code in your research, please cite as:

    @inproceedings{TIP-Shichao-2020,
    title={Zero-Shot Learning to Index on Semantic Trees for Scalable Image Retrieval},
    author={Shichao Kan, Yi Cen, Yigang Cen, Mladenovic Vladimir, Yang Li, and Zhihai He},
    booktitle={},
    pages={},
    year={2020}
    }

### Acknowledgments
This code is written based on the framework of [MS-Loss](https://github.com/MalongTech/research-ms-loss), we are really grateful to the authors of the MS paper to release their code for academic research / non-commercial use. We also thank the following helpful implementtaions on [histogram](https://github.com/valerystrizh/pytorch-histogram-loss), [proxynca](https://github.com/dichotomies/proxy-nca), [n-pair and angular](https://github.com/leeesangwon/PyTorch-Image-Retrieval), [siamese-triplet](https://github.com/adambielski/siamese-triplet), [clustering](https://github.com/shaoniangu/ClusterLoss-Pytorch-ReID) for the implementation of more feature embedding losses.

### License
This code is released for academic research / non-commercial use only. If you wish to use for commercial purposes, please contact [Shichao Kan](https://kanshichao.github.io) by email kanshichao10281078@126.com.


