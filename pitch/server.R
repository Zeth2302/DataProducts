library(shiny)
library(ggplot2)
library(neuralnet)
library(NeuralNetTools)
library(RColorBrewer)

source("NeuralNetPitch.R")

shinyServer(function(input, output) {
    
    trainData <- reactive({
        validate(need(input$noise >= 0, "Noise must be >= 0"))
        buildData(input$trainSize, input$seed, input$noise)
    })
    testData <- reactive({
        validate(need(input$noise >= 0, "Noise must be >= 0"))
        buildData(input$testSize, input$seed * 2, input$noise)
    })
    netFit <- reactive({
        train <- trainData()
        hiddenLayers <- c(input$numNeuronsL1)
        if (input$numNeuronsL2 > 0) hiddenLayers <- c(hiddenLayers, input$numNeuronsL2)
        trainNeuralNet(train, hiddenLayers, input$seed * 3)
    })
    background <- reactive({
        backgroundGrid <- buildBackgroundGrid()
        preds <- neuralnet::compute(netFit(), backgroundGrid)
        cbind(backgroundGrid, pred = preds$net.result)
    })
    

    output$trainPlot <- renderPlot({
        plotBackgroundAndPoints(background(), trainData())
    })
    output$trainAccuracy <- renderText({
        round(measureAccuracy(netFit(), trainData()), 4)
    })
    output$testPlot <- renderPlot({
        plotBackgroundAndPoints(background(), testData())
    })
    output$testAccuracy <- renderText({
        round(measureAccuracy(netFit(), testData()), 4)
    })
    output$netStructure <- renderPlot({
        plotnet(netFit())
    })
  
})
