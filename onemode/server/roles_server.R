roles_server <- function(input, output, session, rv) {

  # ── Internal helpers ─────────────────────────────────────────────────────

  # Get adjacency matrix; optionally weighted
  get_adj <- function(g, use_weights = FALSE) {
    if (use_weights && igraph::is_weighted(g)) {
      adj <- as.matrix(igraph::as_adjacency_matrix(g, attr = "weight", sparse = FALSE))
    } else {
      adj <- as.matrix(igraph::as_adjacency_matrix(g, sparse = FALSE))
    }
    diag(adj) <- 0
    adj
  }

  build_profile_matrix <- function(adj, direction) {
    switch(direction,
      row      = adj,
      column   = t(adj),
      combined = cbind(adj, t(adj))
    )
  }

  compute_dist <- function(adj, method, direction = "combined") {
    profiles <- build_profile_matrix(adj, direction)
    if (method == "euclidean") {
      return(as.matrix(dist(profiles, method = "euclidean")))
    } else if (method == "correlation") {
      cor_mat  <- tryCatch(cor(t(profiles)), error = function(e) matrix(NA, nrow(profiles), nrow(profiles)))
      dist_mat <- 1 - cor_mat
      dist_mat[is.na(dist_mat)] <- 1
      diag(dist_mat) <- 0
      return(dist_mat)
    } else {  # hamming
      profiles_bin <- profiles != 0
      n <- nrow(profiles_bin)
      dist_mat <- matrix(0, n, n)
      for (i in seq_len(n))
        for (j in seq_len(n))
          dist_mat[i, j] <- sum(profiles_bin[i, ] != profiles_bin[j, ])
      return(dist_mat)
    }
  }

  # Metric profile for automorphic equivalence: one row per node
  compute_metric_profile <- function(g) {
    deg  <- igraph::degree(g)
    btw  <- igraph::betweenness(g, normalized = TRUE)
    clo  <- igraph::closeness(g, normalized = TRUE)
    clo[is.nan(clo) | is.infinite(clo)] <- 0
    ecc  <- tryCatch(igraph::eccentricity(g), error = function(e) rep(0, igraph::vcount(g)))
    cbind(deg, btw, clo, ecc)
  }

  # ── Tab 1: Equivalence Demo ──────────────────────────────────────────────

  # Reactive: compute groups via hclust on rv$igraph
  observeEvent(input$compute_equiv, {
    req(rv$igraph)
    g   <- ensure_igraph(rv$igraph)
    n   <- igraph::vcount(g)
    k   <- min(input$equiv_k, n - 1)

    if (input$equiv_type == "automorphic") {
      profiles <- compute_metric_profile(g)
      dist_mat <- as.matrix(dist(profiles, method = "euclidean"))
    } else {
      # structural and regular both use adjacency profiles; differ only in k (coarseness)
      adj      <- get_adj(g)
      dist_mat <- compute_dist(adj, "euclidean", "combined")
    }

    hc     <- hclust(as.dist(dist_mat), method = "complete")
    groups <- cutree(hc, k = k)
    rv$equiv_groups <- list(groups = groups, k = k)
  })

  output$equiv_explanation_ui <- renderUI({
    switch(input$equiv_type,
      structural = tagList(
        tags$b("Structural Equivalence (strictest)"),
        tags$ul(
          tags$li("Nodes have the exact same connections to the exact same neighbors."),
          tags$li("Local phenomenon — equivalent nodes are in close proximity."),
          tags$li("Results in the most groups — use a higher k.")
        )
      ),
      automorphic = tagList(
        tags$b("Automorphic Equivalence (intermediate)"),
        tags$ul(
          tags$li("Nodes have the same network metrics (degree, betweenness, closeness, eccentricity)."),
          tags$li("Connections can be to different neighbors — global phenomenon."),
          tags$li("Results in a moderate number of groups.")
        )
      ),
      regular = tagList(
        tags$b("Regular Equivalence (most relaxed)"),
        tags$ul(
          tags$li("Nodes have broadly similar roles — same type of connections, not necessarily identical metrics."),
          tags$li("Global phenomenon — reveals broad structural categories."),
          tags$li("Results in the fewest groups — use a lower k.")
        )
      )
    )
  })

  output$equiv_demo_plot <- renderVisNetwork({
    req(rv$igraph, rv$equiv_groups)
    g      <- rv$igraph
    groups <- rv$equiv_groups$groups
    k      <- rv$equiv_groups$k

    palette   <- RColorBrewer::brewer.pal(max(k, 3), "Set1")
    node_cols <- palette[groups]

    vis_data <- igraph_to_visNetwork(g, input$layout)
    vis_data <- apply_layer_selection(vis_data, input$layer_selection)
    vis_data <- apply_node_styling(vis_data,
      node_color = input$node_color,
      node_shape = input$node_shape,
      node_size  = input$node_size,
      label_size = input$label_size
    )
    vis_data$nodes$color.background <- node_cols
    vis_data$nodes$title            <- paste("Group:", groups)

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

  output$equiv_demo_ggraph <- renderPlot({
    req(rv$igraph, rv$equiv_groups)
    groups  <- rv$equiv_groups$groups
    k       <- rv$equiv_groups$k
    palette <- RColorBrewer::brewer.pal(max(k, 3), "Set1")
    fill_cols <- palette[groups]
    build_ggraph_plot(rv$igraph, input, node_fill_override = fill_cols)
  }, res = 110)

  output$equiv_group_table <- renderUI({
    req(rv$igraph, rv$equiv_groups)
    groups     <- rv$equiv_groups$groups
    k          <- rv$equiv_groups$k
    nms        <- igraph::V(rv$igraph)$name %||% as.character(seq_len(length(groups)))
    type_label <- switch(input$equiv_type,
      structural = "Structural", automorphic = "Automorphic", regular = "Regular")

    items <- lapply(seq_len(k), function(gid) {
      members <- nms[groups == gid]
      tags$li(tags$b(paste0("Group ", gid, " (n=", length(members), "): ")),
              paste(members, collapse = ", "))
    })

    tagList(
      tags$p("Role groups under ", tags$b(type_label), " Equivalence:"),
      tags$ul(items),
      hr(),
      tags$small(paste("Total groups:", k), style = "color: #888;")
    )
  })

  # ── Tab 2: Profile Similarity ────────────────────────────────────────────

  observeEvent(input$calc_similarity, {
    req(rv$igraph)
    g   <- ensure_igraph(rv$igraph)
    adj <- get_adj(g, use_weights = isTRUE(input$use_weights_sim))
    # For undirected graphs, row and column profiles are identical — force combined
    direction <- if (!igraph::is_directed(g)) "combined" else input$sim_direction
    rv$profile_dist <- compute_dist(adj, input$sim_method, direction)
  })

  output$similarity_heatmap <- renderPlotly({
    req(rv$profile_dist, rv$igraph)
    d   <- rv$profile_dist
    n   <- nrow(d)
    nms <- igraph::V(rv$igraph)$name %||% as.character(seq_len(n))

    max_d <- max(d, na.rm = TRUE)
    sim   <- if (max_d > 0) 1 - d / max_d else matrix(1, n, n)
    rownames(sim) <- colnames(sim) <- nms

    plot_ly(
      x = nms, y = nms, z = sim,
      type = "heatmap",
      colorscale = list(c(0, "#FFFFFF"), c(1, "#CC0000")),
      hovertemplate = "%{y} ↔ %{x}<br>Similarity: %{z:.3f}<extra></extra>"
    ) %>%
      layout(
        title  = "Structural Similarity (1 = identical profile)",
        xaxis  = list(title = "", tickangle = -45),
        yaxis  = list(title = "", autorange = "reversed"),
        margin = list(l = 80, b = 80)
      )
  })

  output$similarity_stats_ui <- renderUI({
    req(rv$profile_dist, rv$igraph)
    d   <- rv$profile_dist
    n   <- nrow(d)
    nms <- igraph::V(rv$igraph)$name %||% as.character(seq_len(n))

    upper <- d[upper.tri(d)]
    tmp   <- d; diag(tmp) <- Inf
    min_idx <- which(tmp == min(tmp, na.rm = TRUE), arr.ind = TRUE)[1, ]
    diag(tmp) <- -Inf
    max_idx <- which(tmp == max(tmp[is.finite(tmp)], na.rm = TRUE), arr.ind = TRUE)[1, ]

    tagList(
      tags$ul(
        tags$li(tags$b("Nodes: "), n),
        tags$li(tags$b("Mean Distance: "),   round(mean(upper),   3)),
        tags$li(tags$b("Median Distance: "), round(median(upper), 3)),
        tags$li(tags$b("Max Distance: "),    round(max(upper),    3)),
        tags$li(tags$b("Most Similar: "),
                paste(nms[min_idx[1]], "↔", nms[min_idx[2]])),
        tags$li(tags$b("Most Different: "),
                paste(nms[max_idx[1]], "↔", nms[max_idx[2]]))
      ),
      hr(),
      tags$small("Red = high similarity (similar role). White = low similarity.",
                 style = "color:#888;")
    )
  })

  # ── Tab 3: Blockmodeling ─────────────────────────────────────────────────

  observeEvent(input$run_blockmodel, {
    req(rv$igraph)
    g    <- ensure_igraph(rv$igraph)
    adj  <- get_adj(g, use_weights = isTRUE(input$use_weights_block))
    n    <- nrow(adj)
    k    <- min(input$n_blocks, n - 1)

    dist_mat <- compute_dist(adj, input$block_dist_method, "combined")
    dist_obj <- as.dist(dist_mat)
    hc       <- hclust(dist_obj, method = input$cluster_method)
    groups   <- cutree(hc, k = k)

    max_k    <- min(8, n - 1)
    elbow_df <- data.frame(
      k    = 2:max_k,
      wcss = sapply(2:max_k, function(ki) wcss_from_dist(dist_mat, cutree(hc, k = ki)))
    )

    rv$blockmodel_res <- list(groups = groups, hc = hc, dist_mat = dist_mat,
         elbow_df = elbow_df, k = k)
  })

  output$blockmodel_stats_ui <- renderUI({
    req(rv$blockmodel_res, rv$igraph)
    res  <- rv$blockmodel_res
    nms  <- igraph::V(rv$igraph)$name %||% as.character(seq_len(length(res$groups)))
    items <- lapply(seq_len(res$k), function(gid) {
      members <- nms[res$groups == gid]
      tags$li(tags$b(paste0("Block ", gid, " (n=", length(members), "): ")),
              paste(members, collapse = ", "))
    })
    tagList(
      tags$p(tags$b(paste(res$k, "-block solution"))),
      tags$ul(items)
    )
  })

  output$elbow_plot <- renderPlotly({
    req(rv$blockmodel_res)
    df <- rv$blockmodel_res$elbow_df
    k  <- rv$blockmodel_res$k

    plot_ly(df, x = ~k, y = ~wcss, type = "scatter", mode = "lines+markers",
            marker = list(size = 8, color = "#CC0000"),
            line   = list(color = "#CC0000"),
            name   = "WCSS") %>%
      add_markers(x = k, y = df$wcss[df$k == k],
                  marker = list(size = 14, color = "#000000", symbol = "star"),
                  name = "Selected k") %>%
      layout(
        title      = "Elbow Plot — Within-Block Sum of Squares",
        xaxis      = list(title = "Number of Blocks (k)", dtick = 1),
        yaxis      = list(title = "Within-Block SS"),
        showlegend = FALSE
      )
  })

  output$blockmodel_plot <- renderVisNetwork({
    req(rv$blockmodel_res, rv$igraph)
    g      <- rv$igraph
    groups <- rv$blockmodel_res$groups
    k      <- rv$blockmodel_res$k

    palette   <- RColorBrewer::brewer.pal(max(k, 3), "Set1")
    node_cols <- palette[groups]

    vis_data <- igraph_to_visNetwork(g, input$layout)
    vis_data <- apply_layer_selection(vis_data, input$layer_selection)
    vis_data <- apply_node_styling(vis_data,
      node_color = input$node_color,
      node_shape = input$node_shape,
      node_size  = input$node_size,
      label_size = input$label_size
    )
    vis_data$nodes$color.background <- node_cols
    vis_data$nodes$title            <- paste("Block:", groups)

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

  output$permuted_matrix_plot <- renderPlotly({
    req(rv$blockmodel_res, rv$igraph)
    g      <- rv$igraph
    groups <- rv$blockmodel_res$groups
    k      <- rv$blockmodel_res$k

    adj  <- get_adj(g, use_weights = isTRUE(input$use_weights_block))
    nms  <- igraph::V(g)$name %||% as.character(seq_len(nrow(adj)))
    ord  <- order(groups)
    adj_perm <- adj[ord, ord]
    nms_perm <- nms[ord]
    grp_perm <- groups[ord]

    boundaries <- which(diff(grp_perm) != 0)
    n          <- length(nms_perm)

    plot_ly(
      x = nms_perm, y = nms_perm, z = adj_perm,
      type       = "heatmap",
      colorscale = list(c(0, "#FFFFFF"), c(1, "#CC0000")),
      showscale  = FALSE,
      hovertemplate = "%{y} → %{x}: %{z}<extra></extra>"
    ) %>%
      layout(
        title  = paste0("Permuted Matrix (", k, " blocks)"),
        xaxis  = list(title = "", tickangle = -45),
        yaxis  = list(title = "", autorange = "reversed"),
        margin = list(l = 80, b = 80),
        shapes = build_block_lines(boundaries, n)
      )
  })

  output$block_membership_table <- renderDT({
    req(rv$blockmodel_res, rv$igraph)
    groups <- rv$blockmodel_res$groups
    nms    <- igraph::V(rv$igraph)$name %||% as.character(seq_len(length(groups)))
    df     <- data.frame(Node = nms, Block = groups)
    df     <- df[order(df$Block, df$Node), ]
    datatable(df, options = list(pageLength = 15, scrollX = TRUE))
  })
}