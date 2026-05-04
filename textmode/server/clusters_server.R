clusters_server <- function(input, output, session, word_graph_rv) {

  # ── Louvain ──────────────────────────────────────────────────────────────────
  louvain_rv <- reactive({
    g    <- word_graph_rv()
    comm <- cluster_louvain(g)
    list(graph = g, comm = comm, membership = membership(comm))
  })

  output$louvain_plot <- renderPlot({
    res       <- louvain_rv()
    g         <- res$graph
    memb      <- res$membership
    layout_id <- input$layout %||% "fr"
    label_sz  <- input$label_size %||% 3

    n_clust <- max(memb)
    pal     <- RColorBrewer::brewer.pal(min(n_clust, 12), "Set3")
    node_cols <- pal[((memb - 1) %% length(pal)) + 1]

    set.seed(1776)
    ggraph(g, layout = layout_id) +
      geom_edge_link(aes(width = n), alpha = 0.15, colour = "#aaaaaa") +
      geom_node_point(colour = node_cols, size = input$node_size %||% 4) +
      geom_node_text(aes(label = name), repel = TRUE, size = label_sz,
                     colour = "#111111", max.overlaps = 30) +
      scale_edge_width(range = c(0.2, 2.5)) +
      labs(
        title    = paste0("Louvain Communities (", max(memb), " clusters)"),
        subtitle = "Colour = semantic community"
      ) +
      theme_void() +
      theme(
        plot.title    = element_text(size = 14, face = "bold"),
        plot.subtitle = element_text(size = 11, colour = "#555555"),
        legend.position = "none"
      )
  }, res = 110)

  output$louvain_table <- renderDT({
    res <- louvain_rv()
    df  <- tibble(
      Word    = V(res$graph)$name,
      Cluster = as.integer(res$membership)
    ) %>%
      arrange(Cluster, Word)
    datatable(df, rownames = FALSE,
              options = list(pageLength = 15, scrollX = TRUE),
              class = "stripe hover")
  })

  output$louvain_sizes <- renderPlot({
    res <- louvain_rv()
    df  <- tibble(Cluster = as.integer(res$membership)) %>%
      count(Cluster, name = "Size")
    ggplot(df, aes(x = factor(Cluster), y = Size)) +
      geom_col(fill = "#CC0000") +
      labs(title = "Cluster Sizes", x = "Cluster", y = "Words") +
      theme_minimal(base_size = 10) +
      theme(plot.title = element_text(size = 10, face = "bold"))
  })

  # ── Walktrap ─────────────────────────────────────────────────────────────────
  walktrap_rv <- reactive({
    g    <- word_graph_rv()
    comm <- cluster_walktrap(g)
    list(graph = g, comm = comm, membership = membership(comm))
  })

  output$walktrap_plot <- renderPlot({
    res       <- walktrap_rv()
    g         <- res$graph
    memb      <- res$membership
    layout_id <- input$layout %||% "fr"
    label_sz  <- input$label_size %||% 3

    n_clust   <- max(memb)
    pal       <- RColorBrewer::brewer.pal(min(n_clust, 12), "Paired")
    node_cols <- pal[((memb - 1) %% length(pal)) + 1]

    set.seed(1776)
    ggraph(g, layout = layout_id) +
      geom_edge_link(aes(width = n), alpha = 0.15, colour = "#aaaaaa") +
      geom_node_point(colour = node_cols, size = input$node_size %||% 4) +
      geom_node_text(aes(label = name), repel = TRUE, size = label_sz,
                     colour = "#111111", max.overlaps = 30) +
      scale_edge_width(range = c(0.2, 2.5)) +
      labs(
        title    = paste0("Walktrap Communities (", max(memb), " clusters)"),
        subtitle = "Colour = semantic community"
      ) +
      theme_void() +
      theme(
        plot.title    = element_text(size = 14, face = "bold"),
        plot.subtitle = element_text(size = 11, colour = "#555555"),
        legend.position = "none"
      )
  }, res = 110)

  output$walktrap_table <- renderDT({
    res <- walktrap_rv()
    df  <- tibble(
      Word    = V(res$graph)$name,
      Cluster = as.integer(res$membership)
    ) %>%
      arrange(Cluster, Word)
    datatable(df, rownames = FALSE,
              options = list(pageLength = 15, scrollX = TRUE),
              class = "stripe hover")
  })

  output$walktrap_sizes <- renderPlot({
    res <- walktrap_rv()
    df  <- tibble(Cluster = as.integer(res$membership)) %>%
      count(Cluster, name = "Size")
    ggplot(df, aes(x = factor(Cluster), y = Size)) +
      geom_col(fill = "#000000") +
      labs(title = "Cluster Sizes", x = "Cluster", y = "Words") +
      theme_minimal(base_size = 10) +
      theme(plot.title = element_text(size = 10, face = "bold"))
  })

  # ── Comparison table ─────────────────────────────────────────────────────────
  output$compare_table <- renderDT({
    lv  <- louvain_rv()
    wt  <- walktrap_rv()
    df  <- tibble(
      Word               = V(lv$graph)$name,
      Louvain_Cluster    = as.integer(lv$membership),
      Walktrap_Cluster   = as.integer(wt$membership)
    ) %>%
      arrange(Louvain_Cluster, Word)
    datatable(df, rownames = FALSE,
              options = list(pageLength = 20, scrollX = TRUE),
              class = "stripe hover")
  })
}
