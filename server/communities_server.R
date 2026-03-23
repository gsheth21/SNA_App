communities_server <- function(input, output, session, rv) {

  g <- reactive({
    req(rv$igraph)
    igraph::as.undirected(ensure_igraph(rv$igraph))
  })

  vis_base <- reactive({
    igraph_to_visNetwork(g(), input$layout)
  })
  
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
    colors <- rainbow(max(membership))
    
    vis_data <- vis_base()

    # 2. Layer selection
    vis_data <- apply_layer_selection(vis_data, input$layer_selection)

    # 3. Global node styling
    vis_data <- apply_node_styling(vis_data,
      node_color = input$node_color,
      node_shape = input$node_shape,
      node_size  = input$node_size,
      label_size = input$label_size
    )
    # Override base color with community colors
    vis_data$nodes$color.background <- colors[membership]
    vis_data$nodes$group            <- as.character(membership)

    # 4. Edge styling
    edge_result <- apply_edge_styling(vis_data, g(),
      hide_arrows    = input$hide_arrows,
      edge_color     = input$edge_color,
      edge_width     = input$edge_width,
      edge_opacity   = input$edge_opacity,
      edge_style     = input$edge_style,
      curve_strength = input$curve_strength %||% 0.3
    )
    vis_data <- edge_result$vis_data

    # 5. Weight style
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
    
    min_size <- input$min_clique_size
    largest_clique_size <- igraph::clique_num(g())

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
    all_cliques <- igraph::max_cliques(g(), min = min_size)
    
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
    
    df <- data.frame(
      Clique_ID = seq_along(rv$cliques),
      Size      = lengths(rv$cliques),
      Nodes     = sapply(rv$cliques, function(cl) paste(node_names[cl], collapse = ", "))
    )
    df <- df[order(-df$Size), ]
    
    datatable(df, options = list(pageLength = 10, scrollX = TRUE))
  })
  
  output$cliques_plot <- renderVisNetwork({
    req(rv$cliques)

    nodes_in_any_clique <- unique(unlist(rv$cliques))

    vis_data <- vis_base()

    # 2. Layer selection
    vis_data <- apply_layer_selection(vis_data, input$layer_selection)

    # 3. Global node styling
    vis_data <- apply_node_styling(vis_data,
      node_color = input$node_color,
      node_shape = input$node_shape,
      node_size  = input$node_size,
      label_size = input$label_size
    )

    # Highlight largest clique in NC State red; others in light gray
    in_clique <- seq_len(igraph::vcount(g())) %in% nodes_in_any_clique
    vis_data$nodes$color.background <- ifelse(in_clique, "#CC0000", "#CCCCCC")
    vis_data$nodes$color.border     <- ifelse(in_clique, "#990000", "#AAAAAA")

    # 4. Edge styling
    edge_result <- apply_edge_styling(vis_data, g(),
      hide_arrows    = input$hide_arrows,
      edge_color     = input$edge_color,
      edge_width     = input$edge_width,
      edge_opacity   = input$edge_opacity,
      edge_style     = input$edge_style,
      curve_strength = input$curve_strength %||% 0.3
    )
    vis_data <- edge_result$vis_data

    # 5. Weight style
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
  
  # ============================================================
  # K-CORE DECOMPOSITION
  # ============================================================

  kcores <- reactive({    
    igraph::coreness(g())
  })
  
  output$kcore_stats <- renderUI({
    coreness_vec <- kcores()
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
    coreness_vec <- kcores()
    dist_table <- table(coreness_vec)
    
    plot_ly(x = as.numeric(names(dist_table)), y = as.numeric(dist_table), type = "bar") %>%
      layout(
        title = "K-Core Layer Distribution",
        xaxis = list(title = "K-Core Level"),
        yaxis = list(title = "Number of Nodes")
      )
  })

  output$kcores_plot <- renderVisNetwork({
    coreness_vec <- kcores()
    max_k        <- max(coreness_vec)
    colors       <- colorRampPalette(c("#FF9999", "#CC0000", "#660000"))(max(max_k, 1))
    cor_clamped  <- pmax(coreness_vec, 1)
    
    vis_data <- vis_base()

    vis_data <- apply_layer_selection(vis_data, input$layer_selection)

    vis_data <- apply_node_styling(vis_data,
      node_color = input$node_color,
      node_shape = input$node_shape,
      node_size  = input$node_size,
      label_size = input$label_size
    )
    
    # Override color and size by coreness level
    vis_data$nodes$color.background <- colors[cor_clamped]
    vis_data$nodes$color.border     <- "#000000"
    vis_data$nodes$size             <- 5 + (cor_clamped / max_k) * input$node_size
   
    # 4. Edge styling
    edge_result <- apply_edge_styling(vis_data, g(),
      hide_arrows    = input$hide_arrows,
      edge_color     = input$edge_color,
      edge_width     = input$edge_width,
      edge_opacity   = input$edge_opacity,
      edge_style     = input$edge_style,
      curve_strength = input$curve_strength %||% 0.3
    )
    vis_data <- edge_result$vis_data

    # 5. Weight style
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
  
  output$kcore_membership_table <- renderDT({    
    coreness_vec <- kcores()
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
  
  modularity_score = reactive({
    req(rv$igraph)

    if (is.null(rv$community_results)) {
      g <- ensure_igraph(rv$igraph)
      rv$community_results <- igraph::cluster_louvain(g)
    }
    
    modularity(rv$community_results)
  })
  
  output$modularity_scores <- renderUI({
    mod <- modularity_score()
    
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
    mod <- modularity_score()
    
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