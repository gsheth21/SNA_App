overview_server <- function(input, output, session, sentences_rv, words_clean_rv) {

  output$overview_doc_stats <- renderUI({
    s <- sentences_rv()
    w <- words_clean_rv()
    tagList(
      tags$ul(
        tags$li(strong("Sentences: "), nrow(s)),
        tags$li(strong("Content words (after cleaning): "), nrow(w)),
        tags$li(strong("Unique content words: "), length(unique(w$word)))
      )
    )
  })
}
