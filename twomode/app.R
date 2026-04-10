source(here::here("twomode", "global.R"))
source(here::here("twomode", "ui", "ui.R"))
source(here::here("twomode", "server", "server.R"))

options(shiny.launch.browser = FALSE)
options(shiny.autoreload = TRUE)

shinyApp(ui = ui, server = server)
