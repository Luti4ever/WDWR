library(MASS)

mu = c(9, 8, 7, 6)
sigma = matrix(c(16,	-2,	-1,	-3,
                 -2,	9,	-4,	-1,
                 -1,	-4,	4,	1,
                 -3,	-1,	1,	1),
               nrow=4, ncol=4)
               
tol = 1e-6
empirical = FALSE
eispack = FALSE

all_cases <- mvrnorm(10000, mu,sigma, tol, empirical, eispack)
all_cases <- all_cases[all_cases[,1]>=5,]
all_cases <- all_cases[all_cases[,2]>=5,]
all_cases <- all_cases[all_cases[,3]>=5,]
all_cases <- all_cases[all_cases[,4]>=5,]
all_cases <- all_cases[all_cases[,1]<=12,]
all_cases <- all_cases[all_cases[,2]<=12,]
all_cases <- all_cases[all_cases[,3]<=12,]
all_cases <- all_cases[all_cases[,4]<=12,]
all_cases <- all_cases[1:1000,]

write.table(all_cases, "scenariusze.data", sep=" ", eol="]\n[", row.names = FALSE, col.names=FALSE)
