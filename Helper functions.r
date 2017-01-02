####Some functions I wrote to automate some of the iterative processing in quine_workup.r. These could be made more general, but given time constraints I've taken some shortcuts and hard-coded in a few variables.
#Author: Sophie King
#Date: 30/12/2016

#1. A function to run through a list of variables, adding them to the model one at a time to select the best, in the order of impact. Criteria are p-values, with variables only added if they improve AIC.

me.choice <- function(me.list, thresh){
  #me.list is a list of the factors you want to test
  #thresh is the significance threshold for keeping or dropping a variable
  #Output: dataframe with list of variables to include, in order, and the AICs, for checking
  # c(varlist, AICs)
  fac.list.ordered <- NULL
  #Take minimum AIC as the AIC for the null model
  min.aic <- glm(Days ~ 1, data = training, family = poisson)$aic
  aics <- round(min.aic,0)
  while (length(me.list)>0){
    #intialise variables
    min.p <- Inf
    min.fac <- NULL
    #Choose best one, if existing
    x <- test.facs(me.list, thresh, fac.list.ordered)
    if (is.null(x)) return(fac.list.ordered)
    else {
      #Update ordered factor list
      fac.list.ordered <- c(fac.list.ordered, x[1])
      #Remove the factor you've included
      me.list <- me.list[me.list != x[1]]
      #Update minimum AIC and AIC list
      min.aic <- x[2]
      aics <- c(aics, round(as.numeric(x[2]),0))
    }
  }
  return(rbind(c('Null',fac.list.ordered), aics))
}

test.facs <- function(me.list, thresh, fac.list.ordered){
  for (fac in me.list) {
    mod <- glm(as.formula(paste('Days ~ ', paste(fac.list.ordered, collapse = '+'), '+', fac)),
               data = training,
               family = poisson
               )
    #print(mod)
    #Note we're always adding the new variable last
    sig <- tail(anova(mod, test = "Chisq")$"Pr(>Chi)",n=1)
    aic <- mod$aic
    #Choose the best factor to add
    if (sig < min(min.p, thresh) & aic < min.aic) {
      min.p <- sig
      min.fac <- fac
      min.aic <- aic
    }
  }
  #return updated factor list if there's a candidate variable, else stop the process
  if (!is.null(min.fac)) return(c(min.fac, min.aic))
}

#2. Function to automate two-way summaries of variables with table and mosaic plot

cat.summ <- function(fac1, fac2) {
  #fac1, fac2 are the two factors to compare
  fac1.label <- deparse(substitute(fac1))
  fac2.label <- deparse(substitute(fac2))
  x <- xtabs(~ fac1 + fac2)
  mosaicplot(x,
             main = paste("Students by", fac1.label, "and", fac2.label),
             xlab = fac1.label,
             ylab = fac2.label)
  x
}

#3. Function to see distribution of response variable by categorical factors
qd_density <- function(fac) {
  par(mfrow = c(1,2))
  #Get the factor name as input to the function, for labelling purposes
  faclabel <- deparse(substitute(fac))
  #Density plots, overlaid for comparison
  sm.density.compare(Days,
                     fac,
                     xlab = 'Absent Days')
  title(main = paste('Distribution of Absent Days by', faclabel))
  colfill<-c(2:(2+length(levels(fac))))
  legend('topright', levels(fac), fill=colfill, inset = 0.1, title = faclabel)
  #Box plots
  boxplot(Days ~ fac,
          main = paste("Distribution of Absent Days by", faclabel),
          ylab = "Number of Absent Days",
          xlab = faclabel)
  #Summary statistics
  describeBy(Days, fac)
}