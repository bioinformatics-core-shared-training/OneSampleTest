library(shiny)
library(DT)


shinyUI(navbarPage("Explore the one sample t-test",id="nav",
                   
                   tabPanel("About",
                            sidebarLayout(
                              sidebarPanel(img(src="cruk-cambridge-institute.jpg",width=350,height=77), br(),a("cruk.cam.ac.uk",href="http://www.cruk.cam.ac.uk",target="_blank")),
                              mainPanel(helpText("This app was developed by the Bioinformatics Core of Cancer Research Uk Cambridge Institute to accompany a training course. On the course webpage you will find lecture notes from the course and practical exercises that use this app"),
                                        a("Introduction to Statistical Analysis",href="http://bioinformatics-core-shared-training.github.io/IntroductionToStats/",target="_blank"),
                                        br(),
                                        helpText(),
                                        br(),
                                        br(),
                                        br(),
                                        br(),
                                        a("View source Code for app", href="https://github.com/bioinformatics-core-shared-training/OneSampleTest.git",target="_blank")
                              )
                            )
                            
                   ),
                   tabPanel("Data Input",
                            sidebarLayout(
                              sidebarPanel(h2("Data Import Parameters"),
                                           fileInput('file1', 'Choose CSV File',
                                                     accept=c('text/csv', 'text/comma-separated-values,text/plain', '.csv')),
                                           textInput("dataCol", "Column containing data to test",value=2),
                                           h2("Hypothesized Mean"),
                                           helpText("You need to specify the Hypothesized (or population) mean that you intend to use in the statistical test"),
                                           textInput("mu","Hypothesized mean",value = 0),
                                           helpText("You can choose to transform the data prior to statistical testing"),
                                           radioButtons("transform","Transformation",c("None"="none","Log10"="log.10","Log2"="log.2","Natural Log"="log"),"none")
                                           
                                           
                              )
                              ,
                              mainPanel(DT::dataTableOutput("mytable")
                              )
                              
                            )
                            
                   ),
                   
                   tabPanel("Data Distribution",
                            sidebarLayout(
                              sidebarPanel(h2("Display Parameters"),
                                           checkboxInput("violin", "Overlay density on boxplot?", value=FALSE),
                                           helpText("You can use the algorithm in R to guess how many bins to use in the histogram"),
                                           checkboxInput("default.bins",label="Guess optimal bin size?",value=TRUE),
                                           helpText("Otherwise, you can choose your own number of bins"),
                                           sliderInput("bins",
                                                       "Number of bins:",
                                                       min = 1,
                                                       max = 50,
                                                       value = 30),


                                           checkboxInput("showMu","Show Hypothesized mean?", T),
      #                                     checkboxInput("showCI", "Show Confidence Interval",value = FALSE),
                                           helpText("The current value of the true mean is defined on the Data Input tab")

                              ),
                              
                              mainPanel(helpText("The boxplot and histogram of the data are shown below"),
                                        plotOutput("boxplot"),
                                        helpText("Numerical summary of the data..."),
                                        verbatimTextOutput("summary"),
                                        helpText("The red solid line on the histogram shows a normal distribtion. You should assess whether your data are approximately normally-distributed before proceeding with a t-test"),
                                        plotOutput("histogram")
                              )
                              
                            )
                            
                            
                            
                   ),
                   tabPanel("Statistical Analysis",
                            sidebarLayout(
                              sidebarPanel(checkboxInput("do.parametric",label = "Use Parametric Test?",value = TRUE),
                                           radioButtons("alternative", "Alternative", c("Two-sided"="two.sided", "Greater" = "greater", "Lower"="less"),"two.sided"),
                                           helpText("Don't forget to check that the value of the Hypothesized mean is correct. You change this on the Data Input tab")
                                           
                              ),
                              mainPanel(h4("One sample test"),
                                        verbatimTextOutput("ttest"),plotOutput("zdist")
                              )
                            )
                   ),
                   tabPanel("Reproducible Analysis",
                            sidebarLayout(
                              sidebarPanel(    h2("Report Parameters"),
                                               #submitButton ('Generate R Code', icon('toggle-right'))
                                               textInput("outfile", "What to call the output R script",value="analysis"),
                                               textInput("name", "Your Name",value="Anon."),
                                               textInput("title", "What title to use in the report",value="My R Analysis")),
                              mainPanel(
                                h4("R Script"),
                                
                                helpText("You will be able to re-run this analysis in R by downloading the R code below"),
                                helpText("We recommend RStudio to run the R code and compile a pdf or HTML report that will show the results of your analysis along with the code used"),
                                img(src="https://www.rstudio.com/wp-content/uploads/2014/03/blue-125.png"), br(),a("RStudio",href="https://www.rstudio.com/",target="_blank"),br(),
                                strong("The input file that you are analysing must be in your R working directory in order for the script to run"),
                                helpText("In order to compile the report in RStudio, you will need to install the tidyverse package"),
                                code("install.packages('tidyverse'))"),
                                p(),
                                downloadLink('downloadScript', 'Download R Script'),
                                p(),
                                downloadLink('downloadMarkdown', 'Download R Markdown file')
                                
                              )
                              
                            )
                   )
                   
)

)

