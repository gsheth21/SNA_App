viz_server <- function(input, output, session, rv) {

  # ── Helper: resolve sidebar layout string to ggraph layout ─────────────────
  get_layout <- function(layout_id) {
    layout_id %||% "dh"
  }

  # ── Sub-tab 1: Basic — stress, uniform, FIXED ───────────────────────────────
  output$viz_basic_plot <- renderPlot({
    set.seed(123)
    ggraph(a_t_g2, layout = "stress") +
      geom_edge_link(alpha = 0.2) +
      geom_node_point(size = 0.5) +
      theme_void()
  }, res = 110)

  # ── Sub-tab 2: Bipartite top/bottom — FIXED ─────────────────────────────────
  output$viz_bipartite_tb <- renderPlot({
    ggraph(a_t_g2, layout = "bipartite") +
      geom_edge_link(alpha = 0.1) +
      geom_node_point(aes(color = type), size = 4) +
      theme_void()
  }, res = 110)

  # ── Sub-tab 2: Bipartite left/right — FIXED ─────────────────────────────────
  output$viz_bipartite_lr <- renderPlot({
    ggraph(a_t_g2, layout = "bipartite") +
      geom_edge_link(alpha = 0.1) +
      geom_node_point(aes(color = type), size = 4) +
      coord_flip() +
      theme_void()
  }, res = 110)

  # ── Sub-tab 3: Force + Color — sidebar-reactive ─────────────────────────────
  output$viz_force_color_plot <- renderPlot({
    layout_id   <- get_layout(input$layout)
    node_sz     <- input$node_size   %||% 1
    edge_alpha  <- input$edge_opacity %||% 0.2
    art_col     <- input$artist_color %||% "steelblue1"
    sng_col     <- input$song_color   %||% "maroon"

    # Build color vector from mode attribute
    fill_vals <- ifelse(V(a_t_g2)$type, sng_col, art_col)

    set.seed(123)
    ggraph(a_t_g2, layout = layout_id) +
      geom_edge_link(alpha = edge_alpha) +
      geom_node_point(color = fill_vals, size = node_sz) +
      labs(title = "Grime Artists Connected to Songs 2008") +
      theme_void()
  }, res = 110)

  # ── Sub-tab 4: Force + Shape — sidebar-reactive ─────────────────────────────
  output$viz_force_shape_plot <- renderPlot({
    layout_id   <- get_layout(input$layout)
    node_sz     <- input$node_size    %||% 1
    edge_alpha  <- input$edge_opacity %||% 0.2
    art_col     <- input$artist_color %||% "steelblue1"
    sng_col     <- input$song_color   %||% "maroon"

    set.seed(123)
    ggraph(a_t_g2, layout = layout_id) +
      geom_edge_link(alpha = edge_alpha) +
      geom_node_point(
        aes(shape = mode, color = mode),
        size = node_sz
      ) +
      scale_shape_manual(
        name   = "Node Type",
        values = c("Artist" = 16, "Song" = 15)
      ) +
      scale_color_manual(
        name   = "Node Type",
        values = c("Artist" = art_col, "Song" = sng_col)
      ) +
      labs(
        title = "Grime Artists Connected to Songs 2008",
        color = "Node Type", shape = "Node Type"
      ) +
      theme_void()
  }, res = 110)

  # ── Sub-tab 5: Styled — sidebar-reactive ────────────────────────────────────
  output$viz_styled_plot <- renderPlot({
    layout_id  <- get_layout(input$layout)
    node_sz    <- input$node_size    %||% 1
    edge_alpha <- input$edge_opacity %||% 0.2
    art_col    <- input$artist_color %||% "steelblue1"
    sng_col    <- input$song_color   %||% "maroon"

    # Show labels only if selected  in sidebar
    show_labels <- "labels" %in% (input$layer_selection %||% character(0))

    set.seed(123)
    p <- ggraph(a_t_g2, layout = layout_id) +
      geom_edge_link(alpha = edge_alpha) +
      geom_node_point(
        aes(shape = mode, color = mode),
        size = node_sz
      ) +
      scale_shape_manual(
        name   = "Node Type",
        values = c("Artist" = 16, "Song" = 15)
      ) +
      scale_color_manual(
        name   = "Node Type",
        values = c("Artist" = art_col, "Song" = sng_col)
      ) +
      labs(title = "Grime Artists Connected to Songs 2008") +
      theme_void()

    if (show_labels) {
      p <- p + geom_node_text(aes(label = name), size = 2, repel = TRUE)
    }

    p
  }, res = 110)
}
