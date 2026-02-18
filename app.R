source(here::here("global.R"))
source(here::here("ui", "ui.R"))
source(here::here("server", "server.R"))

shinyApp(ui = ui, server = server)