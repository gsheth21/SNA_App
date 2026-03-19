path <- function(input, output, session, rv, g, components_result) {
  output$path_from <- renderUI({
    req(rv$igraph)
    g <- g()
    node_names <- igraph::V(g)$name %||% as.character(1:igraph::vcount(g))
    selectInput("path_from_node", "From:", choices = node_names)
  })
  
  output$path_to <- renderUI({
    req(rv$igraph)
    g <- g()
    node_names <- igraph::V(g)$name %||% as.character(1:igraph::vcount(g))
    selectInput("path_to_node", "To:", choices = node_names)
  })
  
  observeEvent(input$find_path, {
    req(input$path_from_node, input$path_to_node)
    req(rv$igraph)
    
    g <- g()
    node_names <- igraph::V(g)$name %||% as.character(1:igraph::vcount(g))
    
    from_id <- which(node_names == input$path_from_node)
    to_id <- which(node_names == input$path_to_node)
    
    path <- igraph::shortest_paths(g, from_id, to_id)$vpath[[1]]
    
    rv$path_result <- list(
      from = input$path_from_node,
      to = input$path_to_node,
      path = path,
      length = length(path) - 1
    )
  })
  
  output$path_results <- renderUI({
    req(rv$path_result)
    
    g <- g()
    path_names <- igraph::V(g)$name[rv$path_result$path] %||% 
                  as.character(rv$path_result$path)
    
    path_str <- paste(path_names, collapse = " → ")
    
    tagList(
      tags$ul(
        tags$li(strong("From: "), rv$path_result$from),
        tags$li(strong("To: "), rv$path_result$to),
        tags$li(strong("Path Length: "), rv$path_result$length, " steps"),
        tags$li(strong("Path: "), path_str)
      )
    )
  })
  
  output$distance_stats <- renderUI({
    req(rv$igraph)
    g <- g()
    
    if (components_result()$no == 1) {
      avg_dist <- igraph::mean_distance(g)
      diam <- igraph::diameter(g)
      
      tagList(
        tags$ul(
          tags$li(strong("Average Distance: "), round(avg_dist, 3)),
          tags$li(strong("Network Diameter: "), diam)
        )
      )
    } else {
      p("Network is disconnected. Statistics only for largest component.")
    }
  })
  
  output$path_plot <- renderVisNetwork({
    req(rv$igraph)
    req(rv$path_result)
    
    g <- g()
    vis_data <- igraph_to_visNetwork(g, input$layout)
    
    path_ids <- as.numeric(rv$path_result$path)
    vis_data$nodes$color <- ifelse(vis_data$nodes$id %in% path_ids, 
                                     "#FF6B6B", "#97C2FC")
    vis_data$nodes$size <- input$node_size
    
    visNetwork(vis_data$nodes, vis_data$edges) %>%
      visOptions(highlightNearest = TRUE) %>%
      visInteraction(navigationButtons = TRUE)
  })
}