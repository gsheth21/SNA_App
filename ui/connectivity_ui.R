connectivity_ui <- tagList(
  # tabName = "connectivity",
  
  tabBox(
    title = "Connectivity Analysis",
    width = 12,
    id = "connectivity_tabs",
    
    # TAB: Components
    tabPanel(
      "Components",
      icon = icon("puzzle-piece"),
      fluidRow(
        box(
          title = "🧩 Connected Components",
          width = 12,
          solidHeader = TRUE,
          status = "primary",
          p("A connected component is a maximal subset of nodes that are all reachable from each other."),
          p("Identifies whether the network is one big component or broken into disconnected pieces.")
        )
      ),
      
      fluidRow(
        column(
          width = 6,
          box(
            title = "📊 Component Statistics",
            width = NULL,
            solidHeader = TRUE,
            status = "info",
            uiOutput("component_stats")
          )
        ),
        column(
          width = 6,
          box(
            title = "📈 Component Size Distribution",
            width = NULL,
            solidHeader = TRUE,
            status = "info",
            plotlyOutput("component_size_dist", height = "300px")
          )
        )
      ),
      
      fluidRow(
        box(
          title = "🎨 Components Visualization (each color = one component)",
          width = 12,
          solidHeader = TRUE,
          status = "info",
          visNetworkOutput("components_plot", height = "500px")
        )
      ),
      
      fluidRow(
        box(
          title = "📋 Component Membership",
          width = 12,
          solidHeader = TRUE,
          status = "info",
          DTOutput("component_membership_table")
        )
      )
    ),
    
    # TAB: Paths
    tabPanel(
      "Paths",
      icon = icon("route"),
      fluidRow(
        box(
          title = "🛤️ Shortest Paths",
          width = 12,
          solidHeader = TRUE,
          status = "primary",
          p("Find the shortest path between any two nodes. Shows how nodes are connected and minimum distance."),
          
          hr(),
          
          fluidRow(
            column(
              width = 6,
              uiOutput("path_from")
            ),
            column(
              width = 6,
              uiOutput("path_to")
            )
          ),
          
          hr(),
          
          actionButton("find_path", "Find Shortest Path", class = "btn-primary")
        )
      ),
      
      fluidRow(
        column(
          width = 6,
          box(
            title = "📏 Path Information",
            width = NULL,
            solidHeader = TRUE,
            status = "info",
            uiOutput("path_results")
          )
        ),
        column(
          width = 6,
          box(
            title = "📊 Distance Statistics",
            width = NULL,
            solidHeader = TRUE,
            status = "info",
            uiOutput("distance_stats")
          )
        )
      ),
      
      fluidRow(
        box(
          title = "🎨 Path Visualization (red = path, blue = other)",
          width = 12,
          solidHeader = TRUE,
          status = "info",
          visNetworkOutput("path_plot", height = "500px")
        )
      )
    ),
    
    # TAB: Distance Matrix
    tabPanel(
      "Distance Matrix",
      icon = icon("table"),
      fluidRow(
        box(
          title = "📊 All Pairwise Distances",
          width = 12,
          solidHeader = TRUE,
          status = "primary",
          p("Shortest path distances between every pair of nodes in the network.")
        )
      ),
      
      fluidRow(
        box(
          title = "📈 Network Diameter & Properties",
          width = 12,
          solidHeader = TRUE,
          status = "info",
          uiOutput("distance_properties")
        )
      ),
      
      fluidRow(
        box(
          title = "🔥 Distance Heatmap (warmer = farther)",
          width = 12,
          solidHeader = TRUE,
          status = "info",
          plotlyOutput("distance_heatmap", height = "600px")
        )
      ),
      
      fluidRow(
        box(
          title = "📊 Distance Distribution",
          width = 12,
          solidHeader = TRUE,
          status = "info",
          plotlyOutput("distance_histogram", height = "400px")
        )
      )
    ),
    
    # TAB: Network Diameter
    tabPanel(
      "Diameter & Paths",
      icon = icon("expand"),
      fluidRow(
        box(
          title = "📐 Network Diameter",
          width = 12,
          solidHeader = TRUE,
          status = "primary",
          p("The diameter is the longest shortest path in the network."),
          p("Indicates how spread out the network is: small diameter = tightly connected, large = sparse."),
        )
      ),
      
      fluidRow(
        column(
          width = 6,
          box(
            title = "📏 Diameter Metrics",
            width = NULL,
            solidHeader = TRUE,
            status = "info",
            uiOutput("diameter_metrics")
          )
        ),
        column(
          width = 6,
          box(
            title = "📊 Path Length Statistics",
            width = NULL,
            solidHeader = TRUE,
            status = "info",
            uiOutput("path_length_stats")
          )
        )
      ),
      
      fluidRow(
        box(
          title = "📈 Average Path Length Comparison",
          width = 12,
          solidHeader = TRUE,
          status = "info",
          plotlyOutput("avg_path_length_plot", height = "400px")
        )
      )
    ),
    
    # TAB: Bridges & Cutpoints
    tabPanel(
      "Bridges & Cutpoints",
      icon = icon("link"),
      fluidRow(
        box(
          title = "🌉 Bridges and Cutpoints",
          width = 12,
          solidHeader = TRUE,
          status = "primary",
          p(strong("Bridge:"), "An edge whose removal disconnects the network."),
          p(strong("Cutpoint:"), "A node whose removal disconnects the network (also called articulation point)."),
          p("These are critical structural elements for network resilience and control."),
        )
      ),
      
      fluidRow(
        column(
          width = 6,
          box(
            title = "🌉 Bridge Information",
            width = NULL,
            solidHeader = TRUE,
            status = "info",
            uiOutput("bridge_stats")
          )
        ),
        column(
          width = 6,
          box(
            title = "🔴 Cutpoint Information",
            width = NULL,
            solidHeader = TRUE,
            status = "info",
            uiOutput("cutpoint_stats")
          )
        )
      ),
      
      fluidRow(
        box(
          title = "🎨 Visualization (red = bridges/cutpoints)",
          width = 12,
          solidHeader = TRUE,
          status = "info",
          visNetworkOutput("bridges_cutpoints_plot", height = "500px")
        )
      ),
      
      fluidRow(
        box(
          title = "📋 Critical Edges (Bridges)",
          width = 6,
          solidHeader = TRUE,
          status = "info",
          DTOutput("bridges_table")
        ),
        
        box(
          title = "📋 Critical Nodes (Cutpoints)",
          width = 6,
          solidHeader = TRUE,
          status = "info",
          DTOutput("cutpoints_table")
        )
      )
    ),
    
    # TAB: Reachability
    tabPanel(
      "Reachability",
      icon = icon("project-diagram"),
      fluidRow(
        box(
          title = "🔗 Network Reachability",
          width = 12,
          solidHeader = TRUE,
          status = "primary",
          p("Reachability analyzes which nodes can reach which other nodes and how."),
          p("Shows connectivity patterns and potential information spread."),
          
          hr(),
          
          uiOutput("reachability_node_select"),
          
          hr(),
          
          actionButton("analyze_reachability", "Analyze Reachability", class = "btn-primary")
        )
      ),
      
      fluidRow(
        column(
          width = 6,
          box(
            title = "📊 Reachability Statistics",
            width = NULL,
            solidHeader = TRUE,
            status = "info",
            uiOutput("reachability_stats")
          )
        ),
        column(
          width = 6,
          box(
            title = "📈 Reachable Nodes by Distance",
            width = NULL,
            solidHeader = TRUE,
            status = "info",
            plotlyOutput("reachable_by_distance", height = "300px")
          )
        )
      ),
      
      fluidRow(
        box(
          title = "🎨 Reachability Visualization",
          width = 12,
          solidHeader = TRUE,
          status = "info",
          visNetworkOutput("reachability_plot", height = "500px")
        )
      )
    ),
    
    # TAB: Interpretation
    tabPanel(
      "Interpretation Guide",
      icon = icon("book"),
      fluidRow(
        box(
          title = "📚 Understanding Connectivity",
          width = 12,
          solidHeader = TRUE,
          status = "info",
          
          h4("Connected Components:"),
          p("If only 1 component: network is fully connected (all nodes reachable from each other)."),
          p("If >1 component: network is fragmented - some nodes cannot reach others."),
          tags$ul(
            tags$li("Isolates: nodes with no connections"),
            tags$li("Main component: largest connected subset"),
            tags$li("Giant component: component with most nodes")
          ),
          
          h4("Shortest Paths:"),
          p("The shortest path between two nodes represents the minimum steps needed for connection."),
          tags$ul(
            tags$li("Short paths = efficient communication"),
            tags$li("Many paths = redundancy & robustness"),
            tags$li("Unique path = vulnerable")
          ),
          
          h4("Network Diameter:"),
          p("Longest shortest path - how spread out is the network?"),
          tags$ul(
            tags$li("Diameter = 1: fully connected (complete graph)"),
            tags$li("Diameter = 2-3: typical for large social networks (small world)"),
            tags$li("Diameter = very large: sparse or fragmented"),
            tags$li("Diameter = Infinity: disconnected network")
          ),
          
          h4("Bridges & Cutpoints:"),
          p("Critical elements for network stability and control."),
          tags$ul(
            tags$li("Removing bridges/cutpoints disconnects network"),
            tags$li("High degree ≠ high importance"),
            tags$li("Structural importance ≠ influence"),
            tags$li("Target in network attacks, protect in defense")
          ),
          
          h4("Practical Applications:"),
          tags$ul(
            tags$li("Infrastructure: find critical links/nodes"),
            tags$li("Epidemiology: trace disease spread paths"),
            tags$li("Organizational: identify communication flow"),
            tags$li("Resilience: evaluate network vulnerability")
          )
        )
      )
    )
  )
)