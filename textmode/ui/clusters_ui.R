clusters_ui <- tagList(

  tabBox(
    title = "Step 10 · Identify Clusters",
    id    = "clusters_tabs",
    width = 12,

    # ── Louvain ──────────────────────────────────────────────────────────────
    tabPanel(
      title = "Louvain",
      value = "clust_louvain",
      icon  = icon("layer-group"),

      fluidRow(
        box(
          title       = "Louvain Community Detection",
          width       = 12,
          solidHeader = TRUE,
          status      = "primary",
          p("The Louvain algorithm maximises modularity — it finds groups of words
            that co-occur more with each other than with words outside the group.
            In text networks, these clusters often correspond to distinct semantic
            regions of the document."),
          tags$pre(
            class = "r-code",
            style = "background:#f5f5f5; padding:8px; border-radius:4px; font-size:12px;",
'communities <- cluster_louvain(word_graph)
V(word_graph)$community <- membership(communities)'
          )
        )
      ),
      fluidRow(
        column(8,
          box(
            title       = "🎨 Cluster Visualization (Louvain)",
            width       = NULL,
            solidHeader = TRUE,
            status      = "info",
            withSpinner(plotOutput("louvain_plot", height = "550px"), color = "#CC0000", type = 4)
          )
        ),
        column(4,
          box(
            title       = "📋 Cluster Membership",
            width       = NULL,
            solidHeader = TRUE,
            status      = "info",
            withSpinner(DTOutput("louvain_table"), color = "#CC0000", type = 4)
          ),
          box(
            title       = "📊 Cluster Sizes",
            width       = NULL,
            solidHeader = TRUE,
            status      = "info",
            withSpinner(plotOutput("louvain_sizes", height = "200px"), color = "#CC0000", type = 4)
          )
        )
      )
    ),

    # ── Walktrap ──────────────────────────────────────────────────────────────
    tabPanel(
      title = "Walktrap",
      value = "clust_walktrap",
      icon  = icon("walking"),

      fluidRow(
        box(
          title       = "Walktrap Community Detection",
          width       = 12,
          solidHeader = TRUE,
          status      = "primary",
          p("Walktrap uses short random walks to identify communities. It often finds
            slightly finer-grained clusters than Louvain. Comparing the two methods
            shows which groupings are stable across algorithms."),
          tags$pre(
            class = "r-code",
            style = "background:#f5f5f5; padding:8px; border-radius:4px; font-size:12px;",
'communities_wt <- cluster_walktrap(word_graph)
V(word_graph)$community_wt <- membership(communities_wt)'
          )
        )
      ),
      fluidRow(
        column(8,
          box(
            title       = "🎨 Cluster Visualization (Walktrap)",
            width       = NULL,
            solidHeader = TRUE,
            status      = "info",
            withSpinner(plotOutput("walktrap_plot", height = "550px"), color = "#CC0000", type = 4)
          )
        ),
        column(4,
          box(
            title       = "📋 Cluster Membership",
            width       = NULL,
            solidHeader = TRUE,
            status      = "info",
            withSpinner(DTOutput("walktrap_table"), color = "#CC0000", type = 4)
          ),
          box(
            title       = "📊 Cluster Sizes",
            width       = NULL,
            solidHeader = TRUE,
            status      = "info",
            withSpinner(plotOutput("walktrap_sizes", height = "200px"), color = "#CC0000", type = 4)
          )
        )
      )
    ),

    # ── Comparison ────────────────────────────────────────────────────────────
    tabPanel(
      title = "Compare Methods",
      value = "clust_compare",
      icon  = icon("balance-scale"),

      fluidRow(
        box(
          title       = "Comparing Louvain vs. Walktrap",
          width       = 12,
          solidHeader = TRUE,
          status      = "primary",
          p("Different community detection algorithms partition the same network differently.
            The table below shows each word's cluster assignment under both methods.
            Agreement across methods increases confidence in the underlying structure."),
          withSpinner(DTOutput("compare_table"), color = "#CC0000", type = 4)
        )
      )
    )
  )
)
