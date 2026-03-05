centrality_ui <- tagList(
  # tabName = "centrality",
  
  tabBox(
    title = "Centrality Measures",
    width = 12,
    id = "centrality_tabs",
    
    # TAB: Degree Centrality
    tabPanel(
      "Degree",
      icon = icon("star"),
      fluidRow(
        box(
          title = "⭐ Degree Centrality",
          width = 12,
          solidHeader = TRUE,
          status = "primary",
          p("The number of connections a node has. More connections = more central."),
          
          hr(),
          
          fluidRow(
            column(
              width = 6,
              radioButtons("degree_type", "Type:", 
                          choices = c("Raw Count" = "raw", "Normalized" = "normalized"),
                          selected = "normalized", inline = TRUE)
            ),
            column(
              width = 6,
              actionButton("calc_degree", "Calculate Degree Centrality", class = "btn-primary")
            )
          )
        )
      ),
      
      fluidRow(
        column(
          width = 6,
          box(
            title = "🥇 Top 5 Nodes by Degree",
            width = NULL,
            solidHeader = TRUE,
            status = "info",
            uiOutput("degree_top5")
          )
        ),
        column(
          width = 6,
          box(
            title = "📊 Centralization Score",
            width = NULL,
            solidHeader = TRUE,
            status = "info",
            uiOutput("degree_centralization")
          )
        )
      ),
      
      fluidRow(
        box(
          title = "🕸️ Network Visualization (sized by degree)",
          width = 12,
          solidHeader = TRUE,
          status = "info",
          visNetworkOutput("degree_plot", height = "500px")
        )
      ),
      
      fluidRow(
        box(
          title = "📈 Degree Distribution",
          width = 12,
          solidHeader = TRUE,
          status = "info",
          plotlyOutput("degree_dist", height = "400px")
        )
      )
    ),
    
    # TAB: Closeness Centrality
    tabPanel(
      "Closeness",
      icon = icon("compress-arrows-alt"),
      fluidRow(
        box(
          title = "🎯 Closeness Centrality",
          width = 12,
          solidHeader = TRUE,
          status = "primary",
          p("How close/near a node is to all other nodes. Shorter average distance = more central."),
          p("Measures: How quickly can information from this node reach all others?"),
          
          hr(),
          
          fluidRow(
            column(
              width = 6,
              radioButtons("closeness_type", "Type:", 
                          choices = c("Normalized" = "normalized", "Raw" = "raw"),
                          selected = "normalized", inline = TRUE)
            ),
            column(
              width = 6,
              actionButton("calc_closeness", "Calculate Closeness", class = "btn-primary")
            )
          )
        )
      ),
      
      fluidRow(
        column(
          width = 6,
          box(
            title = "🥇 Top 5 Nodes by Closeness",
            width = NULL,
            solidHeader = TRUE,
            status = "info",
            uiOutput("closeness_top5")
          )
        ),
        column(
          width = 6,
          box(
            title = "📊 Closeness Statistics",
            width = NULL,
            solidHeader = TRUE,
            status = "info",
            uiOutput("closeness_stats")
          )
        )
      ),
      
      fluidRow(
        box(
          title = "🕸️ Network Visualization (sized by closeness)",
          width = 12,
          solidHeader = TRUE,
          status = "info",
          visNetworkOutput("closeness_plot", height = "500px")
        )
      ),
      
      fluidRow(
        box(
          title = "📈 Closeness Distribution",
          width = 12,
          solidHeader = TRUE,
          status = "info",
          plotlyOutput("closeness_dist", height = "400px")
        )
      )
    ),
    
    # TAB: Betweenness Centrality
    tabPanel(
      "Betweenness",
      icon = icon("exchange-alt"),
      fluidRow(
        box(
          title = "🌉 Betweenness Centrality",
          width = 12,
          solidHeader = TRUE,
          status = "primary",
          p("Number of shortest paths passing through a node. Bridges & brokers are high."),
          p("Measures: How often is this node on the shortest path between other nodes?"),
          
          hr(),
          
          fluidRow(
            column(
              width = 6,
              radioButtons("betweenness_type", "Type:", 
                          choices = c("Normalized" = "normalized", "Raw" = "raw"),
                          selected = "normalized", inline = TRUE)
            ),
            column(
              width = 6,
              actionButton("calc_betweenness", "Calculate Betweenness", class = "btn-primary")
            )
          )
        )
      ),
      
      fluidRow(
        column(
          width = 6,
          box(
            title = "🥇 Top 5 Bridge Nodes",
            width = NULL,
            solidHeader = TRUE,
            status = "info",
            uiOutput("betweenness_top5")
          )
        ),
        column(
          width = 6,
          box(
            title = "📊 Betweenness Statistics",
            width = NULL,
            solidHeader = TRUE,
            status = "info",
            uiOutput("betweenness_stats")
          )
        )
      ),
      
      fluidRow(
        box(
          title = "🕸️ Network Visualization (sized by betweenness)",
          width = 12,
          solidHeader = TRUE,
          status = "info",
          visNetworkOutput("betweenness_plot", height = "500px")
        )
      ),
      
      fluidRow(
        box(
          title = "📈 Betweenness Distribution",
          width = 12,
          solidHeader = TRUE,
          status = "info",
          plotlyOutput("betweenness_dist", height = "400px")
        )
      )
    ),
    
    # TAB: Eigenvector Centrality
    tabPanel(
      "Eigenvector",
      icon = icon("sitemap"),
      fluidRow(
        box(
          title = "👑 Eigenvector Centrality",
          width = 12,
          solidHeader = TRUE,
          status = "primary",
          p("Importance based on connections to other important nodes."),
          p("Distinguishes: It's not just who you know, it's who they know!"),
          
          hr(),
          
          actionButton("calc_eigenvector", "Calculate Eigenvector Centrality", class = "btn-primary")
        )
      ),
      
      fluidRow(
        column(
          width = 6,
          box(
            title = "👑 Top 5 Influential Nodes",
            width = NULL,
            solidHeader = TRUE,
            status = "info",
            uiOutput("eigenvector_top5")
          )
        ),
        column(
          width = 6,
          box(
            title = "📊 Eigenvector Statistics",
            width = NULL,
            solidHeader = TRUE,
            status = "info",
            uiOutput("eigenvector_stats")
          )
        )
      ),
      
      fluidRow(
        box(
          title = "🕸️ Network Visualization (sized by influence)",
          width = 12,
          solidHeader = TRUE,
          status = "info",
          visNetworkOutput("eigenvector_plot", height = "500px")
        )
      ),
      
      fluidRow(
        box(
          title = "📈 Eigenvector Distribution",
          width = 12,
          solidHeader = TRUE,
          status = "info",
          plotlyOutput("eigenvector_dist", height = "400px")
        )
      )
    ),
    
    # TAB: Compare
    tabPanel(
      "Compare",
      icon = icon("balance-scale"),
      fluidRow(
        box(
          title = "⚖️ Compare Centrality Measures",
          width = 12,
          solidHeader = TRUE,
          status = "primary",
          p("Different centrality measures capture different aspects of node importance."),
          p("Compare to understand which nodes are important in different ways."),
          
          hr(),
          
          actionButton("compare_all_centrality", "Calculate All Measures", class = "btn-primary")
        )
      ),
      
      fluidRow(
        box(
          title = "📊 Centrality Measures Comparison Table",
          width = 12,
          solidHeader = TRUE,
          status = "info",
          DTOutput("centrality_comparison_table")
        )
      ),
      
      fluidRow(
        box(
          title = "📈 Correlation Between Measures",
          width = 12,
          solidHeader = TRUE,
          status = "info",
          plotlyOutput("centrality_correlation_heatmap", height = "500px")
        )
      ),
      
      fluidRow(
        box(
          title = "🎯 Centrality Ranking Profiles",
          width = 12,
          solidHeader = TRUE,
          status = "info",
          plotlyOutput("centrality_radar", height = "500px")
        )
      )
    ),
    
    # TAB: Interpretation
    tabPanel(
      "Interpretation Guide",
      icon = icon("book"),
      fluidRow(
        box(
          title = "📚 Understanding Centrality Measures",
          width = 12,
          solidHeader = TRUE,
          status = "info",
          
          h4("Overview:"),
          p("Centrality measures identify the most important nodes in a network from different perspectives."),
          
          h4("Degree Centrality:"),
          tags$ul(
            tags$li("Simplest measure: count direct connections"),
            tags$li("High = well-connected (hub)"),
            tags$li("Best for: immediate influence, popularity")
          ),
          
          h4("Closeness Centrality:"),
          tags$ul(
            tags$li("Inverse of average distance to all other nodes"),
            tags$li("High = close to everyone (easy information spread)"),
            tags$li("Best for: how quickly info can reach others")
          ),
          
          h4("Betweenness Centrality:"),
          tags$ul(
            tags$li("Proportion of shortest paths passing through the node"),
            tags$li("High = broker/bridge (controls information flow)"),
            tags$li("Best for: identifying gatekeepers, structural holes")
          ),
          
          h4("Eigenvector Centrality:"),
          tags$ul(
            tags$li("Importance of neighbors contributes to your importance"),
            tags$li("High = connected to other important nodes"),
            tags$li("Best for: status, prestige, influence")
          ),
          
          h4("When to Use Which:"),
          tags$ul(
            tags$li("Marketing: Degree (find influencers)"),
            tags$li("Disease: Betweenness (find spreaders)"),
            tags$li("Leadership: Closeness (coordinate network)"),
            tags$li("Status: Eigenvector (who's influential)")
          )
        )
      )
    )
  )
)