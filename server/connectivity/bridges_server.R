bridges <- function(input, output, session, rv, g, components_result, vis_base) {
  bridges_result <- reactive({
    g <- igraph::as.undirected(g())
    igraph::bridges(g)
  })

  cutpoints_result <- reactive({
    g <- igraph::as.undirected(g())
    igraph::articulation_points(g)
  })
  
  output$bridge_stats <- renderUI({
    req(bridges_result())
    
    g <- g()
    n_bridges <- length(bridges_result())
    n_edges <- igraph::ecount(g)
    
    tagList(
      tags$ul(
        tags$li(strong("Number of Bridges: "), n_bridges),
        tags$li(strong("Percentage of Edges: "), round(100 * n_bridges / n_edges, 1), "%"),
        tags$li(strong("Network Vulnerability: "), ifelse(n_bridges > n_edges * 0.1, "High", "Low"))
      )
    )
  })
  
  output$cutpoint_stats <- renderUI({
    req(cutpoints_result())
    
    g <- g()
    n_cutpoints <- length(cutpoints_result())
    n_nodes <- igraph::vcount(g)
    
    tagList(
      tags$ul(
        tags$li(strong("Number of Cutpoints: "), n_cutpoints),
        tags$li(strong("Percentage of Nodes: "), round(100 * n_cutpoints / n_nodes, 1), "%"),
        tags$li(strong("Network Fragility: "), ifelse(n_cutpoints > 0, "Fragile", "Robust"))
      )
    )
  })
  
  output$bridges_cutpoints_plot <- renderVisNetwork({
    req(bridges_result(), cutpoints_result())

    cutpoint_ids <- as.numeric(cutpoints_result())
    bridge_ids   <- as.numeric(bridges_result())

    vis_data <- vis_base()
    vis_data <- apply_layer_selection(vis_data, input$layer_selection)
    vis_data <- apply_node_styling(vis_data,
      node_color = input$node_color,
      node_shape = input$node_shape,
      node_size  = input$node_size,
      label_size = input$label_size
    )
    vis_data$nodes$color.background <- ifelse(
      seq_len(igraph::vcount(g())) %in% cutpoint_ids, "#FF0000", "#CCCCCC"
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

    # Overlay bridge highlighting after edge styling
    vis_data$edges$color <- ifelse(
      seq_len(nrow(vis_data$edges)) %in% bridge_ids, "#FF0000", vis_data$edges$color
    )
    vis_data$edges$width <- ifelse(
      seq_len(nrow(vis_data$edges)) %in% bridge_ids, 3, vis_data$edges$width
    )

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
  
  output$bridges_table <- renderDT({
    req(rv$igraph, bridges_result())
    
    g <- g()
    bridges_ids <- bridges_result()
    node_names <- igraph::V(g)$name %||% as.character(1:igraph::vcount(g))
    
    # Get edge endpoints
    edges <- igraph::as_edgelist(g)
    bridge_edges <- edges[bridges_ids, ]
    
    df <- data.frame(
      From = node_names[bridge_edges[, 1]],
      To = node_names[bridge_edges[, 2]]
    )
    
    datatable(df, options = list(pageLength = 10, scrollX = TRUE))
  })
  
  output$cutpoints_table <- renderDT({
    req(rv$igraph, cutpoints_result())
    
    g <- g()
    cutpoint_ids <- cutpoints_result()
    node_names <- igraph::V(g)$name %||% as.character(1:igraph::vcount(g))
    
    cutpoint_names <- node_names[cutpoint_ids]
    degrees <- igraph::degree(g)[cutpoint_ids]
    
    df <- data.frame(
      Node = cutpoint_names,
      Degree = degrees
    )
    
    df <- df[order(-df$Degree), ]
    
    datatable(df, options = list(pageLength = 10, scrollX = TRUE))
  })
}