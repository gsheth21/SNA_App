source(here::here("textmode", "server", "overview_server.R"))
source(here::here("textmode", "server", "textprep_server.R"))
source(here::here("textmode", "server", "pairs_server.R"))
source(here::here("textmode", "server", "network_server.R"))
source(here::here("textmode", "server", "centrality_server.R"))
source(here::here("textmode", "server", "viz_server.R"))
source(here::here("textmode", "server", "clusters_server.R"))

source(here::here("shared", "helpers", "ui_helpers.R"))

server <- function(input, output, session) {

  # ── Tab tracking ────────────────────────────────────────────────────────────
  current_tab <- reactiveVal("overview")

  observeEvent(input$current_tab, {
    req(input$current_tab)
    current_tab(input$current_tab)
  }, ignoreNULL = TRUE, ignoreInit = FALSE)

  # ── Reactive pipeline ────────────────────────────────────────────────────────

  # Step 2: sentences
  sentences_rv <- reactive({
    tibble(text = declaration_text) %>%
      mutate(sentence = str_split(text, "(?<=[.!?])\\s+")) %>%
      unnest(sentence) %>%
      mutate(sentence_id = row_number()) %>%
      filter(str_detect(sentence, "[A-Za-z]"))
  })

  # Step 3: tokenize
  words_rv <- reactive({
    sentences_rv() %>%
      unnest_tokens(word, sentence)
  })

  # Step 4: clean (reacts to sidebar extra_stops)
  words_clean_rv <- reactive({
    raw_stops <- input$extra_stops %||% ""
    extra <- tibble(
      word = unique(trimws(unlist(strsplit(raw_stops, "[,\n]+"))))
    ) %>%
      filter(nchar(word) > 0)

    result <- words_rv() %>%
      filter(str_detect(word, "^[a-z]+$")) %>%
      anti_join(stop_words, by = "word")

    if (nrow(extra) > 0) {
      result <- result %>% anti_join(extra, by = "word")
    }
    result
  })

  # Step 5: count pairs
  pairs_rv <- reactive({
    words_clean_rv() %>%
      pairwise_count(word, sentence_id, sort = TRUE, upper = FALSE)
  })

  # Step 6: filter (reacts to n_pairs slider)
  pairs_filtered_rv <- reactive({
    top_n <- input$n_pairs %||% 50
    pairs_rv() %>%
      slice_max(order_by = n, n = top_n, with_ties = FALSE)
  })

  # Step 7: build graph
  word_graph_rv <- reactive({
    pf <- pairs_filtered_rv()
    req(nrow(pf) > 0)
    graph_from_data_frame(pf, directed = FALSE)
  })

  # Step 8: centrality
  centrality_rv <- reactive({
    g <- word_graph_rv()
    tibble(
      word            = V(g)$name,
      degree          = igraph::degree(g),
      weighted_degree = igraph::strength(g),
      betweenness     = round(igraph::betweenness(g, directed = FALSE), 2)
    ) %>%
      arrange(desc(weighted_degree))
  })

  # ── Tab routing ──────────────────────────────────────────────────────────────
  output$tab_content <- renderUI({
    tab <- current_tab()

    switch(tab,
      "overview"   = tags$div(id = "tab-overview",   class = "tab-inner", overview_ui),
      "textprep"   = tags$div(id = "tab-textprep",   class = "tab-inner", textprep_ui),
      "pairs"      = tags$div(id = "tab-pairs",      class = "tab-inner", pairs_ui),
      "network"    = tags$div(id = "tab-network",    class = "tab-inner", network_ui),
      "centrality" = tags$div(id = "tab-centrality", class = "tab-inner", centrality_ui),
      "viz"        = tags$div(id = "tab-viz",        class = "tab-inner", viz_ui),
      "clusters"   = tags$div(id = "tab-clusters",   class = "tab-inner", clusters_ui),
      "about"      = tags$div(
        id = "tab-about", class = "tab-inner",
        fluidRow(
          box(
            title       = "About Text Network Analysis",
            width       = 12,
            solidHeader = TRUE,
            status      = "primary",
            h4("Text Network Analysis — Chapter"),
            p("This app implements the Text Networks chapter of the Social Network Analysis textbook."),
            p("It covers the complete workflow from raw text through sentence-level
              word co-occurrence network construction, centrality analysis, and community detection."),
            hr(),
            h5("Data Source"),
            p("The Declaration of Independence (United States, 1776) — a public domain document
              well-suited for teaching because of its clear rhetorical architecture."),
            hr(),
            h5("R Packages Used"),
            tags$ul(
              tags$li(code("tidytext"), " — tokenization and stopword removal"),
              tags$li(code("widyr"), " — pairwise co-occurrence counting"),
              tags$li(code("igraph"), " — graph construction and centrality"),
              tags$li(code("ggraph"), " — static network visualization"),
              tags$li(code("visNetwork"), " — interactive network visualization"),
              tags$li(code("ggrepel"), " — non-overlapping text labels")
            ),
            hr(),
            h5("References"),
            tags$ul(
              tags$li("Breiger, R.L. (1974). The duality of persons and groups. Social Forces, 53(2), 181–190."),
              tags$li("Stoltz, D.S. & Taylor, M.A. (2024). Mapping Texts. Oxford University Press."),
              tags$li("Mohr, J.W. (1998). Measuring meaning structures. Annual Review of Sociology, 24, 345–370.")
            )
          )
        )
      )
    )
  })

  # ── Dispatch to chapter servers ──────────────────────────────────────────────
  overview_server(input, output, session,
    sentences_rv = sentences_rv,
    words_clean_rv = words_clean_rv
  )

  textprep_server(input, output, session,
    sentences_rv   = sentences_rv,
    words_rv       = words_rv,
    words_clean_rv = words_clean_rv
  )

  pairs_server(input, output, session,
    pairs_rv          = pairs_rv,
    pairs_filtered_rv = pairs_filtered_rv
  )

  network_server(input, output, session,
    word_graph_rv = word_graph_rv
  )

  centrality_server(input, output, session,
    centrality_rv = centrality_rv,
    word_graph_rv = word_graph_rv
  )

  viz_server(input, output, session,
    word_graph_rv = word_graph_rv,
    centrality_rv = centrality_rv
  )

  clusters_server(input, output, session,
    word_graph_rv = word_graph_rv
  )
}
