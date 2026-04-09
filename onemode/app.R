source(here::here("onemode", "global.R"))
source(here::here("onemode", "ui", "ui.R"))
source(here::here("onemode", "server", "server.R"))

options(shiny.launch.browser = FALSE)
options(shiny.autoreload = TRUE)

shinyApp(ui = ui, server = server)