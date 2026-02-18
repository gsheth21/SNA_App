overview_ui <- tagList(
  # tabName = "overview",
  
  # Welcome Section
  fluidRow(
    box(
      title = "📖 Welcome to One-Mode Network Analysis",
      width = 12,
      solidHeader = TRUE,
      status = "danger",  # NC State red
      h3("Social Network Analysis Course"),
      p("Learn about social networks through interactive visualization and analysis."),
      p("This interactive application accompanies the Social Network Analysis textbook 
        and provides hands-on experience with network data, visualization, and analysis techniques."),
      hr(),
      tags$h4("🚀 Quick Start:"),
      tags$ol(
        tags$li("Select a dataset from the sidebar (try 'Hi-Tech Managers' first)"),
        tags$li("Explore the network visualization in the Visualization tab"),
        tags$li("Run analyses to understand network patterns and structures"),
        tags$li("Try the Simulation tab to generate and compare networks")
      )
    )
  ),
  
  # What is SNA Section
  fluidRow(
    box(
      title = "🔍 What is Social Network Analysis?",
      width = 12,
      solidHeader = TRUE,
      collapsible = TRUE,
      collapsed = FALSE,
      p("Social network analysis (SNA) refers to the study of relationships between 
        people or groups of people. Relationships are important to study for lots of reasons:"),
      tags$ul(
        tags$li(strong("Information & Disease Spread:"), 
                " Understanding how things like information, ideas, and diseases spread across societies"),
        tags$li(strong("Identifying Influence:"), 
                " Revealing which people are the most popular, most powerful, and most healthy"),
        tags$li(strong("Community Detection:"), 
                " Discovering how people form subgroups or clusters of individuals")
      ),
      hr(),
      p(strong("Our Goal:"), "This app is designed to make social network analysis easy to 
        understand and apply. It does not require advanced statistical knowledge nor 
        extensive coding experience.")
    )
  ),
  
  # Current Network Properties
  fluidRow(
    box(
      title = "📊 Current Network Properties",
      width = 6,
      solidHeader = TRUE,
      status = "info",
      uiOutput("overview_properties")
    ),
    
    box(
      title = "ℹ️ About This Dataset",
      width = 6,
      solidHeader = TRUE,
      status = "info",
      uiOutput("dataset_description")
    )
  ),
  
  # Network Fundamentals Section
  fluidRow(
    box(
      title = "📚 Network Fundamentals",
      width = 12,
      solidHeader = TRUE,
      collapsible = TRUE,
      collapsed = TRUE,
      
      h4("What is a Network?"),
      p("A network is a series of ", strong("dots (nodes)"), " and ", 
        strong("lines (edges)"), " connecting them."),
      
      tags$ul(
        tags$li(strong("Nodes (Vertices):"), " People, organizations, websites, etc."),
        tags$li(strong("Edges (Ties):"), " Relationships, friendships, transactions, hyperlinks, etc.")
      ),
      
      hr(),
      
      h4("Three Ways to Represent Networks:"),
      
      tags$h5("1️⃣ Edgelist"),
      p("A simple table showing 'From → To' connections:"),
      tags$pre("
From    To
John    Mary
Mary    Bob
Bob     Alice
      "),
      
      tags$h5("2️⃣ Adjacency Matrix"),
      p("A grid showing connections (1 = connected, 0 = not connected):"),
      tags$pre("
        John  Mary  Bob  Alice
John     0     1    0    0
Mary     1     0    1    0
Bob      0     1    0    1
Alice    0     0    1    0
      "),
      
      tags$h5("3️⃣ Graph Visualization"),
      p("An interactive visual representation (see the Visualization tab!)")
    )
  )
)