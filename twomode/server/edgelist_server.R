edgelist_server <- function(input, output, session, rv) {

  # ── Full edgelist table ─────────────────────────────────────────────────────
  output$edgelist_table <- renderDT({
    datatable(
      artist_track_edge,
      options = list(
        scrollX    = TRUE,
        pageLength = 10,
        dom        = "lfrtip"
      ),
      rownames = FALSE
    )
  })

  # ── Network summary for the edgelist-built graph (a_t_g) ───────────────────
  output$edgelist_network_summary <- renderUI({
    n_nodes  <- igraph::vcount(a_t_g)
    n_e      <- igraph::ecount(a_t_g)
    n_art    <- sum(V(a_t_g)$type == FALSE)
    n_sng    <- sum(V(a_t_g)$type == TRUE)
    is_bip   <- igraph::is_bipartite(a_t_g)

    tagList(
      tags$ul(
        style = "font-size: 13px; line-height: 1.9;",
        tags$li(HTML(paste0("<strong>Total Nodes:</strong> ", n_nodes,
                            " (", n_art, " Artists + ", n_sng, " Songs)"))),
        tags$li(HTML(paste0("<strong>Total Edges:</strong> ", n_e))),
        tags$li(HTML(paste0("<strong>Directed:</strong> ", igraph::is_directed(a_t_g)))),
        tags$li(HTML(paste0("<strong>Is Bipartite:</strong> ",
                            if (is_bip) "✅ Yes (UN-B)" else "❌ No")))
      ),
      tags$p(
        tags$small("The is_bipartite() check confirms the network is a valid two-mode graph."),
        style = "color: #666; font-size: 12px; margin-top: 10px;"
      )
    )
  })
}
