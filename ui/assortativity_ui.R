assortativity_ui <- tagList(
  # tabName = "assortativity",
  
  tabBox(
    title = "Assortativity Analysis",
    width = 12,
    id = "assortativity_tabs",
    
    # TAB: Analysis
    tabPanel(
      "Analysis",
      icon = icon("bullseye"),
      fluidRow(
        box(
          title = "🎯 Assortativity Coefficients",
          width = 12,
          solidHeader = TRUE,
          status = "primary",
          p("Assortativity measure the tendency of nodes with similar characteristics to connect with each other (homophily principle)."),
          p(strong("Degree Assortativity:"), "Measures if high-degree nodes connect to other high-degree nodes."),
          p(strong("Attribute Assortativity:"), "Measures if nodes with similar attributes tend to connect."),
          
          hr(),
          
          # Button to calculate degree assortativity
          actionButton("calc_degree_assort", "Calculate Degree Assortativity", class = "btn-primary"),
          
          hr(),
          
          h5("Degree Assortativity Coefficient:"),
          uiOutput("degree_assort_result"),
          
          hr(),
          
          h5("Interpretation Guide:"),
          tags$ul(
            tags$li("Values range from -1 to +1"),
            tags$li("Positive values: similar nodes tend to connect (homophilic)"),
            tags$li("Negative values: dissimilar nodes tend to connect (disassortative)"),
            tags$li("Values near 0: no clear assortativity pattern")
          )
        )
      ),
      
      fluidRow(
        column(
          width = 6,
          box(
            title = "📊 Degree Assortativity Visualization",
            width = NULL,
            solidHeader = TRUE,
            status = "info",
            plotlyOutput("degree_assort_scatter", height = "400px")
          )
        ),
        column(
          width = 6,
          box(
            title = "📈 Degree Distribution by Neighbors",
            width = NULL,
            solidHeader = TRUE,
            status = "info",
            plotlyOutput("neighbor_degree_dist", height = "400px")
          )
        )
      )
    ),
    
    # TAB: Attribute Assortativity
    tabPanel(
      "Attribute Assortativity",
      icon = icon("tags"),
      fluidRow(
        box(
          title = "🏷️ Categorical Attribute Assortativity",
          width = 12,
          solidHeader = TRUE,
          status = "primary",
          p("Analyze how nodes with similar categorical attributes tend to connect."),
          
          hr(),
          
          uiOutput("assortativity_attribute_select"),
          
          hr(),
          
          actionButton("calc_attr_assort", "Calculate Attribute Assortativity", class = "btn-primary"),
          
          hr(),
          
          h5("Results:"),
          uiOutput("attr_assort_result")
        )
      ),
      
      fluidRow(
        box(
          title = "🎨 Network Colored by Selected Attribute",
          width = 12,
          solidHeader = TRUE,
          status = "info",
          visNetworkOutput("attr_assort_plot", height = "500px")
        )
      ),
      
      fluidRow(
        box(
          title = "📊 Connections Between Attribute Groups",
          width = 12,
          solidHeader = TRUE,
          status = "info",
          plotlyOutput("attr_connection_bar", height = "400px")
        )
      )
    ),
    
    # TAB: Mixing Matrix
    tabPanel(
      "Mixing Matrix",
      icon = icon("table"),
      fluidRow(
        box(
          title = "📋 Mixing Matrix",
          width = 12,
          solidHeader = TRUE,
          status = "primary",
          p("A mixing matrix shows how many connections exist between each pair of attribute categories."),
          
          hr(),
          
          uiOutput("mixing_attribute_select"),
          
          hr(),
          
          actionButton("calc_mixing_matrix", "Generate Mixing Matrix", class = "btn-primary")
        )
      ),
      
      fluidRow(
        box(
          title = "🔢 Mixing Matrix (Counts)",
          width = 6,
          solidHeader = TRUE,
          status = "info",
          DTOutput("mixing_matrix_counts")
        ),
        
        box(
          title = "📊 Mixing Matrix (Proportions)",
          width = 6,
          solidHeader = TRUE,
          status = "info",
          DTOutput("mixing_matrix_proportions")
        )
      ),
      
      fluidRow(
        box(
          title = "🔥 Mixing Matrix Heatmap",
          width = 12,
          solidHeader = TRUE,
          status = "info",
          plotlyOutput("mixing_matrix_heatmap", height = "500px")
        )
      )
    ),
    
    # TAB: Numerical Assortativity
    tabPanel(
      "Numerical Assortativity",
      icon = icon("chart-line"),
      fluidRow(
        box(
          title = "📈 Numerical Attribute Assortativity",
          width = 12,
          solidHeader = TRUE,
          status = "primary",
          p("Correlations between numerical attributes of connected nodes."),
          p("This tests whether nodes with similar numerical values tend to connect."),
          
          hr(),
          
          uiOutput("numerical_attribute_select"),
          
          hr(),
          
          actionButton("calc_numerical_assort", "Calculate Correlation", class = "btn-primary"),
          
          hr(),
          
          h5("Pearson Correlation Results:"),
          uiOutput("numerical_assort_result")
        )
      ),
      
      fluidRow(
        box(
          title = "📊 Attribute Values of Connected Nodes",
          width = 12,
          solidHeader = TRUE,
          status = "info",
          plotlyOutput("connected_values_plot", height = "500px")
        )
      )
    ),
    
    # TAB: Interpretation
    tabPanel(
      "Interpretation Guide",
      icon = icon("book"),
      fluidRow(
        box(
          title = "📚 Understanding Assortativity",
          width = 12,
          solidHeader = TRUE,
          status = "info",
          
          h4("What is Assortativity?"),
          p("Assortativity refers to the preference of nodes to attach to other similar nodes - a fundamental principle known as homophily ('birds of a feather flock together')."),
          
          h4("Types of Assortativity:"),
          tags$ul(
            tags$li(strong("Degree Assortativity:"), "Do high-degree nodes connect to other high-degree nodes?"),
            tags$li(strong("Attribute Assortativity:"), "Do nodes with similar attributes prefer to connect?"),
            tags$li(strong("Numerical Assortativity:"), "Is there a correlation in numerical attributes of neighbors?")
          ),
          
          h4("Interpretation:"),
          tags$ul(
            tags$li("r > 0 (Assortative): Similar nodes connect more than expected"),
            tags$li("r < 0 (Disassortative): Dissimilar nodes connect more than expected"),
            tags$li("r ≈ 0 (No Assortativity): No preference for similarity")
          ),
          
          h4("Real-World Examples:"),
          tags$ul(
            tags$li("Social networks are typically assortative by age and political beliefs"),
            tags$li("Disease networks may be disassortative (hubs connect to low-degree nodes)"),
            tags$li("Professional networks show assortativity by education level")
          ),
          
          h4("Applications:"),
          tags$ul(
            tags$li("Understanding network formation processes"),
            tags$li("Predicting network robustness and resilience"),
            tags$li("Identifying demographic mixing patterns"),
            tags$li("Studying social inequality and stratification")
          )
        )
      )
    )
  )
)