projection_server <- function(input, output, session, rv) {

  # ── Projection summary cards ────────────────────────────────────────────────
  output$projection_summary <- renderUI({
    proj1 <- projections$proj1
    proj2 <- projections$proj2

    fluidRow(
      column(6,
        div(
          style = "background:#e8f4fd; border-left:4px solid steelblue;
                   padding:12px; border-radius:4px; font-size:13px;",
          tags$strong("proj1 — Artist–Artist Network"),
          tags$ul(
            style = "margin-top:6px;",
            tags$li(HTML(paste0("<strong>Nodes:</strong> ", igraph::vcount(proj1), " artists"))),
            tags$li(HTML(paste0("<strong>Edges:</strong> ", igraph::ecount(proj1),
                                " (co-appearances on same song)"))),
            tags$li(HTML(paste0("<strong>Weighted:</strong> ",
                                if (igraph::is_weighted(proj1)) "Yes — weight = # shared songs"
                                else "No"))),
            tags$li(HTML(paste0("<strong>Directed:</strong> ", igraph::is_directed(proj1))))
          )
        )
      ),
      column(6,
        div(
          style = "background:#fdf3e8; border-left:4px solid maroon;
                   padding:12px; border-radius:4px; font-size:13px;",
          tags$strong("proj2 — Song–Song Network"),
          tags$ul(
            style = "margin-top:6px;",
            tags$li(HTML(paste0("<strong>Nodes:</strong> ", igraph::vcount(proj2), " songs"))),
            tags$li(HTML(paste0("<strong>Edges:</strong> ", igraph::ecount(proj2),
                                " (songs sharing at least one artist)"))),
            tags$li(HTML(paste0("<strong>Weighted:</strong> ",
                                if (igraph::is_weighted(proj2)) "Yes — weight = # shared artists"
                                else "No"))),
            tags$li(HTML(paste0("<strong>Directed:</strong> ", igraph::is_directed(proj2))))
          )
        )
      )
    )
  })

  # ── proj1: Artist–Artist network plot ───────────────────────────────────────
  output$proj1_plot <- renderPlot({
    set.seed(123)
    ggraph(projections$proj1, layout = "fr") +
      geom_edge_link(alpha = 0.2) +
      geom_node_point(size = 1, alpha = 0.2, color = "steelblue1") +
      labs(title = "Grime Artists Connected By The Songs They Worked on 2008") +
      theme_void()
  }, res = 110)

  # ── proj2: Song–Song network plot ───────────────────────────────────────────
  output$proj2_plot <- renderPlot({
    set.seed(123)
    ggraph(projections$proj2, layout = "fr") +
      geom_edge_link(alpha = 0.2) +
      geom_node_point(size = 1, alpha = 0.2, color = "maroon") +
      labs(title = "Grime Songs Connected By The Artists They Feature 2008") +
      theme_void()
  }, res = 110)
}
