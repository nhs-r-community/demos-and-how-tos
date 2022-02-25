---
title: Using optim() to produce the best parameter for a 'Synthetic Germany'
author: "Jon Minton"
---

# Introduction

This example shows how the `optim()` function can be used to help select a parameter which minimises a loss function. `optim()` is commonly used under the bonnet to identify maximum likelihood estimates for statistical models. However in this case it is used for something else: to work out the best 'mix' of East and West German life expectancy data to use to make a 'Synthetic Germany' which covers years in which Germany was not unified and so a single population estimate could not be produced. It produces candidate 'synthetic Germanies' by combining a weighted average of life expectancies for East and West Germany. The parameter that can be varied is the proportion of East Germany in the mix (and so by implication the proportion West Germany); and the loss function to minimise is the Root Mean Squared Error (RMSE) between life expectancy estimates for 'synthetic Germany' and *real* Germany over the period 1990 to 2010. 

Two scripts are included: one containing functions, and another containing heavily commented code.

The heavily commented code works up to the use of `optim()` by first showing how a simple grid-search approach can be used. The grid search approach simply calculates RMSE for each full % share of East Germany possible, from 0% to 100%. 

The heavily commented code makes extensive use of functions and functional programming conventions using the `tidyverse`, and so depends on the `tidyverse` package and paradigms to work, and make sense of, respectively. 

The main script also draws directly from a data file from [another project I have been working on](https://github.com/jonminton/change_in_ex/), which extracts lifetables for all nations within the [Human Mortality Database](https://www.mortality.org) using the `HMDHFDplus` package. 

