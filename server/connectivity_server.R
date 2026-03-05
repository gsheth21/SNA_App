connectivity_server <- function(input, output, session, rv) {
  
  # ============================================================
  # CONNECTED COMPONENTS
  # ============================================================
  
  observeEvent(input$analyze_components, {
    req(rv$igraph)
    g <- ensure_igraph(rv$igraph)
    
    comp <- igraph::components(g)
    rv$components_result <- comp
  })
  
  output$component_stats <- renderUI({
    req(rv$components_result)
    
    comp <- rv$components_result
    g <- ensure_igraph(rv$igraph)
    n_components <- comp$no
    sizes <- comp$csize
    main_size <- max(sizes)
    isolates <- sum(igraph::degree(g) == 0)
    
    tagList(
      tags$ul(
        tags$li(strong("Number of Components: "), n_components),
        tags$li(strong("Main Component Size: "), main_size, " nodes"),
        tags$li(strong("Isolates: "), isolates, " nodes"),
        tags$li(strong("Network Connectivity: "), ifelse(n_components == 1, "Fully Connected", "Fragmented"))
      )
    )
  })
  
  output$component_size_dist <- renderPlotly({
    req(rv$components_result)
    
    comp <- rv$components_result
    sizes <- sort(comp$csize, decreasing = TRUE)
    
    plot_ly(x = 1:length(sizes), y = sizes, type = "bar") %>%
      layout(
        title = "Component Size Distribution",
        xaxis = list(title = "Component ID"),
        yaxis = list(title = "Size (Number of Nodes)")
      )
  })
  
  output$components_plot <- renderVisNetwork({
    req(rv$igraph, rv$components_result)
    
    g <- ensure_igraph(rv$igraph)
    comp <- rv$components_result
    
    colors <- rainbow(comp$no)
    node_colors <- colors[comp$membership]
    
    vis_data <- igraph_to_visNetwork(g, input$layout)
    vis_data$nodes$color <- node_colors
    vis_data$nodes$size <- input$node_size
    
    visNetwork(vis_data$nodes, vis_data$edges) %>%
      visOptions(highlightNearest = TRUE) %>%
      visInteraction(navigationButtons = TRUE)
  })
  
  output$component_membership_table <- renderDT({
    req(rv$components_result)
    
    g <- ensure_igraph(rv$igraph)
    comp <- rv$components_result
    node_names <- igraph::V(g)$name %||% as.character(1:igraph::vcount(g))
    
    df <- data.frame(
      Node = node_names,
      Component = comp$membership,
      Component_Size = comp$csize[comp$membership]
    )
    
    df <- df[order(df$Component, df$Node), ]
    
    datatable(df, options = list(pageLength = 10, scrollX = TRUE))
  })
  
  # ============================================================
  # SHORTEST PATHS
  # ============================================================
  
  output$path_from <- renderUI({
    req(rv$igraph)
    g <- ensure_igraph(rv$igraph)
    node_names <- igraph::V(g)$name %||% as.character(1:igraph::vcount(g))
    selectInput("path_from_node", "From:", choices = node_names)
  })
  
  output$path_to <- renderUI({
    req(rv$igraph)
    g <- ensure_igraph(rv$igraph)
    node_names <- igraph::V(g)$name %||% as.character(1:igraph::vcount(g))
    selectInput("path_to_node", "To:", choices = node_names)
  })
  
  observeEvent(input$find_path, {
    req(input$path_from_node, input$path_to_node)
    req(rv$igraph)
    
    g <- ensure_igraph(rv$igraph)
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
    
    g <- ensure_igraph(rv$igraph)
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
    g <- ensure_igraph(rv$igraph)
    
    if (igraph::components(g)$no == 1) {
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
    
    g <- ensure_igraph(rv$igraph)
    vis_data <- igraph_to_visNetwork(g, input$layout)
    
    path_ids <- as.numeric(rv$path_result$path)
    vis_data$nodes$color <- ifelse(vis_data$nodes$id %in% path_ids, 
                                     "#FF6B6B", "#97C2FC")
    vis_data$nodes$size <- input$node_size
    
    visNetwork(vis_data$nodes, vis_data$edges) %>%
      visOptions(highlightNearest = TRUE) %>%
      visInteraction(navigationButtons = TRUE)
  })
  
  # ============================================================
  # DISTANCE MATRIX
  # ============================================================
  
  observeEvent(input$compute_distances, {
    req(rv$igraph)
    g <- ensure_igraph(rv$igraph)
    
    dist_mat <- igraph::distances(g)
    rv$distance_matrix <- dist_mat
  })
  
  output$distance_properties <- renderUI({
    req(rv$igraph, rv$distance_matrix)
    
    g <- ensure_igraph(rv$igraph)
    dist_mat <- rv$distance_matrix
    
    comp <- igraph::components(g)
    
    # Only compute for finite distances
    finite_dist <- dist_mat[is.finite(dist_mat)]
    
    tagList(
      tags$ul(
        tags$li(strong("Network Diameter: "), ifelse(comp$no == 1, max(finite_dist), "Inf (disconnected)")),
        tags$li(strong("Average Shortest Path: "), round(mean(finite_dist), 3)),
        tags$li(strong("Median Distance: "), median(finite_dist)),
        tags$li(strong("Max Distance: "), max(finite_dist))
      )
    )
  })
  
  output$distance_heatmap <- renderPlotly({
    req(rv$igraph, rv$distance_matrix)
    
    g <- ensure_igraph(rv$igraph)
    dist_mat <- rv$distance_matrix
    node_names <- igraph::V(g)$name %||% as.character(1:igraph::vcount(g))
    
    # Replace Inf with max finite value for visualization
    dist_mat_vis <- dist_mat
    max_finite <- max(dist_mat_vis[is.finite(dist_mat_vis)])
    dist_mat_vis[is.infinite(dist_mat_vis)] <- max_finite + 1
    
    plot_ly(
      x = node_names,
      y = node_names,
      z = dist_mat_vis,
      type = "heatmap",
      colorscale = "Viridis"
    ) %>%
      layout(
        title = "Distance Heatmap (all pairwise shortest paths)",
        xaxis = list(title = "Node"),
        yaxis = list(title = "Node")
      )
  })
  
  output$distance_histogram <- renderPlotly({
    req(rv$distance_matrix)
    
    dist_mat <- rv$distance_matrix
    finite_dist <- dist_mat[is.finite(dist_mat) & dist_mat > 0]
    
    plot_ly(x = finite_dist, type = "histogram") %>%
      layout(
        title = "Distribution of Shortest Path Lengths",
        xaxis = list(title = "Path Length"),
        yaxis = list(title = "Frequency")
      )
  })
  
  # ============================================================
  # NETWORK DIAMETER
  # ============================================================
  
  observeEvent(input$compute_diameter, {
    req(rv$igraph)
    g <- ensure_igraph(rv$igraph)
    
    if (igraph::components(g)$no == 1) {
      diam <- igraph::diameter(g)
      avg_path <- igraph::mean_distance(g)
    } else {
      # Only for largest component
      comp <- igraph::components(g)
      largest_comp <- which.max(comp$csize)
      nodes_in_largest <- which(comp$membership == largest_comp)
      g_largest <- igraph::induced_subgraph(g, nodes_in_largest)
      
      diam <- igraph::diameter(g_largest)
      avg_path <- igraph::mean_distance(g_largest)
    }
    
    rv$diameter_result <- list(diameter = diam, avg_path = avg_path)
  })
  
  output$diameter_metrics <- renderUI({
    req(rv$diameter_result)
    
    result <- rv$diameter_result
    
    tagList(
      tags$ul(
        tags$li(strong("Diameter: "), result$diameter),
        tags$li(strong("Average Path Length: "), round(result$avg_path, 3)),
        tags$li(strong("Interpretation: "), ifelse(result$diameter <= 3, "Small world network", "Sparse network"))
      )
    )
  })
  
  output$path_length_stats <- renderUI({
    req(rv$distance_matrix)
    
    dist_mat <- rv$distance_matrix
    finite_dist <- dist_mat[is.finite(dist_mat) & dist_mat > 0]
    
    tagList(
      tags$ul(
        tags$li(strong("Shortest Path: "), min(finite_dist)),
        tags$li(strong("Longest Path: "), max(finite_dist)),
        tags$li(strong("Average: "), round(mean(finite_dist), 3)),
        tags$li(strong("Median: "), median(finite_dist))
      )
    )
  })
  
  output$avg_path_length_plot <- renderPlotly({
    req(rv$distance_matrix)
    
    dist_mat <- rv$distance_matrix
    finite_dist <- dist_mat[is.finite(dist_mat) & dist_mat > 0]
    
    # Create cumulative distribution
    sorted_dist <- sort(unique(finite_dist))
    cum_nodes <- sapply(sorted_dist, function(d) sum(finite_dist <= d))
    
    plot_ly(x = sorted_dist, y = cum_nodes, type = "scatter", mode = "lines+markers") %>%
      layout(
        title = "Cumulative Distribution of Path Lengths",
        xaxis = list(title = "Path Length"),
        yaxis = list(title = "Number of Node Pairs")
      )
  })
  
  # ============================================================
  # BRIDGES & CUTPOINTS
  # ============================================================
  
  observeEvent(input$find_bridges_cutpoints, {
    req(rv$igraph)
    g <- ensure_igraph(rv$igraph)
    g <- igraph::as.undirected(g)
    
    # Find bridges (articulation edges)
    bridges_list <- igraph::bridges(g)
    
    # Find cutpoints (articulation points)
    cutpoints_list <- igraph::articulation_points(g)
    
    rv$bridges_result <- bridges_list
    rv$cutpoints_result <- cutpoints_list
  })
  
  output$bridge_stats <- renderUI({
    req(rv$bridges_result)
    
    g <- ensure_igraph(rv$igraph)
    n_bridges <- length(rv$bridges_result)
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
    req(rv$cutpoints_result)
    
    g <- ensure_igraph(rv$igraph)
    n_cutpoints <- length(rv$cutpoints_result)
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
    req(rv$igraph, rv$bridges_result, rv$cutpoints_result)
    
    g <- ensure_igraph(rv$igraph)
    vis_data <- igraph_to_visNetwork(g, input$layout)
    
    # Highlight cutpoints
    cutpoint_ids <- rv$cutpoints_result
    vis_data$nodes$color <- ifelse(1:igraph::vcount(g) %in% cutpoint_ids, "#FF0000", "#CCCCCC")
    vis_data$nodes$size <- input$node_size
    
    # Highlight bridges
    bridge_edges <- rv$bridges_result
    edge_ids <- igraph::get.edge.ids(g, t(igraph::as_edgelist(g)))
    vis_data$edges$color <- ifelse(edge_ids %in% bridge_edges, "#FF0000", "#000000")
    vis_data$edges$width <- ifelse(edge_ids %in% bridge_edges, 3, 1)
    
    visNetwork(vis_data$nodes, vis_data$edges) %>%
      visOptions(highlightNearest = TRUE) %>%
      visInteraction(navigationButtons = TRUE)
  })
  
  output$bridges_table <- renderDT({
    req(rv$igraph, rv$bridges_result)
    
    g <- ensure_igraph(rv$igraph)
    bridges_ids <- rv$bridges_result
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
    req(rv$igraph, rv$cutpoints_result)
    
    g <- ensure_igraph(rv$igraph)
    cutpoint_ids <- rv$cutpoints_result
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
  
  # ============================================================
  # NETWORK REACHABILITY
  # ============================================================
  
  output$reachability_node_select <- renderUI({
    req(rv$igraph)
    g <- ensure_igraph(rv$igraph)
    node_names <- igraph::V(g)$name %||% as.character(1:igraph::vcount(g))
    selectInput("reachability_node", "Select Source Node:", choices = node_names)
  })
  
  observeEvent(input$analyze_reachability, {
    req(rv$igraph, input$reachability_node)
    
    g <- ensure_igraph(rv$igraph)
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
    req(rv$igraph, rv$reachability_result)
    
    g <- ensure_igraph(rv$igraph)
    dist <- rv$reachability_result$distances
    source_id <- rv$reachability_result$source_id
    
    vis_data <- igraph_to_visNetwork(g, input$layout)
    
    # Color by reachability
    reachable <- is.finite(dist) & dist > 0
    vis_data$nodes$color <- ifelse(1:igraph::vcount(g) == source_id, "#FF0000",
                                    ifelse(reachable, "#00CC00", "#CCCCCC"))
    vis_data$nodes$size <- input$node_size
    
    visNetwork(vis_data$nodes, vis_data$edges) %>%
      visOptions(highlightNearest = TRUE) %>%
      visInteraction(navigationButtons = TRUE)
  })
}