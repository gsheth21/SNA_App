source(here::here("global.R"))
source(here::here("ui", "ui.R"))
source(here::here("server", "server.R"))

options(shiny.launch.browser = FALSE)
options(shiny.autoreload = TRUE)

shinyApp(ui = ui, server = server)