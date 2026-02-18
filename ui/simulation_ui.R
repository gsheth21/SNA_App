simulation_ui <- tagList(
  # tabName = "simulation",
  
  h2("🎲 Network Simulation"),
  p("Generate and analyze simulated networks to understand network formation processes."),
  
  tabBox(
    title = "Network Simulation Tools",
    width = 12,
    id = "simulation_tabs",

    # TAB: Built-in Types
    tabPanel(
      "Built-in Types",
      icon = icon("shapes"),
      
      fluidRow(
        box(
          title = "🏗️ Generate Built-in Graph Types",
          width = 12,
          solidHeader = TRUE,
          status = "primary",
          p("Generate standard network structures to understand basic graph properties."),
          radioButtons(
            "builtin_type",
            "Select Type:",
            choices = c(
              "Empty Graph (nodes only, no edges)" = "empty",
              "Full Graph (complete connections)" = "full",
              "Star Graph (central hub)" = "star",
              "Ring Graph (circular)" = "ring",
              "Tree Graph (hierarchical)" = "tree",
              "Lattice Graph (grid structure)" = "lattice"
            ),
            selected = "star"
          ),
          sliderInput("builtin_nodes", "Number of Nodes:", 
                      min = 10, max = 100, value = 40, step = 5),
          actionButton("generate_builtin", "Generate", 
                       class = "btn-danger", icon = icon("play"))
        )
      ),
      
      fluidRow(
        column(
          width = 8,
          box(
            title = "Graph Visualization",
            width = NULL,
            solidHeader = TRUE,
            visNetworkOutput("builtin_plot", height = "500px")
          )
        ),
        column(
          width = 4,
          box(
            title = "Graph Properties",
            width = NULL,
            solidHeader = TRUE,
            status = "info",
            uiOutput("builtin_properties")
          )
        )
      )
    ),

    # TAB: Random Graphs (Erdős-Rényi)
    tabPanel(
      "Random Graphs",
      icon = icon("dice"),
      
      fluidRow(
        box(
          title = "🎲 Erdős-Rényi Random Graphs",
          width = 12,
          solidHeader = TRUE,
          status = "primary",
          p("Generate random networks where each possible edge exists with equal probability."),
          p(strong("Key Insight:"), "Same parameters → different structures (stochastic process)"),
          sliderInput("erdos_nodes", "Number of Nodes:", 
                      min = 10, max = 100, value = 40, step = 5),
          sliderInput("erdos_prob", "Tie Probability:", 
                      min = 0.01, max = 0.50, value = 0.0667, step = 0.01),
          radioButtons(
            "erdos_num_graphs",
            "Number of Graphs:",
            choices = c("1", "2", "4"),
            selected = "2",
            inline = TRUE
          ),
          actionButton("generate_erdos", "Generate Random Graph(s)", 
                       class = "btn-danger", icon = icon("dice"))
        )
      ),
      
      fluidRow(
        box(
          title = "Generated Random Graphs",
          width = 12,
          solidHeader = TRUE,
          uiOutput("erdos_graphs_ui")
        )
      ),
      
      fluidRow(
        box(
          title = "ℹ️ Key Insight",
          width = 12,
          status = "info",
          p("Notice how graphs with identical parameters produce different structures 
            due to stochastic (random) processes. This demonstrates the importance of 
            running multiple simulations.")
        )
      )
    ),
    
    # TAB: Small World (Watts-Strogatz)
    tabPanel(
      "Small World",
      icon = icon("globe"),
      
      fluidRow(
        box(
          title = "🌍 Small World Network (Watts-Strogatz Model)",
          width = 12,
          solidHeader = TRUE,
          status = "primary",
          p("Generate networks with high clustering and short path lengths."),
          p(strong('"Six Degrees of Separation"'), 
            " - Most real-world networks have small-world properties."),
          sliderInput("sw_nodes", "Nodes:", 
                      min = 20, max = 100, value = 50, step = 5),
          sliderInput("sw_neighbors", "Neighbors:", 
                      min = 2, max = 10, value = 4, step = 1),
          sliderInput("sw_rewire", "Rewiring Probability:", 
                      min = 0, max = 1, value = 0.1, step = 0.05),
          p("💡 ", strong("0.0"), " = Regular lattice | ", 
            strong("0.1"), " = Small world ('sweet spot') | ", 
            strong("1.0"), " = Random graph"),
          actionButton("generate_sw", "Generate", 
                       class = "btn-danger", icon = icon("play"))
        )
      ),
      
      fluidRow(
        column(
          width = 8,
          box(
            title = "Network Visualization",
            width = NULL,
            solidHeader = TRUE,
            visNetworkOutput("sw_plot", height = "500px")
          )
        ),
        column(
          width = 4,
          box(
            title = "Small World Properties",
            width = NULL,
            solidHeader = TRUE,
            status = "info",
            uiOutput("sw_properties"),
            hr(),
            p(strong('ℹ️ "Six Degrees of Separation"')),
            p("High clustering + short paths = small world"),
            p("Typical of social networks, neural networks, power grids")
          )
        )
      )
    ),
    
    # TAB: Preferential Attachment (Barabási-Albert)
    tabPanel(
      "Preferential Attachment",
      icon = icon("chart-line"),
      
      fluidRow(
        box(
          title = "📈 Scale-Free Network (Barabási-Albert Model)",
          width = 12,
          solidHeader = TRUE,
          status = "primary",
          p("Generate networks with power-law degree distribution."),
          p(strong('"Rich get richer"'), 
            " - New nodes preferentially attach to well-connected nodes."),
          sliderInput("ba_nodes", "Nodes:", 
                      min = 20, max = 200, value = 100, step = 10),
          sliderInput("ba_power", "Power:", 
                      min = 0.5, max = 2.0, value = 1.0, step = 0.1),
          sliderInput("ba_connections", "Initial Connections:", 
                      min = 1, max = 5, value = 2, step = 1),
          actionButton("generate_ba", "Generate", 
                       class = "btn-danger", icon = icon("play"))
        )
      ),
      
      fluidRow(
        column(
          width = 8,
          box(
            title = "Network Visualization",
            width = NULL,
            solidHeader = TRUE,
            p(strong("Red nodes:"), " High degree (> 7 connections)"),
            p(strong("Black nodes:"), " Low degree"),
            visNetworkOutput("ba_plot", height = "500px")
          )
        ),
        column(
          width = 4,
          box(
            title = "Degree Distribution",
            width = NULL,
            solidHeader = TRUE,
            plotlyOutput("ba_degree_dist", height = "300px"),
            hr(),
            p(strong('ℹ️ Power Law Distribution')),
            tags$ul(
              tags$li("Few nodes have many connections (hubs)"),
              tags$li("Most nodes have few connections"),
              tags$li('"Rich get richer" phenomenon')
            ),
            p("Typical of: Internet, citations, social media")
          )
        )
      )
    ),
    
    # TAB: Random Walk (RDS Simulation)
    tabPanel(
      "Random Walk",
      icon = icon("walking"),
      
      fluidRow(
        box(
          title = "🚶 Random Walk Simulation (Respondent-Driven Sampling)",
          width = 12,
          solidHeader = TRUE,
          status = "primary",
          p("Simulate how sampling via social connections can approximate network centrality."),
          p(strong("Use Case:"), "Respondent-driven sampling in hard-to-reach populations"),
          uiOutput("rw_network_select"),
          uiOutput("rw_start_node"),
          sliderInput("rw_steps", "Number of Steps:", 
                      min = 5, max = 10000, value = 100, step = 5),
          radioButtons(
            "rw_type",
            "Walk Type:",
            choices = c(
              "Simple Random Walk" = "simple", 
              "Weighted by Degree" = "weighted"
            ),
            selected = "simple",
            inline = TRUE
          ),
          actionButton("start_walk", "Start Walk", 
                       class = "btn-danger", icon = icon("play"))
        )
      ),
      
      fluidRow(
        column(
          width = 8,
          box(
            title = "Walk Visualization",
            width = NULL,
            solidHeader = TRUE,
            p(strong("Node color intensity:"), " Visit frequency"),
            p(strong("Node size:"), " Proportional to visits"),
            visNetworkOutput("rw_plot", height = "500px")
          )
        ),
        column(
          width = 4,
          box(
            title = "Walk Statistics",
            width = NULL,
            solidHeader = TRUE,
            status = "info",
            uiOutput("rw_stats")
          )
        )
      )
    ),
    
    # TAB: Network Distributions (1000 simulations)
    tabPanel(
      "Network Distributions",
      icon = icon("chart-area"),
      
      fluidRow(
        box(
          title = "📊 Network Metric Distributions (1000 Random Graphs)",
          width = 12,
          solidHeader = TRUE,
          status = "primary",
          p("Generate 1000 random networks and examine the distribution of network metrics."),
          p(strong("Purpose:"), "Establish baseline distributions for comparison with observed networks."),
          sliderInput("dist_nodes", "Number of Nodes:", 
                      min = 10, max = 100, value = 40, step = 5),
          sliderInput("dist_prob", "Edge Probability:", 
                      min = 0.01, max = 0.50, value = 0.0667, step = 0.01),
          actionButton("generate_distributions", "Generate 1000 Networks", 
                       class = "btn-danger", icon = icon("play"))
        )
      ),
      
      fluidRow(
        box(
          title = "Distribution Plots",
          width = 12,
          solidHeader = TRUE,
          plotOutput("distributions_plot", height = "600px"),
          p(strong("Red vertical line:"), " Mean value"),
          p("These distributions show what to expect from random networks with the specified parameters.")
        )
      )
    ),
    
    # TAB: Compare to Observed (CUG Tests)
    tabPanel(
      "Compare to Observed",
      icon = icon("microscope"),
      
      fluidRow(
        box(
          title = "🔬 Compare Observed vs. Simulated (Conditional Uniform Graph Tests)",
          width = 12,
          solidHeader = TRUE,
          status = "primary",
          p("Test whether your observed network differs significantly from random networks."),
          p(strong("Currently loaded network:"), textOutput("current_dataset_name", inline = TRUE)),
          hr(),
          radioButtons(
            "cug_null_model",
            "Null Model:",
            choices = c(
              "Random Graph (same size & density)" = "random",
              "Degree-Preserving Randomization" = "degree_preserving"
            ),
            selected = "random",
            inline = TRUE
          ),
          radioButtons(
            "cug_simulations",
            "Number of Simulations:",
            choices = c("100", "500", "1000"),
            selected = "100",
            inline = TRUE
          ),
          actionButton("run_cug", "Run CUG Test", 
                       class = "btn-danger", icon = icon("play"))
        )
      ),
      
      fluidRow(
        box(
          title = "Distribution Comparisons",
          width = 12,
          solidHeader = TRUE,
          p(strong("Black dashed line:"), " Mean of simulated networks"),
          p(strong("Red solid line:"), " Observed network value"),
          plotOutput("cug_distributions", height = "600px")
        )
      ),
      
      fluidRow(
        column(
          width = 6,
          box(
            title = "CUG Test Results",
            width = NULL,
            solidHeader = TRUE,
            status = "info",
            DTOutput("cug_results_table")
          )
        ),
        column(
          width = 6,
          box(
            title = "ℹ️ Interpretation",
            width = NULL,
            solidHeader = TRUE,
            status = "info",
            uiOutput("cug_interpretation")
          )
        )
      )
    )
  )
)