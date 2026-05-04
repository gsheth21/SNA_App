source(here::here("textmode", "global.R"))
source(here::here("textmode", "ui", "ui.R"))
source(here::here("textmode", "server", "server.R"))

options(shiny.launch.browser = FALSE)
options(shiny.autoreload = TRUE)

shinyApp(ui = ui, server = server)
