source(here::here("onemode", "server", "connectivity", "components_server.R"))
source(here::here("onemode", "server", "connectivity", "paths_server.R"))
source(here::here("onemode", "server", "connectivity", "distance_server.R"))
source(here::here("onemode", "server", "connectivity", "diameter_server.R"))
source(here::here("onemode", "server", "connectivity", "bridges_server.R"))
source(here::here("onemode", "server", "connectivity", "reachability_server.R"))

connectivity_server <- function(input, output, session, rv) {
  g <- reactive({
    req(rv$igraph)
    ensure_igraph(rv$igraph)
  })

  components_result <- reactive({
    igraph::components(g())
  })

  vis_base <- reactive({
    igraph_to_visNetwork(g(), input$layout)
  })
  
  components(input, output, session, rv, g, components_result, vis_base)
  path(input, output, session, rv, g, components_result, vis_base)
  distance(input, output, session, rv, g, components_result, vis_base)
  diameter(input, output, session, rv, g, components_result, vis_base)
  bridges(input, output, session, rv, g, components_result, vis_base)
  reachability(input, output, session, rv, g, components_result, vis_base)
}