source(here::here("server", "connectivity", "components_server.R"))
source(here::here("server", "connectivity", "paths_server.R"))
source(here::here("server", "connectivity", "distance_server.R"))
source(here::here("server", "connectivity", "diameter_server.R"))
source(here::here("server", "connectivity", "bridges_server.R"))
source(here::here("server", "connectivity", "reachability_server.R"))

connectivity_server <- function(input, output, session, rv) {
  g <- reactive({
    req(rv$igraph)
    ensure_igraph(rv$igraph)
  })

  components_result <- reactive({
    igraph::components(g())
  })
  
  components(input, output, session, rv, g, components_result)
  path(input, output, session, rv, g, components_result)
  distance(input, output, session, rv, g, components_result)
  diameter(input, output, session, rv, g, components_result)
  bridges(input, output, session, rv, g, components_result)
  reachability(input, output, session, rv, g, components_result)
}