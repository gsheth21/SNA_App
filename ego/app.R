source(here::here("ego", "global.R"))
source(here::here("ego", "ui", "ui.R"))
source(here::here("ego", "server", "server.R"))

options(shiny.launch.browser = FALSE)
options(shiny.autoreload = TRUE)

shinyApp(ui = ui, server = server)
