communities_ui <- tagList(
  # tabName = "communities",
  
  tabBox(
    title = "Community Analysis",
    width = 12,
    id = "communities_tabs",
    
    # TAB: Detection
    tabPanel(
      "Detection",
      icon = icon("users"),
      fluidRow(
        box(
          title = "👥 Community Detection",
          width = 12,
          solidHeader = TRUE,
          status = "primary",
          p("Discover groups of densely connected nodes. Communities are subsets where connections are stronger within than between groups."),
          
          hr(),
          
          fluidRow(
            column(
              width = 6,
              selectInput("community_algorithm", "Algorithm:", 
                         choices = c(
                           "Louvain (best quality)" = "louvain",
                           "Fast Greedy" = "fastgreedy",
                           "Walktrap" = "walktrap",
                           "Edge Betweenness" = "edge_betweenness",
                           "Label Propagation" = "label_prop"
                         ),
                         selected = "louvain")
            ),
            column(
              width = 6,
              actionButton("detect_communities", "Detect Communities", class = "btn-primary")
            )
          ),
          
          hr(),
          
          p(em("Algorithm explanations: Louvain = fastest & high quality | Fast Greedy = greedy optimization | Walktrap = random walks | Edge Betweenness = edge removal | Label Prop = label spreading"))
        )
      ),
      
      fluidRow(
        column(
          width = 6,
          box(
            title = "📊 Community Statistics",
            width = NULL,
            solidHeader = TRUE,
            status = "info",
            uiOutput("community_stats")
          )
        ),
        column(
          width = 6,
          box(
            title = "📈 Community Size Distribution",
            width = NULL,
            solidHeader = TRUE,
            status = "info",
            withSpinner(plotlyOutput("community_size_dist", height = "300px"), color = "#CC0000", type = 4)
          )
        )
      ),
      
      fluidRow(
        box(
          title = "🎨 Communities Visualization",
          width = 12,
          solidHeader = TRUE,
          status = "info",
          tabsetPanel(
            id = "community_viz_tabs", selected = "ggraph",
            tabPanel("ggraph",      value = "ggraph",      br(), withSpinner(plotOutput("community_ggraph",      height = "500px"), color = "#CC0000", type = 4)),
            tabPanel("Interactive", value = "interactive", br(), withSpinner(visNetworkOutput("community_plot", height = "500px"), color = "#CC0000", type = 4))
          )
        )
      ),
      
      fluidRow(
        box(
          title = "📋 Community Membership",
          width = 12,
          solidHeader = TRUE,
          status = "info",
          DTOutput("community_membership_table")
        )
      )
    ),
    
    # TAB: Cliques
    tabPanel(
      "Cliques",
      icon = icon("object-group"),
      fluidRow(
        box(
          title = "🔗 Clique Analysis",
          width = 12,
          solidHeader = TRUE,
          status = "primary",
          p("A clique is a subset where every node connects to every other node (fully connected subgroup)."),
          p("This analysis finds all maximal cliques and subgroups with high internal connectivity."),
          
          hr(),
          
          fluidRow(
            column(
              width = 6,
              numericInput("min_clique_size", "Minimum Clique Size:", value = 3, min = 2, max = 20)
            ),
            column(
              width = 6,
              actionButton("find_cliques", "Find Cliques", class = "btn-primary")
            )
          ),

          uiOutput("clique_size_warning")
        )
      ),
      
      fluidRow(
        column(
          width = 6,
          box(
            title = "📊 Clique Statistics",
            width = NULL,
            solidHeader = TRUE,
            status = "info",
            uiOutput("clique_stats")
          )
        ),
        column(
          width = 6,
          box(
            title = "📈 Clique Size Distribution",
            width = NULL,
            solidHeader = TRUE,
            status = "info",
            withSpinner(plotlyOutput("clique_size_dist", height = "300px"), color = "#CC0000", type = 4)
          )
        )
      ),
      
      fluidRow(
        box(
          title = "📋 Top Cliques",
          width = 12,
          solidHeader = TRUE,
          status = "info",
          DTOutput("cliques_table")
        )
      ),
      
      fluidRow(
        box(
          title = "🎨 Network with Cliques Highlighted",
          width = 12,
          solidHeader = TRUE,
          status = "info",
          withSpinner(visNetworkOutput("cliques_plot", height = "500px"), color = "#CC0000", type = 4)
        )
      )
    ),
    
    # TAB: K-Cores
    tabPanel(
      "K-Cores",
      icon = icon("layer-group"),
      fluidRow(
        box(
          title = "🔷 K-Core Decomposition",
          width = 12,
          solidHeader = TRUE,
          status = "primary",
          p("A k-core is a maximal subgraph where every node has at least k connections within the subgraph."),
          p("Decomposes network into nested layers: core (k=max) to periphery (k=low)."),
        )
      ),
      
      fluidRow(
        column(
          width = 6,
          box(
            title = "📊 K-Core Statistics",
            width = NULL,
            solidHeader = TRUE,
            status = "info",
            uiOutput("kcore_stats")
          )
        ),
        column(
          width = 6,
          box(
            title = "📈 K-Core Layer Distribution",
            width = NULL,
            solidHeader = TRUE,
            status = "info",
            withSpinner(plotlyOutput("kcore_distribution", height = "300px"), color = "#CC0000", type = 4)
          )
        )
      ),
      
      fluidRow(
        box(
          title = "🎨 K-Core Visualization (colored by layer)",
          width = 12,
          solidHeader = TRUE,
          status = "info",
          withSpinner(visNetworkOutput("kcores_plot", height = "500px"), color = "#CC0000", type = 4)
        )
      ),
      
      fluidRow(
        box(
          title = "📋 Node K-Core Membership",
          width = 12,
          solidHeader = TRUE,
          status = "info",
          DTOutput("kcore_membership_table")
        )
      )
    ),
    
    # TAB: Modularity
    tabPanel(
      "Modularity",
      icon = icon("chart-pie"),
      fluidRow(
        box(
          title = "📊 Modularity Analysis",
          width = 12,
          solidHeader = TRUE,
          status = "primary",
          p("Modularity measures how well a partition divides the network into communities."),
          p("Ranges from -1 to 1: higher = stronger community structure."),
          p("Compare different partitioning scores to evaluate community quality."),
        )
      ),
      
      fluidRow(
        column(
          width = 6,
          box(
            title = "📈 Modularity Scores",
            width = NULL,
            solidHeader = TRUE,
            status = "info",
            uiOutput("modularity_scores")
          )
        ),
        column(
          width = 6,
          box(
            title = "🎯 Interpretation",
            width = NULL,
            solidHeader = TRUE,
            status = "warning",
            uiOutput("modularity_interpretation")
          )
        )
      ),
      
      fluidRow(
        box(
          title = "📊 Modularity Gain by Merging Communities",
          width = 12,
          solidHeader = TRUE,
          status = "info",
          plotlyOutput("modularity_gain_plot", height = "400px")
        )
      )
    ),
    
    # TAB: Interpretation
    tabPanel(
      "Interpretation Guide",
      icon = icon("book"),
      fluidRow(
        box(
          title = "📚 Understanding Communities",
          width = 12,
          solidHeader = TRUE,
          status = "info",
          
          h4("What are Communities?"),
          p("Communities (or clusters) are groups of nodes that are more tightly connected to each other than to the rest of the network."),
          
          h4("Detection Algorithms:"),
          tags$ul(
            tags$li(strong("Louvain:"), "Optimization of modularity, usually best quality, fast"),
            tags$li(strong("Fast Greedy:"), "Greedy algorithm, good for large networks"),
            tags$li(strong("Walktrap:"), "Uses random walks, captures real structure"),
            tags$li(strong("Edge Betweenness:"), "Removes high-betweenness edges, slower but intuitive"),
            tags$li(strong("Label Propagation:"), "Spreading labels, fast and scalable")
          ),
          
          h4("What are Cliques?"),
          p("Cliques are the strongest form of communities: complete subgraphs where every node connects to every other."),
          tags$ul(
            tags$li("Rare in real networks (too restrictive)"),
            tags$li("Useful baseline for comparison"),
            tags$li("Identify tightly-knit groups")
          ),
          
          h4("What are K-Cores?"),
          p("Hierarchical decomposition into nested layers based on connectivity."),
          tags$ul(
            tags$li("Core = inner nucleus (high connectivity)"),
            tags$li("Layers = intermediate connections"),
            tags$li("Periphery = loosely connected nodes"),
            tags$li("Reveals network structure & stability")
          ),
          
          h4("How to Interpret Results:"),
          tags$ul(
            tags$li("High modularity (>0.3) = strong community structure"),
            tags$li("Low modularity (<0.1) = weak or no communities"),
            tags$li("More communities = more fragmented network"),
            tags$li("Similar results from multiple algorithms = robust")
          )
        )
      )
    )
  )
)