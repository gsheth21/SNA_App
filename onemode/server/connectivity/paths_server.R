path <- function(input, output, session, rv, g, components_result, vis_base) {
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
    req(rv$path_result)

    path_ids <- as.numeric(rv$path_result$path)

    vis_data <- vis_base()
    vis_data <- apply_layer_selection(vis_data, input$layer_selection)
    vis_data <- apply_node_styling(vis_data,
      node_color = input$node_color,
      node_shape = input$node_shape,
      node_size  = input$node_size,
      label_size = input$label_size
    )
    vis_data$nodes$color.background <- ifelse(
      vis_data$nodes$id %in% path_ids, "#FF6B6B", "#97C2FC"
    )
    vis_data$nodes$color.border <- "#000000"

    edge_result <- apply_edge_styling(vis_data, g(),
      hide_arrows    = input$hide_arrows,
      edge_color     = input$edge_color,
      edge_width     = input$edge_width,
      edge_opacity   = input$edge_opacity,
      edge_style     = input$edge_style,
      curve_strength = input$curve_strength %||% 0.3
    )
    vis_data <- edge_result$vis_data

    # Highlight edges along the shortest path
    if (length(path_ids) >= 2) {
      path_from <- path_ids[-length(path_ids)]
      path_to   <- path_ids[-1]
      on_path <- Reduce(`|`, mapply(function(f, t) {
        (vis_data$edges$from == f & vis_data$edges$to == t) |
        (vis_data$edges$from == t & vis_data$edges$to == f)
      }, path_from, path_to, SIMPLIFY = FALSE))
      vis_data$edges$color <- ifelse(on_path, "#FF6B6B", vis_data$edges$color)
      vis_data$edges$width <- ifelse(on_path, 3, vis_data$edges$width)
    }

    weight_result <- apply_weight_style(vis_data, g(), input$weight_style)
    vis_data <- weight_result$vis_data

    visNetwork(vis_data$nodes, vis_data$edges) %>%
      visEdges(smooth = edge_result$smooth) %>%
      visPhysics(solver = "forceAtlas2Based",
                forceAtlas2Based = list(gravitationalConstant = -50)) %>%
      visLayout(randomSeed = 42) %>%
      visInteraction(dragNodes = TRUE, dragView = TRUE,
                    zoomView = TRUE, navigationButtons = TRUE) %>%
      visOptions(highlightNearest = TRUE)
  })

  output$path_ggraph <- renderPlot({
    req(rv$path_result)
    path_ids  <- as.numeric(rv$path_result$path)
    n_nodes   <- igraph::vcount(g())
    fill_cols <- ifelse(seq_len(n_nodes) %in% path_ids, "#FF6B6B", "#97C2FC")
    build_ggraph_plot(g(), input, node_fill_override = fill_cols)
  }, res = 110)
}