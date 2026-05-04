textprep_server <- function(input, output, session, sentences_rv, words_rv, words_clean_rv) {

  # Step 2: sentences table
  output$sentences_table <- renderDT({
    df <- sentences_rv() %>%
      select(sentence_id, sentence) %>%
      mutate(sentence = stringr::str_trunc(sentence, 120))
    datatable(
      df,
      rownames  = FALSE,
      colnames  = c("Sentence ID", "Sentence Text"),
      options   = list(pageLength = 14, scrollX = TRUE),
      class     = "stripe hover"
    )
  })

  # Step 3: words table
  output$words_table <- renderDT({
    df <- words_rv() %>%
      select(sentence_id, word)
    datatable(
      df,
      rownames  = FALSE,
      colnames  = c("Sentence ID", "Word"),
      options   = list(pageLength = 15, scrollX = TRUE),
      class     = "stripe hover"
    )
  })

  # Step 4: cleaned words table
  output$words_clean_table <- renderDT({
    df <- words_clean_rv() %>%
      select(sentence_id, word)
    datatable(
      df,
      rownames  = FALSE,
      colnames  = c("Sentence ID", "Word"),
      options   = list(pageLength = 15, scrollX = TRUE),
      class     = "stripe hover"
    )
  })

  # Step 4: word frequency bar chart
  output$word_freq_plot <- renderPlot({
    freq_df <- words_clean_rv() %>%
      count(word, sort = TRUE) %>%
      slice_head(n = 20)

    ggplot(freq_df, aes(x = reorder(word, n), y = n)) +
      geom_col(fill = "#CC0000") +
      coord_flip() +
      labs(
        title = "Top 20 Words (after cleaning)",
        x     = NULL,
        y     = "Frequency"
      ) +
      theme_minimal(base_size = 11) +
      theme(plot.title = element_text(size = 11, face = "bold"))
  })
}
