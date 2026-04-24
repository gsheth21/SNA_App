library(here)

source(here::here("dynamic_nets", "global.R"))
source(here::here("dynamic_nets", "ui", "ui.R"))
source(here::here("dynamic_nets", "server", "server.R"))

options(shiny.launch.browser = FALSE)
options(shiny.autoreload = TRUE)

shinyApp(ui = ui, server = server)
