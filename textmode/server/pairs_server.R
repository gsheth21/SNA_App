pairs_server <- function(input, output, session, pairs_rv, pairs_filtered_rv) {

  # Step 5: all pairs table
  output$pairs_table <- renderDT({
    df <- pairs_rv() %>%
      rename(Word1 = item1, Word2 = item2, `Co-occurrences` = n)
    datatable(
      df,
      rownames = FALSE,
      options  = list(pageLength = 15, scrollX = TRUE),
      class    = "stripe hover"
    )
  })

  # Step 5: top-20 bar chart
  output$pairs_bar_plot <- renderPlot({
    df <- pairs_rv() %>%
      slice_head(n = 20) %>%
      mutate(pair = paste(item1, "–", item2))
    ggplot(df, aes(x = reorder(pair, n), y = n)) +
      geom_col(fill = "#CC0000") +
      coord_flip() +
      labs(
        title = "Top 20 Word Pairs",
        x     = NULL,
        y     = "Co-occurrences"
      ) +
      theme_minimal(base_size = 11) +
      theme(plot.title = element_text(size = 11, face = "bold"))
  })

  # Step 6: filtered pairs title
  output$filtered_pairs_title <- renderUI({
    n <- input$n_pairs %||% 50
    paste0("📋 Top ", n, " Pairs (filtered)")
  })

  # Step 6: filtered pairs table
  output$pairs_filtered_table <- renderDT({
    df <- pairs_filtered_rv() %>%
      rename(Word1 = item1, Word2 = item2, `Co-occurrences` = n)
    datatable(
      df,
      rownames = FALSE,
      options  = list(pageLength = 15, scrollX = TRUE),
      class    = "stripe hover"
    )
  })

  # Step 6: histogram of co-occurrence counts
  output$pairs_hist <- renderPlotly({
    df <- pairs_rv()
    p <- ggplot(df, aes(x = n)) +
      geom_histogram(fill = "#CC0000", color = "white", binwidth = 1) +
      labs(
        title = "Distribution of Co-occurrence Counts",
        x     = "Count (n)",
        y     = "Number of Pairs"
      ) +
      theme_minimal(base_size = 11)
    ggplotly(p) %>% layout(showlegend = FALSE)
  })
}
