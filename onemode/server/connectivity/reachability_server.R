reachability <- function(input, output, session, rv, g, components_result, vis_base) {
  output$reachability_node_select <- renderUI({
    req(rv$igraph)
    g <- g()
    node_names <- igraph::V(g)$name %||% as.character(1:igraph::vcount(g))
    selectInput("reachability_node", "Select Source Node:", choices = node_names)
  })
  
  observeEvent(input$analyze_reachability, {
    req(rv$igraph, input$reachability_node)
    
    g <- g()
    node_names <- igraph::V(g)$name %||% as.character(1:igraph::vcount(g))
    node_id <- which(node_names == input$reachability_node)
    
    # Get all reachable nodes and their distances
    dist_from_node <- igraph::distances(g, v = node_id)[1, ]
    
    rv$reachability_result <- list(
      distances = dist_from_node,
      source_node = input$reachability_node,
      source_id = node_id
    )
  })
  
  output$reachability_stats <- renderUI({
    req(rv$reachability_result)
    
    dist <- rv$reachability_result$distances
    reachable <- sum(is.finite(dist)) - 1  # Exclude self
    total <- length(dist) - 1
    
    tagList(
      tags$ul(
        tags$li(strong("Source Node: "), rv$reachability_result$source_node),
        tags$li(strong("Reachable Nodes: "), reachable, " out of ", total),
        tags$li(strong("Reachability: "), round(100 * reachable / total, 1), "%"),
        tags$li(strong("Average Distance: "), round(mean(dist[is.finite(dist) & dist > 0]), 2))
      )
    )
  })
  
  output$reachable_by_distance <- renderPlotly({
    req(rv$reachability_result)
    
    dist <- rv$reachability_result$distances
    dist <- dist[dist > 0]
    dist <- dist[is.finite(dist)]
    
    dist_table <- table(dist)
    
    plot_ly(x = as.numeric(names(dist_table)), y = as.numeric(dist_table), type = "bar") %>%
      layout(
        title = "Nodes Reachable by Distance",
        xaxis = list(title = "Distance"),
        yaxis = list(title = "Number of Nodes")
      )
  })
  
  output$reachability_plot <- renderVisNetwork({
    req(rv$reachability_result)

    dist      <- rv$reachability_result$distances
    source_id <- rv$reachability_result$source_id
    reachable <- is.finite(dist) & dist > 0

    vis_data <- vis_base()
    vis_data <- apply_layer_selection(vis_data, input$layer_selection)
    vis_data <- apply_node_styling(vis_data,
      node_color = input$node_color,
      node_shape = input$node_shape,
      node_size  = input$node_size,
      label_size = input$label_size
    )
    vis_data$nodes$color.background <- ifelse(
      seq_len(igraph::vcount(g())) == source_id, "#FF0000",
      ifelse(reachable, "#00CC00", "#CCCCCC")
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

    # Highlight only edges directly connected to source node
edge_from_source <- vis_data$edges$from == source_id |
                    vis_data$edges$to   == source_id
vis_data$edges$color <- ifelse(edge_from_source, "#FF6B6B", "#AAAAAA")
vis_data$edges$width <- ifelse(edge_from_source, 2, 1)

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
}