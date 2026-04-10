adjmatrix_server <- function(input, output, session, rv) {

  # ── Affiliation matrix table (first 10x10 for readability) ─────────────────
  output$adjmatrix_table <- renderDT({
    # Show first 10 rows and first 12 columns (ego_id + first 10 songs)
    mat <- artist_track_adj
    n_show_rows <- min(10, nrow(mat))
    n_show_cols <- min(10, ncol(mat))

    df <- as.data.frame(mat[1:n_show_rows, 1:n_show_cols])

    datatable(
      df,
      options = list(
        scrollX    = TRUE,
        pageLength = 10,
        dom        = "t"
      ),
      rownames = TRUE
    )
  })

  # ── Network summary for a_t_g2 (primary graph) ─────────────────────────────
  output$adjmatrix_network_summary <- renderUI({
    n_nodes <- igraph::vcount(a_t_g2)
    n_e     <- igraph::ecount(a_t_g2)
    n_art   <- sum(V(a_t_g2)$type == FALSE)
    n_sng   <- sum(V(a_t_g2)$type == TRUE)
    is_bip  <- igraph::is_bipartite(a_t_g2)

    tagList(
      tags$ul(
        style = "font-size: 13px; line-height: 1.9;",
        tags$li(HTML(paste0("<strong>Total Nodes:</strong> ", n_nodes,
                            " (", n_art, " Artists + ", n_sng, " Songs)"))),
        tags$li(HTML(paste0("<strong>Total Edges:</strong> ", n_e))),
        tags$li(HTML(paste0("<strong>Is Bipartite:</strong> ",
                            if (is_bip) "✅ Yes (UN-B)" else "❌ No"))),
        tags$li(HTML(paste0("<strong>Matrix dimensions:</strong> ",
                            nrow(artist_track_adj), " rows × ",
                            ncol(artist_track_adj), " columns")))
      )
    )
  })
}
