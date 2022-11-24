---
id: tz8wfy0bidyoi7cew6pxfi4
title: Outline
desc: ''
updated: 1662472408233
created: 1662432714909
---

## Abstract

## Introduction
- Parameter space of kinetic models is too large for complete grid search
- Many different global optimization schemes are used, but some don't take the global parameter space into account
- Machine learning models are use each point in parameter space to estimate a parameter space function, thereby including all points for parameter update.
- Generative models can use the power of function approximation and ability to generative output to update kinetic model parameters

## Results/Discussion

### Part 1 - Generating new Kinetic Parameters with Generative Models

![](./assets/images/parameter-initialization-workflow-cvae.png){ width=80% }

Figure 4.4. Parameter initialization workflow and cVAE parameter initialization model. A) Workflow of parameter estimation originally followed in Chapter 2 for training the S. cerevisiae kinetic model, along with the workflow of cVAE training from the same data. B) cVAE Model Architecture or computational graph. cVAE is composed of an encoder layer (parent to black nodes), and a decoder layer (child of black nodes). Shown is the most basic cVAE architecture evaluated with only 1 encoder layer and 1 decoder layer. Black nodes represent the latent space of the network. Network modules include General matrix multiplier (Gemm), rectified linear unit (Relu), Batch normalization and (BatchNormilization). The head node directed as input to both the encoder and the decoder represent the vector that conditions the VAE, in this case the output of the ODE objective function (fval).

![](./assets/images/parallel-lines-hyperparameter-optimization.png){ width=80% }

Figure 4.5. Parallel Lines Plots. A) Random search over the space of possible hyperparameters. Each line traces the path of an individual model configuration. In order, hyperparameters include: number of encoder layers (model.enc_num_layers), encoder hidden channels (model.enc_hidden_channels), encoder out channels (model.enc_out_channels), latent dimension (model.latent_dim), decoder number of layers (model.dec_num_layers), decoder hidden channels (model.dec_hidden_channels), learning rate (optiom.lr), weight decay (optim.weight_decay), batch size (train.batch_size), and training split (train.split). The final two columns are the validation loss (val/loss) and the training loss (train/loss). B) Shows the down-selected view of the best runs (yellow from A) and highlights the run with the best balance of both train and validation loss. The text box specifies the model configuration that was used to generate new parameters vectors for the ODE solver.

### Part 2 - Evaluation of Generative Models on the Kinetic Parameter Space

![](./assets/images/evaluation-curves-of-best-cvae.png){ width=80% }

Figure 4.6. Evaluation curves of the best cVAE. The model was trained for 300 epochs. A) Loss curves of training and validation. cVAE loss is computed as the sum of reconstruction loss using binary cross entropy and the Kullback-Leibler (KL) divergence B) Root mean squared error (RMSE) between input data and reconstructed data. Parameter values belong to [-6, 3] after log-normalization. C) Pearson correlation between input and the reconstructed output. D) Spearman correlation between input and the reconstructed output.


![](./assets/images/UMAP-and-validation-latent-space.png){ width=80% }

Figure 4.7. Uniform Manifold Approximation and Projection (UMAP) of validation latent space. Latent vectors are discretized into bins of 0.1 intervals. Clusters indicate that the cVAE latent space of parameters can separate low and high fvals, suggesting the model should be able to generate parameters that converge to local minimum.

### Part 3 - Generation and Testing of New Parameter Vectors from cVAE for Kinetic Model

![](./assets/images/generate-parameter-evaluation.png){ width=80% }

Figure 4.8. Generated parameter evaluation. A) Percentage of generated parameters that don’t produce an fval of infinity. Conditions are fval normalized between [0, 1]. Lower conditions result in a higher percentage of feasible ODE solutions. B) Box and whisker plots of 100 replicates generated at different conditions. [0, 1] represent the range of normalized fvals from the training data. [-0.25, 0) and (1.0, 1.25] represent low and high extrapolation conditions of nomalized fval respectively. As expected, lower condition produces lower fval solutions on average.


![](./assets/images/generated-parameter-distances-for-100-replicates.png){ width=80% }

Figure 4.9. Generated parameter distances for 100 replicates at condition=0. Euclidean distances are computed between generated parameters and both all training data (blue) and the fval 25th quantile of training data (orange) to show the cVAE is not memorizing parameters with low fval. This would manifest as a low distance distribution between condition=0 generated parameters and the 25th quantile training data. To show what this would look like, distances are computed between all 25th quantile training data vectors (green) which shows low data distribution.  We see that the two orange and blue distributions are nearly identical, showing that   cVAE samples parameter space far from existing observed low fval A) distances are plotted in a histogram and B) distances are plotted as probability density to clearly show similarity and dissimilarity in distributions.

Todo: (**2 weeks**)
- Test both and highlight one:
    - Show how generated vectors result in lower fvals than local start local gradient
    - Show generated vectors find more local minima than local gradient

### Part 4 - Other Generative Models (**4 weeks**)
- A) Transformer cVAE
    - Status: Still implementing
- B) CCGAN
    - Status: Debugging

### Part 5 - Benchmarking Against other Methods
- Initialization Methods (**2 weeks**)
    - Status: Code refactored to allow for plugging in new initialization methods
    - Hypercube
    - Random
    - Multi-jittered

- Global Optimization Methods (**4 weeks**)
    - Bayesian Optimization
        - Status: Implemented
    - Monte Carlo Markov Chain (MCMC)
        - Status: Not yet implemented
    - Genetic Algorithm
        - Status: Not yet implemented

### Part 6 - BioModels Benchmarking (**4 weeks**)
- Goal: Find trends between Biomodels and parameter estimation schemes
    - Standard for Nature Machine Intelligence papers
- Todo:
    - Automated download and processing of models
    - Best benchmarks vs. best generative models
        - Learn correlation between types of Biomodels and generative model (best parameter update scheme)
    - Package
        - Plug in your Biomodel, create a generative model for parameter update, and global optimization

## Conclusion

## Methods

## Writing
- Aiming for 10/14/22 (**5 weeks**)
