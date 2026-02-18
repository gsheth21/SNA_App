networks_server <- function(input, output, session, rv) {
  
  output$network_properties <- renderUI({
    req(rv$igraph)
    g <- rv$igraph
    
    n_nodes <- vcount(g)
    n_edges <- ecount(g)
    density <- edge_density(g)
    is_directed <- is_directed(g)
    
    tagList(
      tags$ul(
        tags$li(strong("Nodes: "), n_nodes),
        tags$li(strong("Edges: "), n_edges),
        tags$li(strong("Type: "), ifelse(is_directed, "Directed", "Undirected")),
        tags$li(strong("Density: "), round(density, 3))
      )
    )
  })
  
  output$dataset_info <- renderUI({
    req(input$dataset)
    description <- get_dataset_description(input$dataset)
    p(description)
  })
  
  output$data_table <- renderDT({
    req(rv$igraph)
    g <- rv$igraph
    
    if (input$data_view == "Edgelist") {
      el <- as_edgelist(g, names = TRUE)
      df <- data.frame(From = el[, 1], To = el[, 2])
    } else if (input$data_view == "Adjacency Matrix") {
      adj <- as_adjacency_matrix(g, sparse = FALSE)
      df <- as.data.frame(adj)
    } else { # Nodes
      node_names <- V(g)$name %||% as.character(1:vcount(g))
      df <- data.frame(Node = node_names)
      
      # Add attributes if they exist
      attrs <- vertex_attr_names(g)
      attrs <- attrs[attrs != "name"]
      for (attr in attrs) {
        df[[attr]] <- vertex_attr(g, attr)
      }
    }
    
    datatable(df, options = list(pageLength = 10, scrollX = TRUE))
  })
}