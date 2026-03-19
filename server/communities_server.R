communities_server <- function(input, output, session, rv) {
  
  # ============================================================
  # COMMUNITY DETECTION
  # ============================================================
  
  observeEvent(input$detect_communities, {
    req(rv$igraph)
    g <- ensure_igraph(rv$igraph)
    
    communities <- switch(input$community_algorithm,
      "fastgreedy" = igraph::cluster_fast_greedy(igraph::as.undirected(g)),
      "louvain" = igraph::cluster_louvain(g),
      "walktrap" = igraph::cluster_walktrap(g),
      "edge_betweenness" = igraph::cluster_edge_betweenness(g),
      "label_prop" = igraph::cluster_label_prop(g),
      igraph::cluster_louvain(g)
    )
    
    rv$community_results <- communities
  })
  
  output$community_stats <- renderUI({
    req(rv$community_results)
    
    n_comm <- length(rv$community_results)
    sizes <- sizes(rv$community_results)
    modularity_score <- modularity(rv$community_results)
    
    tagList(
      tags$ul(
        tags$li(strong("Number of Communities: "), n_comm),
        tags$li(strong("Modularity Score: "), round(modularity_score, 3)),
        tags$li(strong("Community Sizes: "), paste(sizes, collapse = ", ")),
        tags$li(strong("Largest Community: "), max(sizes), " nodes"),
        tags$li(strong("Smallest Community: "), min(sizes), " node(s)")
      )
    )
  })
  
  output$community_size_dist <- renderPlotly({
    req(rv$community_results)
    
    sizes <- sizes(rv$community_results)
    
    plot_ly(x = 1:length(sizes), y = sizes, type = "bar") %>%
      layout(
        title = "Community Size Distribution",
        xaxis = list(title = "Community ID"),
        yaxis = list(title = "Size (Number of Nodes)")
      )
  })
  
  output$community_plot <- renderVisNetwork({
    req(rv$community_results)
    req(rv$igraph)
    
    g <- rv$igraph
    membership <- membership(rv$community_results)
    
    vis_data <- igraph_to_visNetwork(g, input$layout)
    
    colors <- rainbow(max(membership))
    vis_data$nodes$color <- colors[membership]
    vis_data$nodes$group <- membership
    vis_data$nodes$size <- input$node_size
    
    visNetwork(vis_data$nodes, vis_data$edges) %>%
      visOptions(highlightNearest = TRUE) %>%
      visInteraction(navigationButtons = TRUE)
  })
  
  output$community_membership_table <- renderDT({
    req(rv$community_results)
    
    membership <- membership(rv$community_results)
    node_names <- V(rv$igraph)$name %||% as.character(1:vcount(rv$igraph))
    
    df <- data.frame(
      Node = node_names,
      Community = membership
    )
    
    df <- df[order(df$Community), ]
    
    datatable(df, options = list(pageLength = 10, scrollX = TRUE))
  })
  
  # ============================================================
  # CLIQUE ANALYSIS
  # ============================================================
  
  observeEvent(input$find_cliques, {
    req(rv$igraph, input$min_clique_size)
    g <- ensure_igraph(rv$igraph)
    g <- igraph::as.undirected(g)
    
    min_size <- input$min_clique_size
    largest_clique_size <- igraph::clique_num(g)

    if (min_size > largest_clique_size) {
      rv$clique_warning <- paste0(
        "Note: Minimum clique size (", min_size, ") exceeds the largest clique in this network (",
        largest_clique_size, " nodes). Showing results for size ", largest_clique_size, " instead."
      )
      min_size <- largest_clique_size
    } else {
      rv$clique_warning <- NULL
    }
    
    # Find all maximal cliques
    all_cliques <- igraph::max_cliques(g, min = min_size)
    
    rv$cliques <- all_cliques
  })

  output$clique_size_warning <- renderUI({
    req(rv$clique_warning)
    tags$p(rv$clique_warning, style = "color: red; margin-top: 8px;")
  })
  
  output$clique_stats <- renderUI({
    req(rv$cliques)
    
    n_cliques <- length(rv$cliques)
    sizes <- sapply(rv$cliques, length)
    
    tagList(
      tags$ul(
        tags$li(strong("Number of Cliques: "), n_cliques),
        tags$li(strong("Largest Clique: "), max(sizes), " nodes"),
        tags$li(strong("Average Size: "), round(mean(sizes), 2), " nodes"),
        tags$li(strong("Smallest Clique: "), min(sizes), " nodes")
      )
    )
  })
  
  output$clique_size_dist <- renderPlotly({
    req(rv$cliques)
    
    sizes <- sapply(rv$cliques, length)
    
    plot_ly(x = sizes, type = "histogram") %>%
      layout(
        title = "Clique Size Distribution",
        xaxis = list(title = "Clique Size"),
        yaxis = list(title = "Frequency")
      )
  })
  
  output$cliques_table <- renderDT({
    req(rv$cliques)
    
    node_names <- V(rv$igraph)$name %||% as.character(1:vcount(rv$igraph))
    
    clique_list <- lapply(1:min(10, length(rv$cliques)), function(i) {
      clique <- rv$cliques[[i]]
      clique_nodes <- node_names[clique]
      data.frame(
        Clique_ID = i,
        Size = length(clique),
        Nodes = paste(clique_nodes, collapse = ", ")
      )
    })
    
    df <- do.call(rbind, clique_list)
    
    datatable(df, options = list(pageLength = 10, scrollX = TRUE))
  })
  
  output$cliques_plot <- renderVisNetwork({
    req(rv$cliques)
    req(rv$igraph)
    
    g <- rv$igraph
    vis_data <- igraph_to_visNetwork(g, input$layout)
    
    # Color nodes in largest clique differently
    if (length(rv$cliques) > 0) {
      largest_clique <- rv$cliques[[which.max(sapply(rv$cliques, length))]]
      clique_color <- ifelse(1:vcount(g) %in% largest_clique, "#CC0000", "#CCCCCC")
    } else {
      clique_color <- "#CCCCCC"
    }
    
    vis_data$nodes$color <- clique_color
    vis_data$nodes$size <- input$node_size
    
    visNetwork(vis_data$nodes, vis_data$edges) %>%
      visOptions(highlightNearest = TRUE) %>%
      visInteraction(navigationButtons = TRUE)
  })
  
  # ============================================================
  # K-CORE DECOMPOSITION
  # ============================================================
  
  observeEvent(input$compute_kcores, {
    req(rv$igraph)
    g <- ensure_igraph(rv$igraph)
    g <- igraph::as.undirected(g)
    
    # Calculate coreness (k-core level)
    coreness_vec <- igraph::coreness(g)
    
    rv$kcores <- coreness_vec
  })
  
  output$kcore_stats <- renderUI({
    req(rv$kcores)
    
    coreness_vec <- rv$kcores
    max_k <- max(coreness_vec)
    
    tagList(
      tags$ul(
        tags$li(strong("Maximum K-Core: "), max_k),
        tags$li(strong("Nodes in Core (k=", max_k, "): "), sum(coreness_vec == max_k)),
        tags$li(strong("Nodes in Periphery (k=1): "), sum(coreness_vec == 1)),
        tags$li(strong("Total Layers: "), max_k)
      )
    )
  })
  
  output$kcore_distribution <- renderPlotly({
    req(rv$kcores)
    
    coreness_vec <- rv$kcores
    dist_table <- table(coreness_vec)
    
    plot_ly(x = as.numeric(names(dist_table)), y = as.numeric(dist_table), type = "bar") %>%
      layout(
        title = "K-Core Layer Distribution",
        xaxis = list(title = "K-Core Level"),
        yaxis = list(title = "Number of Nodes")
      )
  })
  
  output$kcores_plot <- renderVisNetwork({
    req(rv$kcores)
    req(rv$igraph)
    
    g <- ensure_igraph(rv$igraph)
    g <- igraph::as.undirected(g)
    coreness_vec <- rv$kcores
    
    vis_data <- igraph_to_visNetwork(g, input$layout)
    
    # Color by k-core level
    max_k <- max(coreness_vec)
    colors <- colorRampPalette(c("#FF9999", "#CC0000", "#660000"))(max(max_k, 1))
    coreness_for_color <- pmax(coreness_vec, 1)
    vis_data$nodes$color <- colors[coreness_for_color]
    vis_data$nodes$size <- 5 + (coreness_for_color / max_k) * input$node_size
    
    visNetwork(vis_data$nodes, vis_data$edges) %>%
      visOptions(highlightNearest = TRUE) %>%
      visInteraction(navigationButtons = TRUE)
  })
  
  output$kcore_membership_table <- renderDT({
    req(rv$kcores)
    
    coreness_vec <- rv$kcores
    node_names <- V(rv$igraph)$name %||% as.character(1:vcount(rv$igraph))
    
    df <- data.frame(
      Node = node_names,
      KCore_Level = coreness_vec
    )
    
    df <- df[order(-df$KCore_Level, df$Node), ]
    
    datatable(df, options = list(pageLength = 10, scrollX = TRUE))
  })
  
  # ============================================================
  # MODULARITY ANALYSIS
  # ============================================================
  
  observeEvent(input$calculate_modularity, {
    req(rv$igraph)

    if (is.null(rv$community_results)) {
      g <- ensure_igraph(rv$igraph)
      rv$community_results <- igraph::cluster_louvain(g)
    }
    
    # Calculate modularity
    mod_score <- modularity(rv$community_results)
    
    # Calculate expected vs observed edges between communities
    rv$modularity_score <- mod_score
  })
  
  output$modularity_scores <- renderUI({
    req(rv$modularity_score)
    
    mod <- rv$modularity_score
    
    if (mod > 0.3) {
      quality <- "Excellent - Strong community structure"
    } else if (mod > 0.1) {
      quality <- "Good - Moderate community structure"
    } else if (mod > 0) {
      quality <- "Weak - Slight community structure"
    } else {
      quality <- "Poor - No meaningful community structure"
    }
    
    tagList(
      tags$ul(
        tags$li(strong("Modularity Score: "), round(mod, 4)),
        tags$li(strong("Quality Assessment: "), quality)
      )
    )
  })
  
  output$modularity_interpretation <- renderUI({
    req(rv$modularity_score)
    
    mod <- rv$modularity_score
    
    tagList(
      h5("Range: -1 to +1"),
      tags$ul(
        tags$li("0.3 - 0.4: Strong communities"),
        tags$li("0.1 - 0.3: Moderate communities"),
        tags$li("0.0 - 0.1: Weak communities"),
        tags$li("< 0: Worse than random")
      )
    )
  })
  
  output$modularity_gain_plot <- renderPlotly({
    req(rv$community_results)
    
    membership_vec <- membership(rv$community_results)
    n_comm <- length(rv$community_results)
    
    # Create plot of modularity contribution by community
    mod_by_comm <- sapply(1:n_comm, function(comm_id) {
      sum(membership_vec == comm_id)
    })
    
    plot_ly(x = 1:n_comm, y = mod_by_comm, type = "bar") %>%
      layout(
        title = "Modularity Contribution by Community",
        xaxis = list(title = "Community ID"),
        yaxis = list(title = "Community Size")
      )
  })
}