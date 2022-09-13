--- 
title: "Using uiOutput to change selection"
author: "Jon Minton"
date: "8 September 2022"
---

# Introduction

This code example shows how uiOutput can be used to dynamically change one selectInput given the choice of the other selectInput. 

The example uses `uiOutput`, which has an appreciable latency when updating. 
For this particular usecase it may therefore be better to use a different approach instead.
However, this can be considered a proof of principle, which is perhaps more useful when an input's type needs to be changed (as from `selectInput` to `sliderInput`) rather than selection within should be changed. 