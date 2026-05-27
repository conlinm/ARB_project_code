# This line prevents the annoying "Do you want to install from source" dialogs:
options(install.packages.compile.from.source = "never")

install.packages("remotes")
library(remotes)
install_github("ohdsi/Hades", upgrade = "always")
