centrality_server <- function(input, output, session, rv) {

  # ── Helper: summary stats table ─────────────────────────────────────────────
  make_summary_dt <- function(vals) {
    df <- data.frame(
      Statistic = c("Mean", "Min", "Max", "SD", "N"),
      Value     = c(
        round(mean(vals), 2),
        round(min(vals),  2),
        round(max(vals),  2),
        round(sd(vals),   2),
        length(vals)
      ),
      stringsAsFactors = FALSE
    )
    datatable(df, options = list(dom = "t", pageLength = 5), rownames = FALSE)
  }

  # ── Helper: degree group plot ────────────────────────────────────────────────
  make_degree_plot <- function(mode_type, threshold, node_sz, edge_alpha, layout_id,
                                above_label, group_attr_name) {
    g <- a_t_g2
    type_flag  <- if (mode_type == "Artist") FALSE else TRUE
    target_idx <- which(V(g)$type == type_flag)

    deg_vals <- igraph::degree(g, v = target_idx)

    group_vec <- rep(NA_character_, igraph::vcount(g))
    group_vec[target_idx] <- ifelse(deg_vals >= threshold, "Above Avg", "Below Avg")
    igraph::vertex_attr(g, group_attr_name) <- group_vec

    set.seed(123)
    ggraph(g, layout = layout_id) +
      geom_edge_link(alpha = edge_alpha) +
      geom_node_point(
        aes(shape = mode, color = .data[[group_attr_name]]),
        size = node_sz
      ) +
      scale_shape_manual(
        name   = "Node Type",
        values = c("Artist" = 16, "Song" = 15)
      ) +
      scale_color_manual(
        name   = above_label,
        values = c("Above Avg" = "red", "Below Avg" = "black"),
        na.value = "grey70"
      ) +
      labs(title = paste0(mode_type, " Degree vs. Threshold (≥ ", threshold, ")")) +
      theme_void()
  }

  # ============================================================
  # 13.4  DEGREE CENTRALITY
  # ============================================================

  # Artist degree summary
  output$artist_degree_summary <- renderDT({
    vals <- centrality_df$degree[centrality_df$type == "Artist"]
    make_summary_dt(vals)
  })

  # Song degree summary
  output$song_degree_summary <- renderDT({
    vals <- centrality_df$degree[centrality_df$type == "Song"]
    make_summary_dt(vals)
  })

  # Artist degree plot
  output$artist_degree_plot <- renderPlot({
    thresh     <- input$artist_threshold %||% 3
    node_sz    <- input$node_size        %||% 2
    edge_alpha <- input$edge_opacity     %||% 0.2
    layout_id  <- input$layout          %||% "dh"

    make_degree_plot(
      mode_type       = "Artist",
      threshold       = thresh,
      node_sz         = node_sz,
      edge_alpha      = edge_alpha,
      layout_id       = layout_id,
      above_label     = "Artist Degree",
      group_attr_name = "artist_degree_group"
    )
  }, res = 110)

  # Song degree plot
  output$song_degree_plot <- renderPlot({
    thresh     <- input$song_threshold  %||% 3
    node_sz    <- input$node_size       %||% 2
    edge_alpha <- input$edge_opacity    %||% 0.2
    layout_id  <- input$layout         %||% "dh"

    make_degree_plot(
      mode_type       = "Song",
      threshold       = thresh,
      node_sz         = node_sz,
      edge_alpha      = edge_alpha,
      layout_id       = layout_id,
      above_label     = "Song Degree",
      group_attr_name = "song_degree_group"
    )
  }, res = 110)

  # ============================================================
  # 13.5  BETWEENNESS CENTRALITY
  # ============================================================

  # Artist betweenness summary
  output$artist_between_summary <- renderDT({
    vals <- centrality_df$between[centrality_df$type == "Artist"]
    make_summary_dt(vals)
  })

  # Song betweenness summary
  output$song_between_summary <- renderDT({
    vals <- centrality_df$between[centrality_df$type == "Song"]
    make_summary_dt(vals)
  })

  # Artist betweenness callout
  output$artist_between_callout <- renderUI({
    vals   <- centrality_df$between[centrality_df$type == "Artist"]
    m_val  <- round(mean(vals), 0)
    mx_val <- round(max(vals),  0)
    sd_val <- round(sd(vals),   0)
    n_zero <- sum(vals == 0)

    div(
      style = "background:#e8f4fd; border-left:4px solid #1f78b4;
               padding:10px; border-radius:4px; font-size:13px;",
      tags$strong("Interpretation:"),
      tags$ul(
        style = "margin-top:6px;",
        tags$li(paste0("Mean = ", m_val, ", SD = ", sd_val, ", Max = ", mx_val, ".")),
        tags$li(paste0(n_zero, " artists have betweenness = 0 — they are embedded in
                       small or redundant parts of the network.")),
        tags$li("A small number of artists are major bridges, connecting otherwise separate
                 parts of the track–artist structure. High betweenness reflects cross-mode
                 brokerage, not direct social influence.")
      )
    )
  })

  # Song betweenness callout
  output$song_between_callout <- renderUI({
    vals   <- centrality_df$between[centrality_df$type == "Song"]
    m_val  <- round(mean(vals), 0)
    mx_val <- round(max(vals),  0)
    sd_val <- round(sd(vals),   0)
    n_zero <- sum(vals == 0)

    div(
      style = "background:#fdf3e8; border-left:4px solid #ff7f00;
               padding:10px; border-radius:4px; font-size:13px;",
      tags$strong("Interpretation:"),
      tags$ul(
        style = "margin-top:6px;",
        tags$li(paste0("Mean = ", m_val, ", SD = ", sd_val, ", Max = ", mx_val, ".")),
        tags$li(paste0(n_zero, " songs have betweenness = 0 — they connect clusters that
                       are otherwise fully contained.")),
        tags$li("Songs with high betweenness are structural 'meeting points' — shared contexts
                 that connect otherwise disconnected clusters of artists. Songs are not agentic
                 brokers, but they are key connectors in the network.")
      )
    )
  })
}
