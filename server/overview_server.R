overview_server <- function(input, output, session, rv) {

  observeEvent(input$dataset, {
    req(input$dataset)
    
    # Load the network
    network_obj <- load_network_data(input$dataset)
    
    # Convert to igraph if needed
    rv$igraph <- ensure_igraph(network_obj)
    
    # Also store network version (for some analyses)
    rv$network <- ensure_network(network_obj)
  })
  
  # Network properties display
  output$overview_properties <- renderUI({
    req(rv$igraph)
    g <- rv$igraph
    
    n_nodes <- vcount(g)
    n_edges <- ecount(g)
    density <- edge_density(g)
    n_components <- igraph::components(g)$no
    is_directed <- is_directed(g)
    
    # Calculate diameter and avg path length (only if connected)
    if (n_components == 1) {
      diam <- igraph::diameter(g)
      avg_path <- round(igraph::mean_distance(g), 3)
    } else {
      diam <- "N/A (disconnected)"
      avg_path <- "N/A (disconnected)"
    }

    trans <- round(igraph::transitivity(g, type = "global"), 3)
    
    tagList(
      tags$ul(
        tags$li(strong("Nodes (Vertices): "), n_nodes),
        tags$li(strong("Edges (Ties): "), n_edges),
        tags$li(strong("Network Type: "), ifelse(is_directed, "Directed", "Undirected")),
        tags$li(strong("Density: "), round(density, 3)),
        tags$li(strong("Components: "), n_components),
        tags$li(strong("Diameter: "), diam),
        tags$li(strong("Average Path Length: "), 
                ifelse(is.numeric(avg_path), round(avg_path, 2), avg_path))
      )
    )
  })
  
  # Dataset description
  output$dataset_description <- renderUI({
    req(input$dataset)
    
    description <- get_dataset_description(input$dataset)
    
    tagList(
      p(description),
      hr(),
      h5("Available Attributes:"),
      uiOutput("dataset_attributes")
    )
  })

  output$dataset_attributes <- renderUI({
    req(rv$igraph)
    
    node_attrs <- get_node_attributes(rv$igraph)
    edge_attrs <- get_edge_attributes(rv$igraph)
    
    tagList(
      if (length(node_attrs) > 0) {
        tagList(
          p(strong("Node Attributes: ")),
          tags$ul(
            lapply(node_attrs, function(attr) {
              tags$li(attr)
            })
          )
        )
      } else {
        p("No node attributes available")
      },
      
      if (length(edge_attrs) > 0) {
        tagList(
          p(strong("Edge Attributes: ")),
          tags$ul(
            lapply(edge_attrs, function(attr) {
              tags$li(attr)
            })
          )
        )
      } else {
        p("No edge attributes available")
      }
    )
  })
}