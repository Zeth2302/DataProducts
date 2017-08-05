# This file contains functions shared between the Shiny app and the presentation.

# Fabricates some circular classification data.
buildData <- function(amount, randomSeed, noise) {
    set.seed(randomSeed)
    clampVecVals <- function(vec, minVal, maxVal) { 
        sapply(vec, function(v) { max(min(v, maxVal), minVal) })
    }
    raw <- data.frame(
        x = clampVecVals(rnorm(amount, 5, 2), minVal = 0.5, maxVal = 9.5),
        y = clampVecVals(rnorm(amount, 5, 2), minVal = 0.5, maxVal = 9.5)
    )
    rolls <- runif(amount)
    probs <- circularProb(raw$x, raw$y, noise)
    raw$label <- rolls < probs
    raw
}

# Outputs probabilities converging on 1 as (x, y) approaches (5, 5).
circularProb <- function(x, y, noise) {
    scaling = 10 / (noise + 1)
    plogis(-scaling * ( (x - 5)^2 + (y - 5)^2 - 2 ))
}

# Trains a neuralnet for classification output of class probabilities.
# Retries learning 5 times before giving up.
trainNeuralNet <- function(trainData, hiddenLayers, randomSeed) {
    set.seed(randomSeed)
    neuralnet(label ~ x + y, data = trainData, hidden = hiddenLayers, rep = 5, 
              err.fct = "ce", linear.output = FALSE, likelihood = TRUE)
}

# Builds a uniform grid of points across the square from (0, 0) to (10, 10).
buildBackgroundGrid <- function() {
    backgroundGrid <- cbind(
        as.vector(sapply(seq(0, 10, by = 0.05), function(x) { rep(x, 202)} )),
        seq(0, 10, by = 0.05)
    )
    backgroundGrid <- as.data.frame(backgroundGrid)
    colnames(backgroundGrid) <- c("x", "y")
    backgroundGrid
}


# Plots just the background component of the neural net visualization.
plotBackgroundProbs <- function(backgroundProbs) {
    ggplot() + 
        geom_raster(aes(x, y, fill = pred), data = backgroundProbs, alpha = 0.75) +
        scale_fill_gradientn(colors = brewer.pal(4, "RdYlBu")) +
        theme_light()
}

# Add training or test points on top of the in progress ggplot from plotBackgroundProbs.
addPointsToPlot <- function(ggInProgress, points) {
    ggInProgress +
        geom_point(aes(x, y), data = points, size = 3, color = I("white")) +
        geom_point(aes(x, y, color = label), data = points, size = 2.25) +
        scale_color_manual(values = c("#a02000", "#0040bb"))
}

# Plots both the background decision terrain and sample points.
plotBackgroundAndPoints <- function(backgroundProbs, points) {
    backgroundPlot <- plotBackgroundProbs(backgroundProbs)
    addPointsToPlot(backgroundPlot, points)
}


# Returns an accuracy score for how well the fit neuralnet performs
# on the parameter labeledPoints. The labeledPoints param must have
# columns "x", "y", and "label".
measureAccuracy <- function(netFit, labeledPoints) {
    preds <- neuralnet::compute(netFit, labeledPoints[, c("x", "y")])$net.result
    matches <- labeledPoints$label == (preds >= 0.5)
    sum(matches) / length(preds)
}