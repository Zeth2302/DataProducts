library(shiny)

shinyUI(fluidPage(
  
  titlePanel("Neural Net Explorer"),
  
  sidebarLayout(
    sidebarPanel(
        h2("Instructions"),
        p("Interact with the below controls to modify the training data, test data, and structure of a neural 
          network's training and evaluation. Please be patient, as training the network might take a few minutes. 
          The network is not guaranteed to converge. Should you see errors, tweak some attributes and try again."),
        p("This visualization was inspired by ", a("A Neural Network Playground.", href = "http://playground.tensorflow.org/"),
          "Give them a visit for a more complete and robust experience."),
        h2("Controls"),
        numericInput("seed", label = "Data generating random seed", value = 1),
        numericInput("noise", label = "Noise added to the data", min = 0, value = 0),
        sliderInput("trainSize", "Number of training samples:", min = 100, max = 300, value = 150),
        sliderInput("testSize", "Number of testing samples:", min = 100, max = 300, value = 150),
        sliderInput("numNeuronsL1", "Number of neurons in hidden layer 1:", min = 1, max = 5, value = 2),
        sliderInput("numNeuronsL2", "Number of neurons in hidden layer 2:", min = 0, max = 5, value = 0),
        submitButton("Submit")
    ),
    
    mainPanel(
        h2("Training Data"),
        plotOutput("trainPlot"),
        p("Train accuracy: ", textOutput("trainAccuracy", inline = TRUE)),
        h2("Testing Data"),
        plotOutput("testPlot"),
        p("Test accuracy: ", textOutput("testAccuracy", inline = TRUE)),
        h2("Network Structure"),
        p("The structure of the network is plotted using the NeuralNetTools package. 
          The construction of the visualization can be read about at ", 
          a("R is my friend: Visualizing neural networks from the nnet package.", 
            href = "https://beckmw.wordpress.com/2013/03/04/visualizing-neural-networks-from-the-nnet-package/"),
          "Black lines correspond to positive weights, gray lines to negative weights, and line size to the magnitude of the weights."),
        plotOutput("netStructure")
    )
  )
))
