textprep_ui <- tagList(

  tabBox(
    title = "Text Preparation (Steps 2–4)",
    id    = "textprep_tabs",
    width = 12,

    # ── Step 2: Sentence splitting ────────────────────────────────────────────
    tabPanel(
      title = "Step 2 · Sentences",
      value = "tp_sentences",
      icon  = icon("paragraph"),

      fluidRow(
        box(
          title       = "Split Text into Sentences",
          width       = 12,
          solidHeader = TRUE,
          status      = "primary",
          p("The text is split on sentence-ending punctuation (", code(".!?"), "). Each row
            is one sentence and receives a numeric ", code("sentence_id"),
            " used later to identify co-occurring words."),
          tags$pre(
            class = "r-code",
            style = "background:#f5f5f5; padding:8px; border-radius:4px; font-size:12px;",
'sentences <- tibble(text = declaration_text) %>%
  mutate(sentence = str_split(text, "(?<=[.!?])\\\\s+")) %>%
  unnest(sentence) %>%
  mutate(sentence_id = row_number()) %>%
  filter(str_detect(sentence, "[A-Za-z]"))'
          )
        )
      ),
      fluidRow(
        box(
          title       = "📋 Sentence Table",
          width       = 12,
          solidHeader = TRUE,
          status      = "info",
          withSpinner(DTOutput("sentences_table"), color = "#CC0000", type = 4)
        )
      )
    ),

    # ── Step 3: Tokenize ──────────────────────────────────────────────────────
    tabPanel(
      title = "Step 3 · Tokenize",
      value = "tp_tokens",
      icon  = icon("list"),

      fluidRow(
        box(
          title       = "Tokenize into Words",
          width       = 12,
          solidHeader = TRUE,
          status      = "primary",
          p(code("unnest_tokens()"), " splits each sentence into one word per row.
            Every row now shows a word and the sentence it came from — the essential
            intermediate form from which the network will be built."),
          tags$pre(
            class = "r-code",
            style = "background:#f5f5f5; padding:8px; border-radius:4px; font-size:12px;",
'words <- sentences %>%
  unnest_tokens(word, sentence)'
          )
        )
      ),
      fluidRow(
        box(
          title       = "📋 Words Table (all tokens)",
          width       = 12,
          solidHeader = TRUE,
          status      = "info",
          withSpinner(DTOutput("words_table"), color = "#CC0000", type = 4)
        )
      )
    ),

    # ── Step 4: Clean ─────────────────────────────────────────────────────────
    tabPanel(
      title = "Step 4 · Clean",
      value = "tp_clean",
      icon  = icon("broom"),

      fluidRow(
        box(
          title       = "Remove Stopwords",
          width       = 12,
          solidHeader = TRUE,
          status      = "primary",
          p("Common function words (the, and, of, …) are removed with ",
            code("anti_join(stop_words)"), ". Extra domain-specific stops can be
            added via the sidebar. Only alphabetic tokens are kept."),
          tags$pre(
            class = "r-code",
            style = "background:#f5f5f5; padding:8px; border-radius:4px; font-size:12px;",
'words_clean <- words %>%
  filter(str_detect(word, "^[a-z]+$")) %>%
  anti_join(stop_words, by = "word") %>%
  anti_join(custom_stop, by = "word")'
          )
        )
      ),
      fluidRow(
        column(8,
          box(
            title       = "📋 Cleaned Words Table",
            width       = NULL,
            solidHeader = TRUE,
            status      = "info",
            withSpinner(DTOutput("words_clean_table"), color = "#CC0000", type = 4)
          )
        ),
        column(4,
          box(
            title       = "📊 Top Word Frequencies",
            width       = NULL,
            solidHeader = TRUE,
            status      = "info",
            withSpinner(plotOutput("word_freq_plot", height = "350px"), color = "#CC0000", type = 4)
          )
        )
      )
    )
  )
)
