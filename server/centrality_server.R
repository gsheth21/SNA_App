centrality_server <- function(input, output, session, rv) {
  
  # ============================================================
  # DEGREE CENTRALITY
  # ============================================================
  
  observeEvent(input$calc_degree, {
    req(rv$igraph)
    g <- ensure_igraph(rv$igraph)
    
    if (input$degree_type == "normalized") {
      degree_scores <- igraph::degree(g, normalized = TRUE)
    } else {
      degree_scores <- igraph::degree(g)
    }
    
    rv$centrality_results$degree <- degree_scores
  })
  
  output$degree_top5 <- renderUI({
    req(rv$centrality_results$degree)
    
    scores <- rv$centrality_results$degree
    node_names <- V(rv$igraph)$name %||% as.character(1:vcount(rv$igraph))
    
    top5_idx <- order(scores, decreasing = TRUE)[1:min(5, length(scores))]
    top5_names <- node_names[top5_idx]
    top5_scores <- round(scores[top5_idx], 3)
    
    items <- paste0(1:length(top5_names), ". ", top5_names, " (", top5_scores, ")")
    
    tags$ol(
      lapply(items, function(x) tags$li(x))
    )
  })
  
  output$degree_centralization <- renderUI({
    req(rv$centrality_results$degree)
    
    cent <- centr_degree(rv$igraph)$centralization
    
    tagList(
      tags$ul(
        tags$li(strong("Centralization Score: "), round(cent, 3))
      ),
      p("Interpretation: Higher scores indicate the network is more centralized around a few key nodes.")
    )
  })
  
  output$degree_plot <- renderVisNetwork({
    req(rv$centrality_results$degree)
    req(rv$igraph)
    
    g <- rv$igraph
    scores <- rv$centrality_results$degree
    
    vis_data <- igraph_to_visNetwork(g, input$layout)
    vis_data$nodes$value <- scores * 10
    vis_data$nodes$title <- paste("Degree:", round(scores, 3))
    vis_data$nodes$color <- list(background = "#CC0000", border = "#990000")
    
    visNetwork(vis_data$nodes, vis_data$edges) %>%
      visOptions(highlightNearest = TRUE) %>%
      visInteraction(navigationButtons = TRUE)
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
    
    if (input$closeness_type == "normalized") {
      closeness_scores <- igraph::closeness(g, normalized = TRUE)
    } else {
      closeness_scores <- igraph::closeness(g)
    }
    
    rv$centrality_results$closeness <- closeness_scores
  })
  
  output$closeness_top5 <- renderUI({
    req(rv$centrality_results$closeness)
    
    scores <- rv$centrality_results$closeness
    node_names <- V(rv$igraph)$name %||% as.character(1:vcount(rv$igraph))
    
    top5_idx <- order(scores, decreasing = TRUE)[1:min(5, length(scores))]
    top5_names <- node_names[top5_idx]
    top5_scores <- round(scores[top5_idx], 3)
    
    items <- paste0(1:length(top5_names), ". ", top5_names, " (", top5_scores, ")")
    
    tags$ol(
      lapply(items, function(x) tags$li(x))
    )
  })
  
  output$closeness_stats <- renderUI({
    req(rv$centrality_results$closeness)
    
    scores <- rv$centrality_results$closeness
    
    tagList(
      tags$ul(
        tags$li(strong("Mean: "), round(mean(scores, na.rm = TRUE), 3)),
        tags$li(strong("Median: "), round(median(scores, na.rm = TRUE), 3)),
        tags$li(strong("Min: "), round(min(scores, na.rm = TRUE), 3)),
        tags$li(strong("Max: "), round(max(scores, na.rm = TRUE), 3))
      )
    )
  })
  
  output$closeness_plot <- renderVisNetwork({
    req(rv$centrality_results$closeness)
    req(rv$igraph)
    
    g <- rv$igraph
    scores <- rv$centrality_results$closeness
    scores[is.na(scores)] <- 0
    
    vis_data <- igraph_to_visNetwork(g, input$layout)
    vis_data$nodes$value <- (scores / max(scores)) * 20
    vis_data$nodes$title <- paste("Closeness:", round(scores, 3))
    vis_data$nodes$color <- list(background = "#000000", border = "#CC0000")
    
    visNetwork(vis_data$nodes, vis_data$edges) %>%
      visOptions(highlightNearest = TRUE) %>%
      visInteraction(navigationButtons = TRUE)
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
    
    if (input$betweenness_type == "normalized") {
      between_scores <- igraph::betweenness(g, normalized = TRUE)
    } else {
      between_scores <- igraph::betweenness(g)
    }
    
    rv$centrality_results$betweenness <- between_scores
  })
  
  output$betweenness_top5 <- renderUI({
    req(rv$centrality_results$betweenness)
    
    scores <- rv$centrality_results$betweenness
    node_names <- V(rv$igraph)$name %||% as.character(1:vcount(rv$igraph))
    
    top5_idx <- order(scores, decreasing = TRUE)[1:min(5, length(scores))]
    top5_names <- node_names[top5_idx]
    top5_scores <- round(scores[top5_idx], 3)
    
    items <- paste0(1:length(top5_names), ". ", top5_names, " (", top5_scores, ")")
    
    tags$ol(
      lapply(items, function(x) tags$li(x))
    )
  })
  
  output$betweenness_stats <- renderUI({
    req(rv$centrality_results$betweenness)
    
    scores <- rv$centrality_results$betweenness
    
    tagList(
      tags$ul(
        tags$li(strong("Mean: "), round(mean(scores), 3)),
        tags$li(strong("Median: "), round(median(scores), 3)),
        tags$li(strong("Min: "), round(min(scores), 3)),
        tags$li(strong("Max: "), round(max(scores), 3))
      )
    )
  })
  
  output$betweenness_plot <- renderVisNetwork({
    req(rv$centrality_results$betweenness)
    req(rv$igraph)
    
    g <- rv$igraph
    scores <- rv$centrality_results$betweenness
    
    vis_data <- igraph_to_visNetwork(g, input$layout)
    vis_data$nodes$value <- (scores / max(scores)) * 20
    vis_data$nodes$title <- paste("Betweenness:", round(scores, 3))
    vis_data$nodes$color <- list(background = "#FF3333", border = "#990000")
    
    visNetwork(vis_data$nodes, vis_data$edges) %>%
      visOptions(highlightNearest = TRUE) %>%
      visInteraction(navigationButtons = TRUE)
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
    
    eigen_res <- igraph::eigen_centrality(g)
    rv$centrality_results$eigenvector <- eigen_res$vector
  })
  
  output$eigenvector_top5 <- renderUI({
    req(rv$centrality_results$eigenvector)
    
    scores <- rv$centrality_results$eigenvector
    node_names <- V(rv$igraph)$name %||% as.character(1:vcount(rv$igraph))
    
    top5_idx <- order(scores, decreasing = TRUE)[1:min(5, length(scores))]
    top5_names <- node_names[top5_idx]
    top5_scores <- round(scores[top5_idx], 3)
    
    items <- paste0(1:length(top5_names), ". ", top5_names, " (", top5_scores, ")")
    
    tags$ol(
      lapply(items, function(x) tags$li(x))
    )
  })
  
  output$eigenvector_stats <- renderUI({
    req(rv$centrality_results$eigenvector)
    
    scores <- rv$centrality_results$eigenvector
    
    tagList(
      tags$ul(
        tags$li(strong("Mean: "), round(mean(scores), 3)),
        tags$li(strong("Median: "), round(median(scores), 3)),
        tags$li(strong("Min: "), round(min(scores), 3)),
        tags$li(strong("Max: "), round(max(scores), 3))
      )
    )
  })
  
  output$eigenvector_plot <- renderVisNetwork({
    req(rv$centrality_results$eigenvector)
    req(rv$igraph)
    
    g <- rv$igraph
    scores <- rv$centrality_results$eigenvector
    
    vis_data <- igraph_to_visNetwork(g, input$layout)
    vis_data$nodes$value <- (scores / max(scores)) * 20
    vis_data$nodes$title <- paste("Eigenvector:", round(scores, 3))
    vis_data$nodes$color <- list(background = "#777777", border = "#CC0000")
    
    visNetwork(vis_data$nodes, vis_data$edges) %>%
      visOptions(highlightNearest = TRUE) %>%
      visInteraction(navigationButtons = TRUE)
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
    
    # Calculate all measures
    degree_scores <- degree(g, normalized = TRUE)
    closeness_scores <- closeness(g, normalized = TRUE)
    closeness_scores[is.na(closeness_scores)] <- 0
    betweenness_scores <- betweenness(g, normalized = TRUE)
    eigen_res <- eigen_centrality(g)
    eigenvector_scores <- eigen_res$vector
    
    rv$centrality_results$degree <- degree_scores
    rv$centrality_results$closeness <- closeness_scores
    rv$centrality_results$betweenness <- betweenness_scores
    rv$centrality_results$eigenvector <- eigenvector_scores
  })
  
  output$centrality_comparison_table <- renderDT({
    req(rv$centrality_results$degree, rv$centrality_results$closeness,
        rv$centrality_results$betweenness, rv$centrality_results$eigenvector)
    
    node_names <- V(rv$igraph)$name %||% as.character(1:vcount(rv$igraph))
    
    df <- data.frame(
      Node = node_names,
      Degree = round(rv$centrality_results$degree, 3),
      Closeness = round(rv$centrality_results$closeness, 3),
      Betweenness = round(rv$centrality_results$betweenness, 3),
      Eigenvector = round(rv$centrality_results$eigenvector, 3)
    )
    
    datatable(df, options = list(pageLength = 10, scrollX = TRUE))
  })
  
  output$centrality_correlation_heatmap <- renderPlotly({
    req(rv$centrality_results$degree, rv$centrality_results$closeness,
        rv$centrality_results$betweenness, rv$centrality_results$eigenvector)
    
    corr_mat <- cor(cbind(
      Degree = rv$centrality_results$degree,
      Closeness = rv$centrality_results$closeness,
      Betweenness = rv$centrality_results$betweenness,
      Eigenvector = rv$centrality_results$eigenvector
    ), use = "complete.obs")
    
    plot_ly(
      x = colnames(corr_mat),
      y = rownames(corr_mat),
      z = corr_mat,
      type = "heatmap",
      colorscale = "RdBu",
      zmid = 0,
      zmin = -1,
      zmax = 1
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
    
    # Get top 5 nodes
    degree_scores <- rv$centrality_results$degree
    top_indices <- order(degree_scores, decreasing = TRUE)[1:min(5, length(degree_scores))]
    node_names <- (V(rv$igraph)$name %||% as.character(1:vcount(rv$igraph)))[top_indices]
    
    # Normalize all metrics to 0-1 scale for comparison
    norm_degree <- rv$centrality_results$degree[top_indices] / max(rv$centrality_results$degree)
    norm_closeness <- rv$centrality_results$closeness[top_indices] / max(rv$centrality_results$closeness)
    norm_betweenness <- rv$centrality_results$betweenness[top_indices] / max(rv$centrality_results$betweenness)
    norm_eigenvector <- rv$centrality_results$eigenvector[top_indices] / max(rv$centrality_results$eigenvector)
    
    # Create a simple subplot visualization
    plot_ly() %>%
      add_trace(
        x = c("Degree", "Closeness", "Betweenness", "Eigenvector"),
        y = c(norm_degree[1], norm_closeness[1], norm_betweenness[1], norm_eigenvector[1]),
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