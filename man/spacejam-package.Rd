\name{spacejam-package}
\alias{spacejam-package}
\alias{spacejam}
\docType{package}
\title{Fit sparse conditional independence graphs with joint additive models}
\description{
This package is called `spacejam', which can be thought to stand for SParse Conditional Estimation with Joint Additive Models. The two main functions of this package, \code{SJ} and \code{SJ.dag}, estimate conditional independence graphs and DAGs using flexible node-wise regressions, employing a standardized group lasso to encourage sparsity. Details of the method are given in Voorman, Shojaie and Witten (2013). Graph Estimation with Joint Additive Models.
}
\details{
\tabular{ll}{
Package: \tab spacejam\cr
Type: \tab Package\cr
Version: \tab 1.1\cr
Date: \tab 2013-04-08\cr
License: \tab GPL >= 2\cr
}

The package includes the following functions:

\tabular{ll}{
\code{\link{SJ}} and \code{\link{SJ.dag}}: \tab Estimate the conditional independence graph, or directed acyclic graph, based on observed data\cr
\code{\link{rdag}}: \tab construct a random directed acyclic graph	\cr
\code{\link{moralize}}: \tab Determine the moral graph, which is the conditional independence graph associated with the directed graph \cr
\code{\link{generate.dag.data}}:\tab Generate data from a bayesian network \cr
\code{\link{plot.SJ}}:\tab Plot SJ and SJ.dag objects.\cr
}

}
\author{
Arend Voorman

Maintainer: Arend Voorman <voorma@uw.edu>
}
\references{
Voorman, Shojaie and Witten (2013). Graph Estimation with Joint Additive Models. Submitted to Biometrika. available on ArXiv or from authors upon request
}
\keyword{ package }
\seealso{
\code{\link{spacejam}}
\code{\link{SJ}}
\code{\link{generate.dag.data}}
}
\examples{
#########Create graph and distribution used in Figure 2 of Voorman, Shojaie and Witten (2013):
p <- 100 #variables
n <- 50 #observations

#Generate Graph
set.seed(20)
g <- rdag(p,80)
mylayout <- layout.fruchterman.reingold(g)

par(mfrow=c(1,2))
plot(g, layout = mylayout, edge.color = "gray50", 
        vertex.color = "red", vertex.size = 3, vertex.label = NA, 
        edge.arrow.size = 0.4)
plot(moralize(g), layout = mylayout, edge.color = "gray50", 
        vertex.color = "red", vertex.size = 3, vertex.label = NA, 
        edge.arrow.size = 0.4)

#create a distribution on the DAG using cubic polynomials with random normal coefficients 
#with standard deviations of 1, 0.5 and 0.5, (i.e. giving more weight to linear association than quadratic or cubic)
data <- generate.dag.data(g,n,basesd=c(1,0.5,0.5))
X <- data$X

#Fit conditional independence graph at one lambda 
fit1 <- SJ(X, lambda = 0.6)

#Fit conditional independence graph at 10 (hopefully reasonable) lambdas:
fit2 <- SJ(X, length = 10)

#Fit conditional independence graph using quadratic basis functions:
fit3 <- SJ(X, bfun = function(x){cbind(x,x^2)}, length = 10)

#Fit the DAG using default causal ordering 1:p, and at 10 lambdas
fit4 <- SJ.dag(X, length = 10)
fit4

#plot the DAGs, and the true graph
par(mfrow=c(1,3))
plot(g, layout=mylayout, edge.color = "gray50", vertex.color = "red", vertex.size = 3, vertex.label = NA, edge.arrow.size = 0.4, main="True DAG")
plot(fit4, layout = mylayout, which= 4, main= paste0("lambda = ",round(fit4$lambda[4],2) ))
plot(fit4, layout = mylayout, main = "min BIC")

###For additional replications using the same DAG distribution use e.g.
data <- generate.dag.data(g,n,funclist = data$funclist)


#### Screen out edges whose corresponding nodes have low spearman correlation:
# useful for approximating spacejam in high dimesnions
S <- cor(data$X, method = "spearman")
G.max <- S > 0.1
mean(G.max) #~75\% of edges removed

system.time({fit.screen <- SJ(X, G.max = G.max,length=20)})
system.time({fit.noscreen <- SJ(X,length = 20)})

plot(fit.screen, layout=mylayout)
plot(fit.noscreen, layout=mylayout)
}
