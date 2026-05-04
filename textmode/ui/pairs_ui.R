pairs_ui <- tagList(

  tabBox(
    title = "Co-occurring Word Pairs (Steps 5–6)",
    id    = "pairs_tabs",
    width = 12,

    # ── Step 5: Count pairs ───────────────────────────────────────────────────
    tabPanel(
      title = "Step 5 · Count Pairs",
      value = "pairs_count",
      icon  = icon("equals"),

      fluidRow(
        box(
          title       = "Count Co-occurring Word Pairs",
          width       = 12,
          solidHeader = TRUE,
          status      = "primary",
          p(code("pairwise_count()"), " counts how often each word pair appears in
            the same sentence. Each row is a unique (word1, word2) pair with a count ",
            code("n"), ". This table is the relational foundation of the network —
            it exists before any graph is drawn."),
          tags$pre(
            class = "r-code",
            style = "background:#f5f5f5; padding:8px; border-radius:4px; font-size:12px;",
'pairs <- words_clean %>%
  pairwise_count(word, sentence_id, sort = TRUE, upper = FALSE)'
          )
        )
      ),
      fluidRow(
        column(7,
          box(
            title       = "📋 All Pairs (sorted by co-occurrence count)",
            width       = NULL,
            solidHeader = TRUE,
            status      = "info",
            withSpinner(DTOutput("pairs_table"), color = "#CC0000", type = 4)
          )
        ),
        column(5,
          box(
            title       = "📊 Top 20 Strongest Pairs",
            width       = NULL,
            solidHeader = TRUE,
            status      = "info",
            withSpinner(plotOutput("pairs_bar_plot", height = "400px"), color = "#CC0000", type = 4)
          )
        )
      )
    ),

    # ── Step 6: Filter ────────────────────────────────────────────────────────
    tabPanel(
      title = "Step 6 · Filter",
      value = "pairs_filter",
      icon  = icon("filter"),

      fluidRow(
        box(
          title       = "Filter for Readability",
          width       = 12,
          solidHeader = TRUE,
          status      = "primary",
          p("Keeping all pairs usually produces a graph too dense to read. Use the ",
            strong("Top N Pairs"), " slider in the sidebar to keep only the strongest ties.
            The graph you see later is a ", em("simplified representation"), " — not the
            totality of all word relations."),
          tags$pre(
            class = "r-code",
            style = "background:#f5f5f5; padding:8px; border-radius:4px; font-size:12px;",
'pairs_filtered <- pairs %>%
  slice_max(order_by = n, n = 50)   # sidebar slider controls this'
          )
        )
      ),
      fluidRow(
        column(7,
          box(
            title       = uiOutput("filtered_pairs_title"),
            width       = NULL,
            solidHeader = TRUE,
            status      = "info",
            withSpinner(DTOutput("pairs_filtered_table"), color = "#CC0000", type = 4)
          )
        ),
        column(5,
          box(
            title       = "📊 Distribution of Co-occurrence Counts",
            width       = NULL,
            solidHeader = TRUE,
            status      = "info",
            withSpinner(plotlyOutput("pairs_hist", height = "350px"), color = "#CC0000", type = 4)
          )
        )
      )
    )
  )
)
