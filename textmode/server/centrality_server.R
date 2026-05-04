centrality_server <- function(input, output, session, centrality_rv, word_graph_rv) {

  output$centrality_table <- renderDT({
    df <- centrality_rv() %>%
      rename(
        Word            = word,
        Degree          = degree,
        `Wtd. Degree`   = weighted_degree,
        Betweenness     = betweenness
      )
    datatable(
      df,
      rownames = FALSE,
      options  = list(pageLength = 15, scrollX = TRUE),
      class    = "stripe hover"
    ) %>%
      formatRound(columns = c("Betweenness"), digits = 1)
  })

  output$centrality_wdeg_plot <- renderPlot({
    df <- centrality_rv() %>%
      slice_head(n = 20)
    ggplot(df, aes(x = reorder(word, weighted_degree), y = weighted_degree)) +
      geom_col(fill = "#CC0000") +
      coord_flip() +
      labs(
        title = "Top 20 Words by Weighted Degree",
        x     = NULL,
        y     = "Weighted Degree (Strength)"
      ) +
      theme_minimal(base_size = 11) +
      theme(plot.title = element_text(size = 11, face = "bold"))
  })

  output$centrality_between_plot <- renderPlot({
    df <- centrality_rv() %>%
      arrange(desc(betweenness)) %>%
      slice_head(n = 20)
    ggplot(df, aes(x = reorder(word, betweenness), y = betweenness)) +
      geom_col(fill = "#000000") +
      coord_flip() +
      labs(
        title = "Top 20 Words by Betweenness",
        x     = NULL,
        y     = "Betweenness Centrality"
      ) +
      theme_minimal(base_size = 11) +
      theme(plot.title = element_text(size = 11, face = "bold"))
  })
}
