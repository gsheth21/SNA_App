centrality_server <- function(input, output, session, rv) {

  # ============================================================
  # DEGREE CENTRALITY
  # ============================================================

  observeEvent(input$calc_degree, {
    shinyjs::show("degree_results")
    req(rv$igraph)
    g <- ensure_igraph(rv$igraph)

    degree_scores <- igraph::degree(g, normalized = input$degree_type == "normalized")
    rv$centrality_results$degree <- degree_scores
  })

  output$degree_top5 <- renderUI({
    req(rv$centrality_results$degree)

    scores     <- rv$centrality_results$degree
    node_names <- igraph::V(rv$igraph)$name %||% as.character(seq_len(igraph::vcount(rv$igraph)))

    top5_idx    <- order(scores, decreasing = TRUE)[seq_len(min(5, length(scores)))]
    top5_names  <- node_names[top5_idx]
    top5_scores <- round(scores[top5_idx], 3)

    items <- paste0(seq_along(top5_names), ". ", top5_names, " (", top5_scores, ")")
    tags$ol(lapply(items, function(x) tags$li(x)))
  })

  output$degree_centralization <- renderUI({
    req(rv$centrality_results$degree)

    cent <- igraph::centr_degree(rv$igraph)$centralization

    tagList(
      tags$ul(
        tags$li(strong("Centralization Score: "), round(cent, 3))
      ),
      p("Interpretation: Higher scores indicate the network is more centralized around a few key nodes.")
    )
  })

  output$degree_plot <- renderVisNetwork({
    req(rv$centrality_results$degree, rv$igraph)

    g      <- rv$igraph
    scores <- rv$centrality_results$degree

    vis_data <- igraph_to_visNetwork(g, input$layout)
    vis_data <- apply_layer_selection(vis_data, input$layer_selection)
    vis_data <- apply_node_styling(vis_data,
      node_color = input$node_color,
      node_shape = input$node_shape,
      node_size  = input$node_size,
      label_size = input$label_size
    )
    vis_data$nodes$value <- scales::rescale(scores, to = c(input$node_size * 0.4, input$node_size * 3))
    vis_data$nodes$title <- paste("Degree:", round(scores, 3))

    edge_result <- apply_edge_styling(vis_data, g,
      hide_arrows    = input$hide_arrows,
      edge_color     = input$edge_color,
      edge_width     = input$edge_width,
      edge_opacity   = input$edge_opacity,
      edge_style     = input$edge_style,
      curve_strength = input$curve_strength %||% 0.3
    )
    vis_data <- edge_result$vis_data

    visNetwork(vis_data$nodes, vis_data$edges) %>%
      visEdges(smooth = edge_result$smooth) %>%
      visPhysics(solver = "forceAtlas2Based",
                 forceAtlas2Based = list(gravitationalConstant = -50)) %>%
      visLayout(randomSeed = 42) %>%
      visInteraction(dragNodes = TRUE, dragView = TRUE,
                     zoomView = TRUE, navigationButtons = TRUE) %>%
      visOptions(highlightNearest = TRUE)
  })

  output$degree_dist <- renderPlotly({
    req(rv$centrality_results$degree)

    plot_ly(x = rv$centrality_results$degree, type = "histogram") %>%
      layout(
        title = "Degree Centrality Distribution",
        xaxis = list(title = "Degree Centrality"),
        yaxis = list(title = "Frequency")
      )
  })

  # ============================================================
  # CLOSENESS CENTRALITY
  # ============================================================

  observeEvent(input$calc_closeness, {
    req(rv$igraph)
    g <- ensure_igraph(rv$igraph)

    closeness_scores <- igraph::closeness(g, normalized = input$closeness_type == "normalized")
    rv$centrality_results$closeness <- closeness_scores
  })

  output$closeness_top5 <- renderUI({
    req(rv$centrality_results$closeness)

    scores     <- rv$centrality_results$closeness
    node_names <- igraph::V(rv$igraph)$name %||% as.character(seq_len(igraph::vcount(rv$igraph)))

    top5_idx    <- order(scores, decreasing = TRUE)[seq_len(min(5, length(scores)))]
    top5_names  <- node_names[top5_idx]
    top5_scores <- round(scores[top5_idx], 3)

    items <- paste0(seq_along(top5_names), ". ", top5_names, " (", top5_scores, ")")
    tags$ol(lapply(items, function(x) tags$li(x)))
  })

  output$closeness_stats <- renderUI({
    req(rv$centrality_results$closeness)

    scores <- rv$centrality_results$closeness

    tagList(
      tags$ul(
        tags$li(strong("Mean: "),   round(mean(scores,   na.rm = TRUE), 3)),
        tags$li(strong("Median: "), round(median(scores, na.rm = TRUE), 3)),
        tags$li(strong("Min: "),    round(min(scores,    na.rm = TRUE), 3)),
        tags$li(strong("Max: "),    round(max(scores,    na.rm = TRUE), 3))
      )
    )
  })

  output$closeness_plot <- renderVisNetwork({
    req(rv$centrality_results$closeness, rv$igraph)

    g      <- rv$igraph
    scores <- rv$centrality_results$closeness
    scores[is.na(scores)] <- 0

    vis_data <- igraph_to_visNetwork(g, input$layout)
    vis_data <- apply_layer_selection(vis_data, input$layer_selection)
    vis_data <- apply_node_styling(vis_data,
      node_color = input$node_color,
      node_shape = input$node_shape,
      node_size  = input$node_size,
      label_size = input$label_size
    )
    vis_data$nodes$value <- scales::rescale(scores, to = c(input$node_size * 0.4, input$node_size * 3))
    vis_data$nodes$title <- paste("Closeness:", round(scores, 3))

    edge_result <- apply_edge_styling(vis_data, g,
      hide_arrows    = input$hide_arrows,
      edge_color     = input$edge_color,
      edge_width     = input$edge_width,
      edge_opacity   = input$edge_opacity,
      edge_style     = input$edge_style,
      curve_strength = input$curve_strength %||% 0.3
    )
    vis_data <- edge_result$vis_data

    visNetwork(vis_data$nodes, vis_data$edges) %>%
      visEdges(smooth = edge_result$smooth) %>%
      visPhysics(solver = "forceAtlas2Based",
                 forceAtlas2Based = list(gravitationalConstant = -50)) %>%
      visLayout(randomSeed = 42) %>%
      visInteraction(dragNodes = TRUE, dragView = TRUE,
                     zoomView = TRUE, navigationButtons = TRUE) %>%
      visOptions(highlightNearest = TRUE)
  })

  output$closeness_dist <- renderPlotly({
    req(rv$centrality_results$closeness)

    plot_ly(x = rv$centrality_results$closeness, type = "histogram") %>%
      layout(
        title = "Closeness Centrality Distribution",
        xaxis = list(title = "Closeness Centrality"),
        yaxis = list(title = "Frequency")
      )
  })

  # ============================================================
  # BETWEENNESS CENTRALITY
  # ============================================================

  observeEvent(input$calc_betweenness, {
    req(rv$igraph)
    g <- ensure_igraph(rv$igraph)

    between_scores <- igraph::betweenness(g, normalized = input$betweenness_type == "normalized")
    rv$centrality_results$betweenness <- between_scores
  })

  output$betweenness_top5 <- renderUI({
    req(rv$centrality_results$betweenness)

    scores     <- rv$centrality_results$betweenness
    node_names <- igraph::V(rv$igraph)$name %||% as.character(seq_len(igraph::vcount(rv$igraph)))

    top5_idx    <- order(scores, decreasing = TRUE)[seq_len(min(5, length(scores)))]
    top5_names  <- node_names[top5_idx]
    top5_scores <- round(scores[top5_idx], 3)

    items <- paste0(seq_along(top5_names), ". ", top5_names, " (", top5_scores, ")")
    tags$ol(lapply(items, function(x) tags$li(x)))
  })

  output$betweenness_stats <- renderUI({
    req(rv$centrality_results$betweenness)

    scores <- rv$centrality_results$betweenness

    tagList(
      tags$ul(
        tags$li(strong("Mean: "),   round(mean(scores),   3)),
        tags$li(strong("Median: "), round(median(scores), 3)),
        tags$li(strong("Min: "),    round(min(scores),    3)),
        tags$li(strong("Max: "),    round(max(scores),    3))
      )
    )
  })

  output$betweenness_plot <- renderVisNetwork({
    req(rv$centrality_results$betweenness, rv$igraph)

    g      <- rv$igraph
    scores <- rv$centrality_results$betweenness

    vis_data <- igraph_to_visNetwork(g, input$layout)
    vis_data <- apply_layer_selection(vis_data, input$layer_selection)
    vis_data <- apply_node_styling(vis_data,
      node_color = input$node_color,
      node_shape = input$node_shape,
      node_size  = input$node_size,
      label_size = input$label_size
    )
    vis_data$nodes$value <- scales::rescale(scores, to = c(input$node_size * 0.4, input$node_size * 3))
    vis_data$nodes$title <- paste("Betweenness:", round(scores, 3))

    edge_result <- apply_edge_styling(vis_data, g,
      hide_arrows    = input$hide_arrows,
      edge_color     = input$edge_color,
      edge_width     = input$edge_width,
      edge_opacity   = input$edge_opacity,
      edge_style     = input$edge_style,
      curve_strength = input$curve_strength %||% 0.3
    )
    vis_data <- edge_result$vis_data

    visNetwork(vis_data$nodes, vis_data$edges) %>%
      visEdges(smooth = edge_result$smooth) %>%
      visPhysics(solver = "forceAtlas2Based",
                 forceAtlas2Based = list(gravitationalConstant = -50)) %>%
      visLayout(randomSeed = 42) %>%
      visInteraction(dragNodes = TRUE, dragView = TRUE,
                     zoomView = TRUE, navigationButtons = TRUE) %>%
      visOptions(highlightNearest = TRUE)
  })

  output$betweenness_dist <- renderPlotly({
    req(rv$centrality_results$betweenness)

    plot_ly(x = rv$centrality_results$betweenness, type = "histogram") %>%
      layout(
        title = "Betweenness Centrality Distribution",
        xaxis = list(title = "Betweenness Centrality"),
        yaxis = list(title = "Frequency")
      )
  })

  # ============================================================
  # EIGENVECTOR CENTRALITY
  # ============================================================

  observeEvent(input$calc_eigenvector, {
    req(rv$igraph)
    g <- ensure_igraph(rv$igraph)

    rv$centrality_results$eigenvector <- igraph::eigen_centrality(g)$vector
  })

  output$eigenvector_top5 <- renderUI({
    req(rv$centrality_results$eigenvector)

    scores     <- rv$centrality_results$eigenvector
    node_names <- igraph::V(rv$igraph)$name %||% as.character(seq_len(igraph::vcount(rv$igraph)))

    top5_idx    <- order(scores, decreasing = TRUE)[seq_len(min(5, length(scores)))]
    top5_names  <- node_names[top5_idx]
    top5_scores <- round(scores[top5_idx], 3)

    items <- paste0(seq_along(top5_names), ". ", top5_names, " (", top5_scores, ")")
    tags$ol(lapply(items, function(x) tags$li(x)))
  })

  output$eigenvector_stats <- renderUI({
    req(rv$centrality_results$eigenvector)

    scores <- rv$centrality_results$eigenvector

    tagList(
      tags$ul(
        tags$li(strong("Mean: "),   round(mean(scores),   3)),
        tags$li(strong("Median: "), round(median(scores), 3)),
        tags$li(strong("Min: "),    round(min(scores),    3)),
        tags$li(strong("Max: "),    round(max(scores),    3))
      )
    )
  })

  output$eigenvector_plot <- renderVisNetwork({
    req(rv$centrality_results$eigenvector, rv$igraph)

    g      <- rv$igraph
    scores <- rv$centrality_results$eigenvector

    vis_data <- igraph_to_visNetwork(g, input$layout)
    vis_data <- apply_layer_selection(vis_data, input$layer_selection)
    vis_data <- apply_node_styling(vis_data,
      node_color = input$node_color,
      node_shape = input$node_shape,
      node_size  = input$node_size,
      label_size = input$label_size
    )
    vis_data$nodes$value <- scales::rescale(scores, to = c(input$node_size * 0.4, input$node_size * 3))
    vis_data$nodes$title <- paste("Eigenvector:", round(scores, 3))

    edge_result <- apply_edge_styling(vis_data, g,
      hide_arrows    = input$hide_arrows,
      edge_color     = input$edge_color,
      edge_width     = input$edge_width,
      edge_opacity   = input$edge_opacity,
      edge_style     = input$edge_style,
      curve_strength = input$curve_strength %||% 0.3
    )
    vis_data <- edge_result$vis_data

    visNetwork(vis_data$nodes, vis_data$edges) %>%
      visEdges(smooth = edge_result$smooth) %>%
      visPhysics(solver = "forceAtlas2Based",
                 forceAtlas2Based = list(gravitationalConstant = -50)) %>%
      visLayout(randomSeed = 42) %>%
      visInteraction(dragNodes = TRUE, dragView = TRUE,
                     zoomView = TRUE, navigationButtons = TRUE) %>%
      visOptions(highlightNearest = TRUE)
  })

  output$eigenvector_dist <- renderPlotly({
    req(rv$centrality_results$eigenvector)

    plot_ly(x = rv$centrality_results$eigenvector, type = "histogram") %>%
      layout(
        title = "Eigenvector Centrality Distribution",
        xaxis = list(title = "Eigenvector Centrality"),
        yaxis = list(title = "Frequency")
      )
  })

  # ============================================================
  # COMPARE ALL CENTRALITY MEASURES
  # ============================================================

  observeEvent(input$compare_all_centrality, {
    req(rv$igraph)
    g <- rv$igraph

    closeness_scores <- igraph::closeness(g, normalized = TRUE)
    closeness_scores[is.na(closeness_scores)] <- 0

    rv$centrality_results$degree      <- igraph::degree(g, normalized = TRUE)
    rv$centrality_results$closeness   <- closeness_scores
    rv$centrality_results$betweenness <- igraph::betweenness(g, normalized = TRUE)
    rv$centrality_results$eigenvector <- igraph::eigen_centrality(g)$vector
  })

  output$centrality_comparison_table <- renderDT({
    req(rv$centrality_results$degree, rv$centrality_results$closeness,
        rv$centrality_results$betweenness, rv$centrality_results$eigenvector)

    node_names <- igraph::V(rv$igraph)$name %||% as.character(seq_len(igraph::vcount(rv$igraph)))

    df <- data.frame(
      Node        = node_names,
      Degree      = round(rv$centrality_results$degree,      3),
      Closeness   = round(rv$centrality_results$closeness,   3),
      Betweenness = round(rv$centrality_results$betweenness, 3),
      Eigenvector = round(rv$centrality_results$eigenvector, 3)
    )

    datatable(df, options = list(pageLength = 10, scrollX = TRUE))
  })

  output$centrality_correlation_heatmap <- renderPlotly({
    req(rv$centrality_results$degree, rv$centrality_results$closeness,
        rv$centrality_results$betweenness, rv$centrality_results$eigenvector)

    corr_mat <- cor(cbind(
      Degree      = rv$centrality_results$degree,
      Closeness   = rv$centrality_results$closeness,
      Betweenness = rv$centrality_results$betweenness,
      Eigenvector = rv$centrality_results$eigenvector
    ), use = "complete.obs")

    plot_ly(
      x = colnames(corr_mat),
      y = rownames(corr_mat),
      z = corr_mat,
      type = "heatmap",
      colorscale = "RdBu",
      zmid = 0, zmin = -1, zmax = 1
    ) %>%
      layout(
        title = "Correlation Between Centrality Measures",
        xaxis = list(title = ""),
        yaxis = list(title = "")
      )
  })

  output$centrality_radar <- renderPlotly({
    req(rv$centrality_results$degree, rv$centrality_results$closeness,
        rv$centrality_results$betweenness, rv$centrality_results$eigenvector)

    degree_scores <- rv$centrality_results$degree
    top_indices   <- order(degree_scores, decreasing = TRUE)[seq_len(min(5, length(degree_scores)))]
    node_names    <- (igraph::V(rv$igraph)$name %||%
                      as.character(seq_len(igraph::vcount(rv$igraph))))[top_indices]

    norm <- function(x, idx) x[idx] / max(x)
    norm_degree      <- norm(rv$centrality_results$degree,      top_indices)
    norm_closeness   <- norm(rv$centrality_results$closeness,   top_indices)
    norm_betweenness <- norm(rv$centrality_results$betweenness, top_indices)
    norm_eigenvector <- norm(rv$centrality_results$eigenvector, top_indices)

    plot_ly() %>%
      add_trace(
        x    = c("Degree", "Closeness", "Betweenness", "Eigenvector"),
        y    = c(norm_degree[1], norm_closeness[1], norm_betweenness[1], norm_eigenvector[1]),
        type = "bar",
        name = node_names[1]
      ) %>%
      layout(
        title = "Top 5 Nodes: Normalized Centrality Comparison",
        xaxis = list(title = "Centrality Measure"),
        yaxis = list(title = "Normalized Score (0-1)")
      )
  })
}