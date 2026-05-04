viz_server <- function(input, output, session, word_graph_rv, centrality_rv) {

  get_layout <- function() input$layout %||% "fr"

  # ── Static ggraph ────────────────────────────────────────────────────────────
  output$viz_ggraph_plot <- renderPlot({
    g          <- word_graph_rv()
    layout_id  <- get_layout()
    node_sz    <- input$node_size  %||% 4
    label_sz   <- input$label_size %||% 3
    edge_alpha <- input$edge_alpha %||% 0.25

    set.seed(1776)
    ggraph(g, layout = layout_id) +
      geom_edge_link(aes(width = n), alpha = edge_alpha, colour = "#888888") +
      geom_node_point(size = node_sz, colour = "#CC0000") +
      geom_node_text(aes(label = name), repel = TRUE, size = label_sz,
                     colour = "#000000", max.overlaps = 30) +
      scale_edge_width(range = c(0.2, 2.5)) +
      labs(
        title    = "Sentence-Level Word Co-Occurrence Network",
        subtitle = "Declaration of Independence (1776)"
      ) +
      theme_void() +
      theme(
        plot.title    = element_text(size = 14, face = "bold"),
        plot.subtitle = element_text(size = 11, colour = "#555555"),
        legend.position = "none"
      )
  }, res = 110)

  # ── Nodes sized by degree ────────────────────────────────────────────────────
  output$viz_degree_plot <- renderPlot({
    g          <- word_graph_rv()
    layout_id  <- get_layout()
    label_sz   <- input$label_size %||% 3
    edge_alpha <- input$edge_alpha %||% 0.25

    deg <- igraph::degree(g)
    V(g)$size <- scales::rescale(deg, to = c(2, 12))

    set.seed(1776)
    ggraph(g, layout = layout_id) +
      geom_edge_link(aes(width = n), alpha = edge_alpha, colour = "#888888") +
      geom_node_point(aes(size = size), colour = "#CC0000") +
      geom_node_text(aes(label = name), repel = TRUE, size = label_sz,
                     colour = "#000000", max.overlaps = 30) +
      scale_edge_width(range = c(0.2, 2.5)) +
      scale_size_identity() +
      labs(
        title    = "Word Network — Nodes Sized by Degree",
        subtitle = "Larger nodes = more co-occurring neighbours"
      ) +
      theme_void() +
      theme(
        plot.title    = element_text(size = 14, face = "bold"),
        plot.subtitle = element_text(size = 11, colour = "#555555"),
        legend.position = "none"
      )
  }, res = 110)

  # ── Interactive visNetwork ───────────────────────────────────────────────────
  output$viz_vis_plot <- visNetwork::renderVisNetwork({
    g          <- word_graph_rv()
    cent       <- centrality_rv()
    node_sz    <- input$node_size %||% 4

    nodes <- tibble(
      id    = V(g)$name,
      label = V(g)$name
    ) %>%
      left_join(cent %>% select(word, weighted_degree), by = c("id" = "word")) %>%
      mutate(
        value = scales::rescale(weighted_degree, to = c(node_sz * 2, node_sz * 8)),
        title = paste0("<b>", label, "</b><br/>Wtd. Degree: ", weighted_degree),
        color = "#CC0000",
        font  = list(color = "#000000")
      )

    edges_df  <- igraph::as_data_frame(g, what = "edges")
    edges_vis <- data.frame(
      from  = edges_df$from,
      to    = edges_df$to,
      value = edges_df$n,
      title = paste0("Co-occurrences: ", edges_df$n),
      color = "#888888"
    )

    visNetwork::visNetwork(nodes, edges_vis) %>%
      visNetwork::visEdges(smooth = FALSE) %>%
      visNetwork::visPhysics(
        solver = "forceAtlas2Based",
        forceAtlas2Based = list(gravitationalConstant = -50)
      ) %>%
      visNetwork::visLayout(randomSeed = 1776) %>%
      visNetwork::visInteraction(
        dragNodes       = TRUE,
        dragView        = TRUE,
        zoomView        = TRUE,
        navigationButtons = TRUE
      ) %>%
      visNetwork::visOptions(highlightNearest = TRUE, nodesIdSelection = TRUE)
  })
}
