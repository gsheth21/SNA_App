connectivity_server <- function(input, output, session, rv) {
  
  output$component_stats <- renderUI({
    req(rv$igraph)
    g <- rv$igraph
    
    comp <- igraph::components(g)
    n_components <- comp$no
    sizes <- comp$csize
    main_size <- max(sizes)
    isolates <- sum(igraph::degree(g) == 0)
    
    tagList(
      tags$ul(
        tags$li(strong("Number of Components: "), n_components),
        tags$li(strong("Main Component Size: "), main_size, " nodes"),
        tags$li(strong("Isolates: "), isolates, " nodes")
      )
    )
  })
  
  output$components_plot <- renderVisNetwork({
    req(rv$igraph)
    g <- rv$igraph
    
    comp <- components(g)
    colors <- rainbow(comp$no)
    node_colors <- colors[comp$membership]
    
    vis_data <- igraph_to_visNetwork(g, input$layout)
    vis_data$nodes$color <- node_colors
    vis_data$nodes$size <- input$node_size
    
    visNetwork(vis_data$nodes, vis_data$edges) %>%
      visOptions(highlightNearest = TRUE) %>%
      visInteraction(navigationButtons = TRUE)
  })
  
  # Path finding UI controls
  output$path_from <- renderUI({
    req(rv$igraph)
    node_names <- V(rv$igraph)$name %||% as.character(1:vcount(rv$igraph))
    selectInput("path_from_node", "From:", choices = node_names)
  })
  
  output$path_to <- renderUI({
    req(rv$igraph)
    node_names <- V(rv$igraph)$name %||% as.character(1:vcount(rv$igraph))
    selectInput("path_to_node", "To:", choices = node_names)
  })
  
  observeEvent(input$find_path, {
    req(input$path_from_node, input$path_to_node)
    req(rv$igraph)
    
    g <- rv$igraph
    node_names <- V(g)$name %||% as.character(1:vcount(g))
    
    from_id <- which(node_names == input$path_from_node)
    to_id <- which(node_names == input$path_to_node)
    
    path <- shortest_paths(g, from_id, to_id)$vpath[[1]]
    
    rv$path_result <- list(
      from = input$path_from_node,
      to = input$path_to_node,
      path = path,
      length = length(path) - 1
    )
  })
  
  output$path_results <- renderUI({
    req(rv$path_result)
    
    path_names <- V(rv$igraph)$name[rv$path_result$path] %||% 
                  as.character(rv$path_result$path)
    
    tagList(
      tags$ul(
        tags$li(strong("Shortest Path Length: "), rv$path_result$length),
        tags$li(strong("Path: "), paste(path_names, collapse = " → "))
      )
    )
  })
  
  output$path_plot <- renderVisNetwork({
    req(rv$igraph)
    req(rv$path_result)
    
    g <- rv$igraph
    vis_data <- igraph_to_visNetwork(g, input$layout)
    
    path_ids <- as.numeric(rv$path_result$path)
    vis_data$nodes$color <- ifelse(vis_data$nodes$id %in% path_ids, 
                                     "#FF6B6B", "#97C2FC")
    vis_data$nodes$size <- input$node_size
    
    visNetwork(vis_data$nodes, vis_data$edges) %>%
      visOptions(highlightNearest = TRUE) %>%
      visInteraction(navigationButtons = TRUE)
  })
  
  output$distance_heatmap <- renderPlotly({
    req(rv$igraph)
    g <- rv$igraph
    
    dist_mat <- distances(g)
    node_names <- V(g)$name %||% as.character(1:vcount(g))
    
    plot_ly(
      x = node_names,
      y = node_names,
      z = dist_mat,
      type = "heatmap",
      colorscale = "Viridis"
    ) %>%
      layout(
        title = "Geodesic Distance Matrix",
        xaxis = list(title = ""),
        yaxis = list(title = "")
      )
  })
}