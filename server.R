library(shiny)
library(tidyverse)
library(knitr)
library(DT)

shinyServer(function(input, output){
  
  data <- reactive({inFile <- input$file1
  
    df <- data.frame(Month= month.name, Failure = c(2.9,2.99,2.48,1.48,2.71,4.17,3.74,3.04,1.23,2.72,3.23,3.4))
    if (is.null(inFile)) return(df)
 
	  as.data.frame(read_csv(inFile$datapath))
  })
  
  #  output$plot <- renderPlot({
  #    plot(data(), xlab="X", ylab="Y", ylim=c(-300,800))
  #    if(input$line) {
  #      abline(lm(Y ~ X, data=data()), col="dark blue")
  #    }
  #    if(input$means) {
  #      abline(v = mean(data()[,1]), lty="dotted")
  #      abline(h = mean(data()[,2]), lty="dotted")
  #    } 
  #    if(input$ant) {
  #      model = lm(Y ~ X, data=data())
  #      txt = paste("The equation of the line is:\nY = ",
  #                  round(coefficients(model)[1],0)," + ",
  #                  round(coefficients(model)[2],3),"X + error")
  
  #      boxed.labels(50,600,labels=txt,bg="white", cex=1.25)
  #    }    
  
  #  })
  #
  
  output$mytable= DT::renderDataTable({
    df <- data()
    datacol <- as.numeric(input$dataCol)
    
    if(!input$transform =="none"){
      
      df[,datacol] <- switch(input$transform,
                             log.2 = log2(df[,datacol]),
                             log.10 = log10(df[,datacol]),
                             log = log(df[,datacol])
      )
    }
    
    mu <- as.numeric(input$mu)
    
    if(!input$do.parametric){
      
      df$Sign <- "="
      df$Sign[df[,datacol] > mu] <- "+"
      df$Sign[df[,datacol] < mu] <- "-"
    }
    
    datatable(df, rownames = FALSE)
  }, server = FALSE
  )
  
  
  
  output$histogram<- renderPlot({
    
    df <- data()
    datacol <- as.numeric(input$dataCol)
    
    
    mu <- as.numeric(input$mu)
    
    if(!input$transform =="none"){
      
      df[,datacol] <- switch(input$transform,
                             log.2 = log2(df[,datacol]),
                             log.10 = log10(df[,datacol]),
                             log = log(df[,datacol])
      )
      
      mu <- switch(input$transform,
                   log.2 = log2(mu),
                   log.10 = log10(mu),
                   log = log(mu)
      )
    }
    
    
    
    
    if(input$showMu){ xlim <-c(min(mu, min(df[,datacol])), max(mu, max(df[,datacol])))
    } else xlim <- c(min(df[,datacol]), max(df[,datacol]))
    
    
    colnames(df)[datacol] <- "X"
    if(input$default.bins){
      brx <- pretty(range(df$X), 
                    n = nclass.Sturges(df$X),min.n = 1)
      
      p <- ggplot(df, aes(x=X)) + geom_histogram(breaks=brx,colour="black", fill=rgb(29,0,150,maxColorValue=255)) + ylab("") + xlim(xlim)
    }
    
    else {
      binwid <- (max(df$X)-min(df$X)) / input$bins
      print(binwid)
      p<- ggplot(df, aes(x=X)) + geom_histogram(binwidth=binwid,colour="black", fill=rgb(29,0,150,maxColorValue=255)) + ylab("") + xlim(xlim)
    }
    #  p <- p +  stat_function(fun=dnorm,col="red",args=list(mean=mean(df$X), sd=sd(df$X)))
    
    
    if(input$showMu) p <- p + geom_vline(xintercept = mu,lty=2,col="red")
    
    print(p)
    
  }
  )
  
  output$boxplot <- renderPlot({
    df <- data()
    datacol <- as.numeric(input$dataCol)
    
    mu <- as.numeric(input$mu)
    
    if(!input$transform =="none"){
      
      df[,datacol] <- switch(input$transform,
                             log.2 = log2(df[,datacol]),
                             log.10 = log10(df[,datacol]),
                             log = log(df[,datacol])
      )
      
      mu <- switch(input$transform,
                   log.2 = log2(mu),
                   log.10 = log10(mu),
                   log = log(mu)
      )
      if(is.infinite(mu)) mu <- 0
    }
    
    
    if(input$showMu){ xlim <-c(min(mu, min(df[,datacol])), max(mu, max(df[,datacol])))
    } else xlim <- c(min(df[,datacol]), max(df[,datacol]))
    
    colnames(df)[datacol] <- "X"
    df$tmp <- factor(rep("x", nrow(df)))
    
    if(!input$violin){
      p <- ggplot(df, aes(x=tmp,y=X)) + xlab("") + geom_boxplot(fill=rgb(236,0,140,maxColorValue = 255),alpha=0.75)
      p <- p + geom_hline(yintercept = mu,lty=2,col="red") + ylim(xlim) + geom_jitter(position = position_jitter(width = .05)) + coord_flip()
      
    } else{
      p <- ggplot(df, aes(x=tmp,y=X)) + xlab("") + geom_violin(fill=rgb(236,0,140,maxColorValue = 255),alpha=0.75) + geom_boxplot(fill="white",width=0.1)
      p <- p + geom_hline(yintercept = mu,lty=2,col="red") + ylim(xlim) + geom_jitter(position = position_jitter(width = .05)) + coord_flip()
      
    }
#    if(input$showCI) p <- p + stat_summary(fun.data="mean_cl_normal",colour="red",fun.args = list(mult=1.96),geom="errorbar")
    print(p)
    
  }
  
  )
  # output$boxplot_old<- reactivePlot(function(){
  #    
  #    df <- data()
  #    datacol <- as.numeric(input$dataCol)
  
  
  #    mu <- as.numeric(input$mu)
  
  #    if(!input$transform =="none"){
  
  #      df[,datacol] <- switch(input$transform,
  #                             log.2 = log2(df[,datacol]),
  #                             log.10 = log10(df[,datacol]),
  #                             log = log(df[,datacol])
  #      )
  
  #      mu <- switch(mu,
  #                   log.2 = log2(mu),
  #                   log.10 = log10(mu),
  #                   log = log(mu)
  #      )
  #      
  #    }
  
  
  #    if(input$showMu){ xlim <-c(min(mu, min(df[,datacol])), max(mu, max(df[,datacol])))
  #    } else xlim <- c(min(df[,datacol]), max(df[,datacol]))
  
  
  #    colnames(df)[datacol] <- "X"
  #    df$tmp <- factor(rep("x", nrow(df)))
  
  #    p<- ggplot(df, aes(x=tmp,y=X)) + xlab("") +       geom_boxplot()
  #    geom_hline(yintercept = mu,lty=2,col="red") + ylim(xlim) + geom_jitter(position = position_jitter(width = .05)) + coord_flip()
  #    p
  
  #    if(input$showMu) p <- p + geom_vline(xintercept = mu,lty=2,col="red")
  #    print(p)
  
  #  }
  #  )
  
  
  
  output$ttest <-renderPrint({
    df <- data()
    
    datacol <- as.numeric(input$dataCol)
    
    mu <- as.numeric(input$mu)
    
    if(!input$transform =="none"){
      
      df[,datacol] <- switch(input$transform,
                             log.2 = log2(df[,datacol]),
                             log.10 = log10(df[,datacol]),
                             log = log(df[,datacol])
      )
      
      mu <- switch(input$transform,,
                   log.2 = log2(mu),
                   log.10 = log10(mu),
                   log = log(mu)
      )
      if(is.infinite(mu)) mu <- 0
    }
    
    X <- df[,datacol]
    alternative = input$alternative
    
    if(input$do.parametric) t.test(X,mu=mu,alternative=alternative)
    
    else {
      print(wilcox.test(X,mu=mu,alternative=alternative))
#      cat("\nAlternative that does not assume a symmetrical distribution\n\n\tSign test\n\n")
#      df <- data.frame(X)
#      df$Sign <- "="
#      df$Sign[X > mu] <- "+"
#      df$Sign[X < mu] <- "-"
      
#      npos <- sum(X>mu)
#      nneg <- sum(X<mu)
#      x <- min(npos,nneg)
#      n <- sum(X != mu)
#      cat(paste("Number of +'s", npos, "\n"))
#      cat(paste("Number of -'s", nneg, "\n"))

#      cat(paste("Test statistic:", x,"\n"))
#      p <- pbinom(q = x, size = n, prob = 0.5)
#      p <- switch(input$alternative,
#                  two.sided = p,
#                  greater = p / 2,
#  								less = 1 - p / 2)
#      p <- round(p, digits = 3)
#      cat(paste("P-value using binomial distribution with", n, "trials and p=0.5:", p, "\n"))
    }
  })
  
  
  
  output$summary <- renderPrint({
    df <- data()
    datacol <- as.numeric(input$dataCol)
    
    if(!input$transform =="none"){
      
      df[,datacol] <- switch(input$transform,
                             log.2 = log2(df[,datacol]),
                             log.10 = log10(df[,datacol]),
                             log = log(df[,datacol])
      )
    }

    df %>%
      select(datacol) %>%
      summarise_all(funs(
        n(),
        mean(., na.rm = TRUE),
        sd(., na.rm = TRUE),
        IQR(., na.rm = TRUE),
        `0%` = quantile(., 0, na.rm = TRUE),
        `25%` = quantile(., 0.25, na.rm = TRUE),
        `50%` = quantile(., 0.5, na.rm = TRUE),
        `75%` = quantile(., 0.75, na.rm = TRUE),
        `100%` = quantile(., 1.0, na.rm = TRUE)
      )) %>%
      mutate(ci.lower = mean - 1.96 * sd / sqrt(n)) %>%
      mutate(ci.upper = mean + 1.96 * sd / sqrt(n)) %>%
      print(row.names = FALSE, digits = 4)
  })


  output$zdist <- renderPlot({
    
    mu <- as.numeric(input$mu)
    alternative = input$alternative
    mu <- as.numeric(input$mu)
    
    df <- data()
    datacol <- as.numeric(input$dataCol)
    
    if(!input$transform =="none"){
      
      df[,datacol] <- switch(input$transform,
                             log.2 = log2(df[,datacol]),
                             log.10 = log10(df[,datacol]),
                             log = log(df[,datacol])
      )
      
      mu <- switch(input$transform,
                   log.2 = log2(mu),
                   log.10 = log10(mu),
                   log = log(mu)
      )
      if(is.infinite(mu)) mu <- 0
    }
    
    
    degfree <- nrow(df)-1
    X <- df[,datacol]
    tstat <- t.test(X,mu=mu,alternative=alternative)$statistic
    
    
    alternative = input$alternative
    
    if(input$do.parametric){
      
      df <- data.frame(ts = rt(10000,df=degfree))
      
      
      #p<- ggplot(df, aes(x=ts)) + 
       # geom_histogram(aes(y=..density..),      # Histogram with density instead of count on y-axis
        #               binwidth=.5,
         #              colour="black", fill=rgb(236,0,140,maxColorValue=255)) + stat_function(fun=dnorm,col="red",args=list(mean=mean(df$ts), sd=sd(df$ts)))
      
      p <- ggplot(data.frame(x=c(-4,4)),aes(x)) + stat_function(fun=dt, args=list(df=degfree))
      
      xlim <- c(min(tstat-0.2,min(df$ts)), max(tstat+0.2, max(df$ts)))
      
      if(alternative == "two.sided") critvals <- c(qt(0.025, degfree),qt(0.975,degfree))
      else critvals <- c(qt(0.05, degfree),qt(0.95,degfree))
      
      rect1 <- data.frame(xmin = min(critvals[1],xlim),xmax = critvals[1], ymin=-Inf,ymax=Inf)
      rect2 <- data.frame(xmin = critvals[2],xmax = max(critvals[2],xlim), ymin=-Inf,ymax=Inf)
      
      p <- switch(alternative,
                  "two.sided" = p + geom_rect(data=rect1,aes(xmin=xmin, xmax=xmax, ymin=ymin, ymax=ymax),fill="yellow", alpha=0.5, inherit.aes = FALSE) + geom_rect(data=rect2,aes(xmin=xmin, xmax=xmax, ymin=ymin, ymax=ymax),fill="yellow", alpha=0.5, inherit.aes = FALSE),
                  "greater" = p + geom_rect(data=rect2,aes(xmin=xmin, xmax=xmax, ymin=ymin, ymax=ymax),fill="yellow", alpha=0.5, inherit.aes = FALSE),
                  "less" =  p + geom_rect(data=rect1,aes(xmin=xmin, xmax=xmax, ymin=ymin, ymax=ymax),fill="yellow", alpha=0.5, inherit.aes = FALSE)
      )   
      p <- p + geom_vline(xintercept = tstat,lty=2,col="red") + xlim(xlim)
      
    }
    
    else {
      
      
      npos <- sum(X>mu)
      nneg <- sum(X<mu)
      x <- min(npos,nneg)
      n <- sum(X != mu)
      
      df <- data.frame(ts = rbinom(10000,size=n,prob=0.5))
      
      p<- ggplot(df, aes(x=ts)) + 
        geom_histogram(aes(y=..density..),      # Histogram with density instead of count on y-axis
                       binwidth=.5,
                       colour="black", fill=rgb(236,0,140,maxColorValue=255)) 
      
      xlim <- c(min(x-0.2,min(df$ts)), max(x+0.2, max(df$ts)))
      
      critvals <- c(qbinom(0.025, size=n,prob=0.5),qbinom(0.975,size=n,prob=0.5))
      rect1 <- data.frame(xmin = min(critvals[1],xlim),xmax = critvals[1], ymin=-Inf,ymax=Inf)
      rect2 <- data.frame(xmin = critvals[2],xmax = max(critvals[2],xlim), ymin=-Inf,ymax=Inf)
      
      p <- p + geom_rect(data=rect1,aes(xmin=xmin, xmax=xmax, ymin=ymin, ymax=ymax),color="yellow", alpha=0.5, inherit.aes = FALSE) + geom_rect(data=rect2,aes(xmin=xmin, xmax=xmax, ymin=ymin, ymax=ymax),color="yellow", alpha=0.5, inherit.aes = FALSE)
      
      p <- p + geom_vline(xintercept = x,lty=2,col="red") + xlim(xlim)
      
    }
    print(p)
    
    
    
    
  })
  
  output$downloadScript <- downloadHandler(
    filename = function() {
      paste(input$outfile, '.R', sep='')
    },
    content = function(file) {

      cat(file = file, as.name("library(tidyverse)\n"))

      inFile <- input$file1
      
      if (is.null(inFile)) {
        cat(file = file, as.name("data<-data.frame(Month=month.name,Failure=c(2.9,2.99,2.48,1.48,2.71,4.17,3.74,3.04,1.23,2.72,3.23,3.4))\n"), append = TRUE)
      }
      else {
        cat(file = file, as.name(paste0('myfile <- \"' , inFile$name, '\"\n')), append = TRUE)
        cat(file = file, as.name("data <- as.data.frame(read_csv(myfile))\n"), append=TRUE)
      }
      
      cat(file=file,as.name("head(data)\n"),append=TRUE)
      cat(file=file,as.name(paste("mu <- ", input$mu,'\n')),append=TRUE)
      
      cat(file=file,as.name(paste("datacol <- ", input$dataCol,'\n')),append=TRUE)
      cat(file=file,as.name(paste0('transform <- \'', input$transform,'\'','\n')),append=TRUE)
      cat(file=file,as.name("if(transform != 'none') df[,datacol] <- switch(transform,log.2 = log2(df[,datacol]),log.10 = log10(df[,datacol]),log = log(df[,datacol]))\n"),append=TRUE)
      cat(file=file,as.name("if(transform != 'none') mu <- switch(transform,log.2 = log2(mu),log.10 = log10(mu),log = log(mu))\n"),append=TRUE)  
      
      cat(file=file,as.name("X <- data[,datacol]\n"),append=TRUE)
      cat(file=file,as.name("summary(X)\n"),append=TRUE)
      cat(file=file,as.name("boxplot(X,horizontal=TRUE)\n"),append=TRUE)
      
      cat(file=file,as.name("colnames(data)[datacol] <- 'X'\n"),append=TRUE)
      cat(file=file, as.name("ggplot(data, aes(x=X)) + geom_histogram(aes(y=..density..),binwidth=.5,colour='black', fill='white')+ stat_function(fun=dnorm,color='red',arg=list(mean=mean(data$X), sd=sd(data$X)))\n"),append=TRUE)
      
      cat(file=file,as.name(paste0('alternative <- \'', input$alternative,'\'','\n')),append=TRUE)
      
      if (input$do.parametric) {
        cat(file = file, as.name("t.test(X, mu = mu, alternative = alternative)\n"), append = TRUE)
      } else {
        cat(file = file, as.name("wilcox.test(X, mu = mu, alternative = alternative)\n"), append = TRUE)
#        cat(file=file,as.name("df <- data.frame(X)\n"),append=TRUE)
#        cat(file=file,as.name("df$Sign <- '='\n"),append=TRUE)
#        cat(file=file,as.name("df$Sign[X > mu] <- '+'\n"),append=TRUE)
#        cat(file=file,as.name("df$Sign[X < mu] <- '-'\n"),append=TRUE)
#        cat(file=file,as.name("npos <- sum(X>mu)\n"),append=TRUE)
#        cat(file=file,as.name("nneg <- sum(X<mu)\n"),append=TRUE)
#        cat(file=file,as.name("x <- min(npos,nneg)\n"),append=TRUE)
#        cat(file=file,as.name("n <- sum(X != mu)\n"),append=TRUE)
#        cat(file=file,as.name("p <- round(pbinom(q = x, size = n,prob = 0.5)*2,3)\n"),append=TRUE)
#        cat(file=file,as.name("p\n"),append=TRUE)
      }
      cat(file=file,as.name("sessionInfo()\n"),append=TRUE)
      #formatR::tidy_source(source=file,output = file)
    }
  )
  
  
  output$downloadMarkdown <- downloadHandler(
    filename = function() {
      paste(input$outfile, '.Rmd', sep='')
    },
    content = function(file) {

      script <- gsub(".Rmd", ".R",file)

      cat(file = script, as.name("library(tidyverse)\n"))

      inFile <- input$file1
 
      if (is.null(inFile)) {
        cat(file = script, as.name("data<-data.frame(Month=month.name,Failure=c(2.9,2.99,2.48,1.48,2.71,4.17,3.74,3.04,1.23,2.72,3.23,3.4))\n"), append = TRUE)
      }
      else {
        cat(file = script, as.name(paste0('myfile <- \"' , inFile$name, '\"\n')), append = TRUE)
        cat(file = script, as.name("data <- as.data.frame(read_csv(myfile))\n"),append = TRUE)
      }
      cat(file=script,as.name("head(data)\n"),append=TRUE)
      cat(file=script,as.name(paste("mu <- ", input$mu,'\n')),append=TRUE)
      
      cat(file=script,as.name(paste("datacol <- ", input$dataCol,'\n')),append=TRUE)
      cat(file=script,as.name("X <- data[,datacol]\n"),append=TRUE)
      cat(file=script,as.name(paste0('transform <- \'', input$transform,'\'','\n')),append=TRUE)
      cat(file=script,as.name("if(transform != 'none') df[,datacol] <- switch(transform,log.2 = log2(df[,datacol]),log.10 = log10(df[,datacol]),log = log(df[,datacol]))\n"),append=TRUE)
      cat(file=script,as.name("if(transform != 'none') mu <- switch(transform,log.2 = log2(mu),log.10 = log10(mu),log = log(mu))\n"),append=TRUE)  
      
      cat(file=script,as.name("summary(X)\n"),append=TRUE)
      cat(file=script,as.name("boxplot(X,horizontal=TRUE)\n"),append=TRUE)
      cat(file=script,as.name("colnames(data)[datacol] <- 'X'\n"),append=TRUE)
      cat(file=script, as.name("ggplot(data, aes(x=X)) + geom_histogram(aes(y=..density..),binwidth=.5,colour='black', fill='white')+ stat_function(fun=dnorm,color='red',arg=list(mean=mean(data$X), sd=sd(data$X)))\n"),append=TRUE)
      
      cat(file=script,as.name(paste0('alternative <- \'', input$alternative,'\'','\n')),append=TRUE)
      
      if (input$do.parametric) {
        cat(file = script, as.name("t.test(X, mu = mu, alternative = alternative)\n"), append = TRUE)
      } else {
        cat(file = script, as.name("wilcox.test(X, mu = mu, alternative = alternative)\n"), append = TRUE)
#        cat(file=script,as.name("df <- data.frame(X)\n"),append=TRUE)
#        cat(file=script,as.name("df$Sign <- '='\n"),append=TRUE)
#        cat(file=script,as.name("df$Sign[X > mu] <- '+'\n"),append=TRUE)
#        cat(file=script,as.name("df$Sign[X < mu] <- '-'\n"),append=TRUE)
#        cat(file=script,as.name("npos <- sum(X>mu)\n"),append=TRUE)
#        cat(file=script,as.name("nneg <- sum(X<mu)\n"),append=TRUE)
#        cat(file=script,as.name("x <- min(npos,nneg)\n"),append=TRUE)
#        cat(file=script,as.name("n <- sum(X != mu)\n"),append=TRUE)
#        cat(file=script,as.name("p <- round(pbinom(q = x, size = n,prob = 0.5)*2,3)\n"),append=TRUE)
#        cat(file=script,as.name("p\n"),append=TRUE)
      }
      cat(file=script,as.name("sessionInfo()\n"),append=TRUE)
      knitr:::spin(hair=script,knit = FALSE)
      rmd <- readLines(file)
      
      cat(file = file, paste(input$title, "\n=======================\n"))
      cat(file=file, as.name(paste("###", input$name, "\n")),append=TRUE)    
      cat(file=file, as.name(paste("### Report Generated at: ", as.character(Sys.time()), "\n")),append=TRUE)    
      
      for(i in 1:length(rmd)){
        cat(file=file, as.name(paste(rmd[i], "\n")),append=TRUE)
        
      }
      
      #    formatR::tidy_urce(file,output = file)
    }
  )
  
  
  
}
)
